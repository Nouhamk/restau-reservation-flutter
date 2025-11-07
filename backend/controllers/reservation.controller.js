const { getConnection } = require('../db');
const notificationService = require('../services/notification.service');

exports.createReservation = async (req, res) => {
  const { reservation_date, reservation_time, guests, notes, place_id } = req.body;

  if (!reservation_date || !reservation_time || !guests) {
    return res.status(400).json({ error: 'Champs obligatoires manquants' });
  }

  try {
    const connection = await getConnection();
    
    let existingQuery = 'SELECT SUM(guests) as total_guests FROM reservations WHERE reservation_date = ? AND reservation_time = ? AND status NOT IN ("cancelled", "rejected")';
    const existingParams = [reservation_date, reservation_time];
    if (place_id) {
      existingQuery += ' AND place_id = ?';
      existingParams.push(place_id);
    }

    const [existing] = await connection.execute(existingQuery, existingParams);

    const [slot] = await connection.execute('SELECT max_capacity FROM time_slots WHERE slot_time = ?', [reservation_time]);
    if (slot.length === 0) {
      await connection.end();
      return res.status(400).json({ error: 'Créneau horaire invalide' });
    }

    const currentCapacity = existing[0].total_guests || 0;
    if (currentCapacity + guests > slot[0].max_capacity) {
      await connection.end();
      return res.status(400).json({ 
        error: 'Plus de places disponibles pour ce créneau',
        available: slot[0].max_capacity - currentCapacity
      });
    }

    const [result] = await connection.execute(
      'INSERT INTO reservations (user_id, reservation_date, reservation_time, guests, notes, place_id) VALUES (?, ?, ?, ?, ?, ?)',
      [req.userId, reservation_date, reservation_time, guests, notes || null, place_id || null]
    );

    const reservationId = result.insertId;
    
    // Récupérer le nom du lieu si place_id est fourni
    let placeName = null;
    if (place_id) {
      const [place] = await connection.execute('SELECT name FROM places WHERE id = ?', [place_id]);
      if (place.length > 0) {
        placeName = place[0].name;
      }
    }
    
    await connection.end();
    
    // Envoyer une notification par email aux hôtes
    try {
      notificationService.notifyNewReservation(reservationId, {
        userId: req.userId,
        date: reservation_date,
        timeSlot: reservation_time,
        partySize: guests,
        placeName
      });
    } catch (emailError) {
      console.error('⚠️  Failed to send host notification:', emailError.message);
      // Ne pas échouer la requête si l'email échoue
    }

    res.status(201).json({ message: 'Réservation créée avec succès', reservationId });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.listReservations = async (req, res) => {
  try {
    const connection = await getConnection();
    const { place_id } = req.query;

    let query = 'SELECT * FROM reservations WHERE user_id = ?';
    let params = [req.userId];

    if (place_id) {
      query += ' AND place_id = ?';
      params.push(place_id);
    }

    if (req.userRole === 'host' || req.userRole === 'admin') {
      query = 'SELECT r.*, u.name as user_name, u.email as user_email, u.phone as user_phone FROM reservations r JOIN users u ON r.user_id = u.id';
      params = [];
      if (place_id) {
        query += ' WHERE r.place_id = ?';
        params.push(place_id);
      }
    }

    query += ' ORDER BY reservation_date DESC, reservation_time DESC';

    const [reservations] = await connection.execute(query, params);
    await connection.end();
    res.json(reservations);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.updateReservation = async (req, res) => {
  const { id } = req.params;
  const { reservation_date, reservation_time, guests, notes } = req.body;
  try {
    const connection = await getConnection();
    const [existing] = await connection.execute('SELECT * FROM reservations WHERE id = ? AND user_id = ?', [id, req.userId]);
    if (existing.length === 0) {
      await connection.end();
      return res.status(404).json({ error: 'Réservation non trouvée' });
    }

    await connection.execute('UPDATE reservations SET reservation_date = ?, reservation_time = ?, guests = ?, notes = ? WHERE id = ?', [reservation_date, reservation_time, guests, notes || null, id]);
    await connection.end();
    res.json({ message: 'Réservation modifiée avec succès' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.cancelReservation = async (req, res) => {
  const { id } = req.params;
  try {
    const connection = await getConnection();
    const [existing] = await connection.execute('SELECT * FROM reservations WHERE id = ? AND user_id = ?', [id, req.userId]);
    if (existing.length === 0) {
      await connection.end();
      return res.status(404).json({ error: 'Réservation non trouvée' });
    }

    await connection.execute('UPDATE reservations SET status = "cancelled" WHERE id = ?', [id]);
    await connection.end();
    res.json({ message: 'Réservation annulée avec succès' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.patchStatus = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  
  // Vérifier que l'utilisateur est hôte ou admin
  if (req.userRole !== 'host' && req.userRole !== 'admin') {
    return res.status(403).json({ error: 'Accès interdit' });
  }
  
  // Valider le statut (inclut maintenant 'rejected')
  if (!['confirmed', 'rejected', 'cancelled'].includes(status)) {
    return res.status(400).json({ error: 'Statut invalide. Valeurs acceptées: confirmed, rejected, cancelled' });
  }

  try {
    const connection = await getConnection();
    
    // Vérifier que la réservation existe
    const [reservation] = await connection.execute(
      'SELECT id, status, user_id FROM reservations WHERE id = ?',
      [id]
    );
    
    if (reservation.length === 0) {
      await connection.end();
      return res.status(404).json({ error: 'Réservation non trouvée' });
    }
    
    const oldStatus = reservation[0].status;
    
    // Mettre à jour le statut
    await connection.execute('UPDATE reservations SET status = ? WHERE id = ?', [status, id]);
    await connection.end();
    
    // Envoyer une notification par email au client
    try {
      notificationService.sendStatusUpdate(reservation[0].user_id, id, oldStatus, status);
    } catch (emailError) {
      console.error('⚠️  Failed to send email notification:', emailError.message);
      // Ne pas échouer la requête si l'email échoue
    }
    
    res.json({ 
      message: 'Statut mis à jour avec succès', 
      reservationId: id,
      oldStatus,
      newStatus: status 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Routes
const authRoutes = require('./routes/auth.route');
const menuRoutes = require('./routes/menu.route');
const reservationRoutes = require('./routes/reservations.route');
const placeRoutes = require('./routes/places.route');
const timeSlotRoutes = require('./routes/timeSlots.route');
const authMiddleware = require('./middlewares/auth');

app.use('/api', authRoutes);
app.use('/api/menu', menuRoutes);
app.use('/api/reservations', reservationRoutes);
app.use('/api/places', placeRoutes);
app.use('/api/time-slots', timeSlotRoutes);

// ROUTES RÉSERVATIONS

// Créer une réservation
app.post('/api/reservations', authMiddleware, async (req, res) => {
  const { reservation_date, reservation_time, guests, notes, place_id } = req.body;

  if (!reservation_date || !reservation_time || !guests) {
    return res.status(400).json({ error: 'Champs obligatoires manquants' });
  }

  try {
    const connection = await mysql.createConnection(dbConfig);
    
    // Vérifier la disponibilité (filtrer par place_id si fourni)
    let existingQuery = 'SELECT SUM(guests) as total_guests FROM reservations WHERE reservation_date = ? AND reservation_time = ? AND status != "cancelled"';
    const existingParams = [reservation_date, reservation_time];
    if (place_id) {
      existingQuery += ' AND place_id = ?';
      existingParams.push(place_id);
    }

    const [existing] = await connection.execute(existingQuery, existingParams);

    const [slot] = await connection.execute(
      'SELECT max_capacity FROM time_slots WHERE slot_time = ?',
      [reservation_time]
    );

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

    // Créer la réservation (inclure place_id si fourni)
    const [result] = await connection.execute(
      'INSERT INTO reservations (user_id, reservation_date, reservation_time, guests, notes, place_id) VALUES (?, ?, ?, ?, ?, ?)',
      [req.userId, reservation_date, reservation_time, guests, notes || null, place_id || null]
    );

    await connection.end();

    res.status(201).json({
      message: 'Réservation créée avec succès',
      reservationId: result.insertId
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Récupérer les réservations de l'utilisateur
app.get('/api/reservations', authMiddleware, async (req, res) => {
  try {
    const connection = await mysql.createConnection(dbConfig);
    const { place_id } = req.query;

    let query = 'SELECT * FROM reservations WHERE user_id = ?';
    let params = [req.userId];

    // If place_id provided, filter by it (for client's own reservations)
    if (place_id) {
      query += ' AND place_id = ?';
      params.push(place_id);
    }

    // Si c'est un hôte ou admin, afficher toutes les réservations (optionnellement filtrer par place)
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
});

// Modifier une réservation
app.put('/api/reservations/:id', authMiddleware, async (req, res) => {
  const { id } = req.params;
  const { reservation_date, reservation_time, guests, notes } = req.body;

  try {
    const connection = await mysql.createConnection(dbConfig);
    
    // Vérifier que la réservation appartient à l'utilisateur
    const [existing] = await connection.execute(
      'SELECT * FROM reservations WHERE id = ? AND user_id = ?',
      [id, req.userId]
    );

    if (existing.length === 0) {
      await connection.end();
      return res.status(404).json({ error: 'Réservation non trouvée' });
    }

    await connection.execute(
      'UPDATE reservations SET reservation_date = ?, reservation_time = ?, guests = ?, notes = ? WHERE id = ?',
      [reservation_date, reservation_time, guests, notes || null, id]
    );

    await connection.end();

    res.json({ message: 'Réservation modifiée avec succès' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Annuler une réservation
app.delete('/api/reservations/:id', authMiddleware, async (req, res) => {
  const { id } = req.params;

  try {
    const connection = await mysql.createConnection(dbConfig);
    
    const [existing] = await connection.execute(
      'SELECT * FROM reservations WHERE id = ? AND user_id = ?',
      [id, req.userId]
    );

    if (existing.length === 0) {
      await connection.end();
      return res.status(404).json({ error: 'Réservation non trouvée' });
    }

    await connection.execute(
      'UPDATE reservations SET status = "cancelled" WHERE id = ?',
      [id]
    );

    await connection.end();

    res.json({ message: 'Réservation annulée avec succès' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Valider/Refuser une réservation (hôte uniquement)
app.patch('/api/reservations/:id/status', authMiddleware, async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  if (req.userRole !== 'host' && req.userRole !== 'admin') {
    return res.status(403).json({ error: 'Accès interdit' });
  }

  if (!['confirmed', 'cancelled'].includes(status)) {
    return res.status(400).json({ error: 'Statut invalide' });
  }

  try {
    const connection = await mysql.createConnection(dbConfig);
    
    await connection.execute(
      'UPDATE reservations SET status = ? WHERE id = ?',
      [status, id]
    );

    await connection.end();

    res.json({ message: 'Statut mis à jour' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Vérifier la disponibilité
app.get('/api/availability', async (req, res) => {
  const { date, time } = req.query;

  if (!date || !time) {
    return res.status(400).json({ error: 'Date et heure requises' });
  }

  try {
    const connection = await mysql.createConnection(dbConfig);
    
    const { place_id } = req.query;

    const [slot] = await connection.execute(
      'SELECT max_capacity FROM time_slots WHERE slot_time = ?',
      [time]
    );

    if (slot.length === 0) {
      await connection.end();
      return res.status(400).json({ error: 'Créneau invalide' });
    }

    // If place_id provided, count reservations only for that place
    let reservationsQuery = 'SELECT SUM(guests) as total_guests FROM reservations WHERE reservation_date = ? AND reservation_time = ? AND status != "cancelled"';
    const reservationsParams = [date, time];
    if (place_id) {
      reservationsQuery += ' AND place_id = ?';
      reservationsParams.push(place_id);
    }

    const [reservations] = await connection.execute(reservationsQuery, reservationsParams);

    await connection.end();

    const totalGuests = reservations[0].total_guests || 0;
    const available = slot[0].max_capacity - totalGuests;

    res.json({
      maxCapacity: slot[0].max_capacity,
      reserved: totalGuests,
      available
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// --- PLACES (branches) CRUD ---

// Récupérer toutes les places
app.get('/api/places', async (req, res) => {
  try {
    const connection = await mysql.createConnection(dbConfig);
    const [places] = await connection.execute('SELECT * FROM places ORDER BY name');
    await connection.end();
    res.json(places);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Récupérer une place
app.get('/api/places/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute('SELECT * FROM places WHERE id = ?', [id]);
    await connection.end();
    if (rows.length === 0) return res.status(404).json({ error: 'Place non trouvée' });
    res.json(rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Créer une place (admin uniquement)
app.post('/api/places', authMiddleware, async (req, res) => {
  if (req.userRole !== 'admin') return res.status(403).json({ error: 'Accès interdit' });
  const { name, address, phone, capacity } = req.body;
  if (!name) return res.status(400).json({ error: 'Nom requis' });
  try {
    const connection = await mysql.createConnection(dbConfig);
    const [result] = await connection.execute(
      'INSERT INTO places (name, address, phone, capacity) VALUES (?, ?, ?, ?)',
      [name, address || null, phone || null, capacity || 50]
    );
    await connection.end();
    res.status(201).json({ message: 'Place créée', placeId: result.insertId });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Modifier une place (admin uniquement)
app.put('/api/places/:id', authMiddleware, async (req, res) => {
  if (req.userRole !== 'admin') return res.status(403).json({ error: 'Accès interdit' });
  const { id } = req.params;
  const { name, address, phone, capacity } = req.body;
  try {
    const connection = await mysql.createConnection(dbConfig);
    await connection.execute(
      'UPDATE places SET name = ?, address = ?, phone = ?, capacity = ? WHERE id = ?',
      [name, address || null, phone || null, capacity || 50, id]
    );
    await connection.end();
    res.json({ message: 'Place mise à jour' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Supprimer une place (admin uniquement)
app.delete('/api/places/:id', authMiddleware, async (req, res) => {
  if (req.userRole !== 'admin') return res.status(403).json({ error: 'Accès interdit' });
  const { id } = req.params;
  try {
    const connection = await mysql.createConnection(dbConfig);
    await connection.execute('DELETE FROM places WHERE id = ?', [id]);
    await connection.end();
    res.json({ message: 'Place supprimée' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Récupérer les créneaux horaires
app.get('/api/time-slots', async (req, res) => {
  try {
    const connection = await mysql.createConnection(dbConfig);
    const [slots] = await connection.execute('SELECT * FROM time_slots ORDER BY slot_time');
    await connection.end();
    res.json(slots);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur http://localhost:${PORT}`);
});
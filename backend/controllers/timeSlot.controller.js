const { getConnection } = require('../db');

exports.listTimeSlots = async (req, res) => {
  try {
    const connection = await getConnection();
    const [slots] = await connection.execute('SELECT * FROM time_slots ORDER BY slot_time');
    await connection.end();
    res.json(slots);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.checkAvailability = async (req, res) => {
  const { date, time } = req.query;
  if (!date || !time) return res.status(400).json({ error: 'Date et heure requises' });

  try {
    const connection = await getConnection();
    const { place_id } = req.query;

    const [slot] = await connection.execute('SELECT max_capacity FROM time_slots WHERE slot_time = ?', [time]);
    if (slot.length === 0) {
      await connection.end();
      return res.status(400).json({ error: 'Créneau invalide' });
    }

    let reservationsQuery = 'SELECT SUM(guests) as total_guests FROM reservations WHERE reservation_date = ? AND reservation_time = ? AND status NOT IN ("cancelled", "rejected")';
    const reservationsParams = [date, time];
    if (place_id) {
      reservationsQuery += ' AND place_id = ?';
      reservationsParams.push(place_id);
    }

    const [reservations] = await connection.execute(reservationsQuery, reservationsParams);
    await connection.end();

    const totalGuests = reservations[0].total_guests || 0;
    const available = slot[0].max_capacity - totalGuests;

    res.json({ maxCapacity: slot[0].max_capacity, reserved: totalGuests, available });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

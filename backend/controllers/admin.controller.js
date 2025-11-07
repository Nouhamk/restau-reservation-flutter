const { getConnection } = require('../db');

exports.getStats = async (req, res) => {
  // Only host or admin can access
  if (req.userRole !== 'admin' && req.userRole !== 'host') {
    return res.status(403).json({ error: 'Accès interdit' });
  }

  try {
    const connection = await getConnection();

    const [placesRows] = await connection.execute('SELECT COUNT(*) AS count FROM places');
    const [clientsRows] = await connection.execute("SELECT COUNT(*) AS count FROM users WHERE role = 'client'");
    const [hostsRows] = await connection.execute("SELECT COUNT(*) AS count FROM users WHERE role = 'host'");
    const [reservationsRows] = await connection.execute('SELECT COUNT(*) AS count FROM reservations');

    await connection.end();

    const stats = {
      restaurants: (placesRows[0] && placesRows[0].count) ? Number(placesRows[0].count) : 0,
      clients: (clientsRows[0] && clientsRows[0].count) ? Number(clientsRows[0].count) : 0,
      hosts: (hostsRows[0] && hostsRows[0].count) ? Number(hostsRows[0].count) : 0,
      reservations: (reservationsRows[0] && reservationsRows[0].count) ? Number(reservationsRows[0].count) : 0,
    };

    return res.json(stats);
  } catch (error) {
    console.error('Error fetching admin stats:', error);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
};

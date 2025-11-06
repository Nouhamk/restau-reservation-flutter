const { getConnection } = require('../db');

exports.getMenu = async (req, res) => {
  try {
    const connection = await getConnection();
    const [items] = await connection.execute('SELECT * FROM menu_items WHERE available = TRUE ORDER BY category, name');
    await connection.end();
    res.json(items);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

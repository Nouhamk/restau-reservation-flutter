const { getConnection } = require('../db');

exports.listPlaces = async (req, res) => {
  try {
    const connection = await getConnection();
    const [places] = await connection.execute('SELECT * FROM places ORDER BY name');
    await connection.end();
    res.json(places);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.getPlace = async (req, res) => {
  const { id } = req.params;
  try {
    const connection = await getConnection();
    const [rows] = await connection.execute('SELECT * FROM places WHERE id = ?', [id]);
    await connection.end();
    if (rows.length === 0) return res.status(404).json({ error: 'Place non trouvée' });
    res.json(rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.createPlace = async (req, res) => {
  if (req.userRole !== 'admin') return res.status(403).json({ error: 'Accès interdit' });
  const { name, address, phone, capacity } = req.body;
  if (!name) return res.status(400).json({ error: 'Nom requis' });
  try {
    const connection = await getConnection();
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
};

exports.updatePlace = async (req, res) => {
  if (req.userRole !== 'admin') return res.status(403).json({ error: 'Accès interdit' });
  const { id } = req.params;
  const { name, address, phone, capacity } = req.body;
  try {
    const connection = await getConnection();
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
};

exports.deletePlace = async (req, res) => {
  if (req.userRole !== 'admin') return res.status(403).json({ error: 'Accès interdit' });
  const { id } = req.params;
  try {
    const connection = await getConnection();
    await connection.execute('DELETE FROM places WHERE id = ?', [id]);
    await connection.end();
    res.json({ message: 'Place supprimée' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

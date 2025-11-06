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

exports.getAllMenuItems = async (req, res) => {
  try {
    const connection = await getConnection();
    const [items] = await connection.execute('SELECT * FROM menu_items ORDER BY category, name');
    await connection.end();
    res.json(items);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.getMenuItem = async (req, res) => {
  const { id } = req.params;
  try {
    const connection = await getConnection();
    const [items] = await connection.execute('SELECT * FROM menu_items WHERE id = ?', [id]);
    await connection.end();
    if (items.length === 0) {
      return res.status(404).json({ error: 'Plat non trouvé' });
    }
    res.json(items[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.createMenuItem = async (req, res) => {
  // Only admin can create menu items
  if (req.userRole !== 'admin' && req.userRole !== 'host') {
    return res.status(403).json({ error: 'Accès interdit' });
  }

  const { name, description, price, category, image_url, available } = req.body;
  
  if (!name || !price || !category) {
    return res.status(400).json({ error: 'Nom, prix et catégorie requis' });
  }

  if (!['starter', 'main', 'dessert', 'drink'].includes(category)) {
    return res.status(400).json({ error: 'Catégorie invalide. Valeurs acceptées: starter, main, dessert, drink' });
  }

  try {
    const connection = await getConnection();
    const [result] = await connection.execute(
      'INSERT INTO menu_items (name, description, price, category, image_url, available) VALUES (?, ?, ?, ?, ?, ?)',
      [name, description || null, price, category, image_url || null, available !== undefined ? available : true]
    );
    await connection.end();
    res.status(201).json({ 
      message: 'Plat créé avec succès', 
      menuItemId: result.insertId 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.updateMenuItem = async (req, res) => {
  if (req.userRole !== 'admin' && req.userRole !== 'host') {
    return res.status(403).json({ error: 'Accès interdit' });
  }

  const { id } = req.params;
  const { name, description, price, category, image_url, available } = req.body;

  if (category && !['starter', 'main', 'dessert', 'drink'].includes(category)) {
    return res.status(400).json({ error: 'Catégorie invalide' });
  }

  try {
    const connection = await getConnection();
    
    // Check if item exists
    const [existing] = await connection.execute('SELECT id FROM menu_items WHERE id = ?', [id]);
    if (existing.length === 0) {
      await connection.end();
      return res.status(404).json({ error: 'Plat non trouvé' });
    }

    await connection.execute(
      'UPDATE menu_items SET name = ?, description = ?, price = ?, category = ?, image_url = ?, available = ? WHERE id = ?',
      [
        name, 
        description || null, 
        price, 
        category, 
        image_url || null, 
        available !== undefined ? available : true, 
        id
      ]
    );
    await connection.end();
    res.json({ message: 'Plat mis à jour avec succès' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.deleteMenuItem = async (req, res) => {
  if (req.userRole !== 'admin') {
    return res.status(403).json({ error: 'Accès interdit - Admin uniquement' });
  }

  const { id } = req.params;
  
  try {
    const connection = await getConnection();
    const [result] = await connection.execute('DELETE FROM menu_items WHERE id = ?', [id]);
    await connection.end();
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Plat non trouvé' });
    }
    
    res.json({ message: 'Plat supprimé avec succès' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.toggleAvailability = async (req, res) => {
  if (req.userRole !== 'admin' && req.userRole !== 'host') {
    return res.status(403).json({ error: 'Accès interdit' });
  }

  const { id } = req.params;
  const { available } = req.body;

  if (available === undefined) {
    return res.status(400).json({ error: 'Le champ "available" est requis' });
  }

  try {
    const connection = await getConnection();
    const [result] = await connection.execute(
      'UPDATE menu_items SET available = ? WHERE id = ?',
      [available, id]
    );
    await connection.end();

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Plat non trouvé' });
    }

    res.json({ 
      message: available ? 'Plat disponible' : 'Plat indisponible',
      available 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

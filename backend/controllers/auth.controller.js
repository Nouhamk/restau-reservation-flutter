const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { getConnection } = require('../db');
const dotenv = require('dotenv');

dotenv.config();
const JWT_SECRET = process.env.JWT_SECRET || 'votre_secret_jwt';

exports.register = async (req, res) => {
  const { email, password, name, phone } = req.body;
  console.log('📝 Registration attempt:', { email, name, phone });
  
  if (!email || !password || !name) {
    console.log('❌ Registration failed: Missing required fields');
    return res.status(400).json({ error: 'Champs obligatoires manquants' });
  }

  try {
    const connection = await getConnection();
    const [existing] = await connection.execute('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      await connection.end();
      console.log('❌ Registration failed: Email already exists -', email);
      return res.status(400).json({ error: 'Email déjà utilisé' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const [result] = await connection.execute(
      'INSERT INTO users (email, password, name, phone, role) VALUES (?, ?, ?, ?, ?)',
      [email, hashedPassword, name, phone || null, 'client']
    );
    await connection.end();

    console.log('✅ User registered successfully:', { userId: result.insertId, email, role: 'client' });
    res.status(201).json({ message: 'Inscription réussie', userId: result.insertId });
  } catch (error) {
    console.error('💥 Registration error:', error.message);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.login = async (req, res) => {
  const { email, password } = req.body;
  console.log('🔐 Login attempt:', { email });
  
  if (!email || !password) {
    console.log('❌ Login failed: Missing credentials');
    return res.status(400).json({ error: 'Email et mot de passe requis' });
  }

  try {
    const connection = await getConnection();
    const [users] = await connection.execute('SELECT id, email, password, name, role FROM users WHERE email = ?', [email]);
    await connection.end();

    if (users.length === 0) {
      console.log('❌ Login failed: User not found -', email);
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    const user = users[0];
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      console.log('❌ Login failed: Invalid password for', email);
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: '24h' });

    console.log('✅ Login successful:', { userId: user.id, email: user.email, role: user.role });
    res.json({ token, user: { id: user.id, email: user.email, name: user.name, role: user.role } });
  } catch (error) {
    console.error('💥 Login error:', error.message);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

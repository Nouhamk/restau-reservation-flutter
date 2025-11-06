const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');

dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET || 'votre_secret_jwt';

module.exports = async function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    console.log('🔒 Auth failed: No token provided for', req.method, req.originalUrl);
    return res.status(401).json({ error: 'Token manquant' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.userId;
    req.userRole = decoded.role;
    
    console.log('🔓 Auth successful:', { 
      userId: decoded.userId, 
      role: decoded.role, 
      route: req.originalUrl 
    });
    
    next();
  } catch (error) {
    console.log('🔒 Auth failed: Invalid token for', req.method, req.originalUrl, '-', error.message);
    res.status(401).json({ error: 'Token invalide' });
  }
};

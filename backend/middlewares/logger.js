const morgan = require('morgan');

// Custom token for response time in ms
morgan.token('response-time-ms', (req, res) => {
  if (!req._startTime) return '-';
  const diff = process.hrtime(req._startTime);
  const ms = diff[0] * 1e3 + diff[1] * 1e-6;
  return ms.toFixed(2);
});

// Custom token for request body (sanitized)
morgan.token('body', (req) => {
  if (!req.body || Object.keys(req.body).length === 0) return '-';
  
  // Clone and sanitize sensitive data
  const sanitized = { ...req.body };
  if (sanitized.password) sanitized.password = '***HIDDEN***';
  if (sanitized.token) sanitized.token = '***HIDDEN***';
  
  return JSON.stringify(sanitized);
});

// Custom token for user info from JWT
morgan.token('user', (req) => {
  if (req.userId && req.userRole) {
    return `[User:${req.userId}|${req.userRole}]`;
  }
  return '[Guest]';
});

// Custom format with colors and detailed info
const customFormat = (tokens, req, res) => {
  const status = tokens.status(req, res);
  const statusColor = status >= 500 ? '\x1b[31m' : // red
                      status >= 400 ? '\x1b[33m' : // yellow
                      status >= 300 ? '\x1b[36m' : // cyan
                      status >= 200 ? '\x1b[32m' : // green
                      '\x1b[0m'; // default

  return [
    '\x1b[90m' + tokens.date(req, res, 'iso') + '\x1b[0m', // gray timestamp
    statusColor + tokens.method(req, res) + '\x1b[0m',
    '\x1b[36m' + tokens.url(req, res) + '\x1b[0m', // cyan URL
    statusColor + tokens.status(req, res) + '\x1b[0m',
    '\x1b[35m' + tokens['response-time-ms'](req, res) + 'ms\x1b[0m', // magenta time
    '\x1b[90m' + tokens.user(req, res) + '\x1b[0m', // gray user info
    tokens.body(req, res) !== '-' ? '\x1b[90mBody: ' + tokens.body(req, res) + '\x1b[0m' : ''
  ].filter(Boolean).join(' ');
};

// Development logger with detailed info
const devLogger = morgan(customFormat);

// Production logger - standard Apache format
const prodLogger = morgan('combined');

// Request logger middleware that logs incoming requests
const requestLogger = (req, res, next) => {
  req._startTime = process.hrtime();
  
  // Log incoming request
  console.log('\n🔵 Incoming Request:', {
    timestamp: new Date().toISOString(),
    method: req.method,
    url: req.originalUrl,
    ip: req.ip || req.connection.remoteAddress,
    userAgent: req.get('user-agent'),
    body: req.body && Object.keys(req.body).length > 0 ? 
          JSON.stringify({ ...req.body, password: req.body.password ? '***' : undefined }).substring(0, 200) : 
          'No body'
  });
  
  next();
};

// Response logger middleware
const responseLogger = (req, res, next) => {
  const originalSend = res.send;
  
  res.send = function(data) {
    // Log response
    const responseTime = req._startTime ? 
      (() => {
        const diff = process.hrtime(req._startTime);
        return (diff[0] * 1e3 + diff[1] * 1e-6).toFixed(2);
      })() : '-';
    
    const statusColor = res.statusCode >= 500 ? '🔴' :
                       res.statusCode >= 400 ? '🟡' :
                       res.statusCode >= 300 ? '🟣' :
                       res.statusCode >= 200 ? '🟢' : '⚪';
    
    console.log(`${statusColor} Response:`, {
      timestamp: new Date().toISOString(),
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      responseTime: responseTime + 'ms',
      user: req.userId ? `User:${req.userId}(${req.userRole})` : 'Guest',
      responseSize: data ? (typeof data === 'string' ? data.length : JSON.stringify(data).length) + ' bytes' : '0 bytes'
    });
    
    originalSend.call(this, data);
  };
  
  next();
};

// Error logger
const errorLogger = (err, req, res, next) => {
  console.error('❌ Error occurred:', {
    timestamp: new Date().toISOString(),
    method: req.method,
    url: req.originalUrl,
    error: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    user: req.userId ? `User:${req.userId}(${req.userRole})` : 'Guest'
  });
  
  next(err);
};

module.exports = {
  devLogger,
  prodLogger,
  requestLogger,
  responseLogger,
  errorLogger
};

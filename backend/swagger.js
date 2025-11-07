const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Restaurant Reservation API',
      version: '1.0.0',
      description: 'API REST pour l\'application de réservation de restaurant avec gestion multi-branches',
      contact: {
        name: 'Restaurant Reservation Team',
        email: 'support@restaurant-reservation.com'
      },
      license: {
        name: 'ISC',
        url: 'https://opensource.org/licenses/ISC'
      }
    },
    servers: [
      {
        url: 'https://restau-api.67gigs.codes',
        description: 'Serveur de production'
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Entrez votre token JWT obtenu après connexion'
        }
      },
      schemas: {
        User: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            email: { type: 'string', format: 'email', example: 'user@example.com' },
            name: { type: 'string', example: 'John Doe' },
            phone: { type: 'string', example: '0123456789' },
            role: { type: 'string', enum: ['client', 'host', 'admin'], example: 'client' },
            created_at: { type: 'string', format: 'date-time' }
          }
        },
        Reservation: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            user_id: { type: 'integer', example: 1 },
            reservation_date: { type: 'string', format: 'date', example: '2025-11-15' },
            reservation_time: { type: 'string', format: 'time', example: '19:00:00' },
            guests: { type: 'integer', minimum: 1, example: 4 },
            status: { type: 'string', enum: ['pending', 'confirmed', 'rejected', 'cancelled'], example: 'pending' },
            notes: { type: 'string', example: 'Fenêtre si possible' },
            place_id: { type: 'integer', nullable: true, example: 1 },
            created_at: { type: 'string', format: 'date-time' },
            updated_at: { type: 'string', format: 'date-time' }
          }
        },
        Place: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            name: { type: 'string', example: 'Restaurant Centre-Ville' },
            address: { type: 'string', example: '123 Rue Principale, Paris' },
            phone: { type: 'string', example: '0123456789' },
            capacity: { type: 'integer', example: 50 },
            created_at: { type: 'string', format: 'date-time' }
          }
        },
        MenuItem: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            name: { type: 'string', example: 'Salade César' },
            description: { type: 'string', example: 'Salade verte avec poulet grillé' },
            price: { type: 'number', format: 'decimal', example: 12.50 },
            category: { type: 'string', enum: ['starter', 'main', 'dessert', 'drink'], example: 'starter' },
            image_url: { type: 'string', format: 'uri', example: 'https://example.com/images/cesar.jpg' },
            available: { type: 'boolean', example: true },
            created_at: { type: 'string', format: 'date-time' }
          }
        },
        TimeSlot: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            slot_time: { type: 'string', format: 'time', example: '19:00:00' },
            max_capacity: { type: 'integer', example: 50 }
          }
        },
        Error: {
          type: 'object',
          properties: {
            error: { type: 'string', example: 'Message d\'erreur' }
          }
        },
        Success: {
          type: 'object',
          properties: {
            message: { type: 'string', example: 'Opération réussie' }
          }
        }
      },
      responses: {
        UnauthorizedError: {
          description: 'Token JWT manquant ou invalide',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: { error: 'Token manquant' }
            }
          }
        },
        ForbiddenError: {
          description: 'Accès interdit - Permissions insuffisantes',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: { error: 'Accès interdit' }
            }
          }
        },
        NotFoundError: {
          description: 'Ressource non trouvée',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: { error: 'Ressource non trouvée' }
            }
          }
        },
        ValidationError: {
          description: 'Erreur de validation des données',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: { error: 'Champs obligatoires manquants' }
            }
          }
        },
        ServerError: {
          description: 'Erreur serveur interne',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: { error: 'Erreur serveur' }
            }
          }
        }
      }
    },
    tags: [
      {
        name: 'Authentication',
        description: 'Inscription et connexion des utilisateurs'
      },
      {
        name: 'Reservations',
        description: 'Gestion des réservations (création, modification, validation)'
      },
      {
        name: 'Places',
        description: 'Gestion des branches/lieux du restaurant'
      },
      {
        name: 'Menu',
        description: 'Consultation du menu'
      },
      {
        name: 'Time Slots',
        description: 'Créneaux horaires et disponibilités'
      }
    ]
  },
  apis: ['./routes/*.js', './controllers/*.js'] // Fichiers contenant les annotations JSDoc
};

const swaggerSpec = swaggerJsdoc(options);

module.exports = swaggerSpec;

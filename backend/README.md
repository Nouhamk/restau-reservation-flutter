# Backend - Restaurant Reservation API

API REST pour l'application de réservation de restaurant.

## 📁 Structure du projet

```
backend/
├── controllers/          # Logique métier
│   ├── auth.controller.js
│   ├── menu.controller.js
│   ├── place.controller.js
│   ├── reservation.controller.js
│   └── timeSlot.controller.js
├── routes/              # Définition des routes
│   ├── auth.route.js
│   ├── menu.route.js
│   ├── places.route.js
│   ├── reservations.route.js
│   └── timeSlots.route.js
├── middlewares/         # Middlewares personnalisés
│   └── auth.js          # Authentification JWT
├── services/            # Services réutilisables
│   └── notification.service.js  # Notifications (Firebase)
├── db.js               # Configuration base de données
├── server.js           # Point d'entrée
└── .env                # Variables d'environnement
```

## 🚀 Installation

```bash
cd backend
npm install
```

## ⚙️ Configuration

Créer un fichier `.env` à partir de `.env.example`:

```bash
cp .env.example .env
```

Variables requises:
```env
JWT_SECRET=votre_secret_jwt_très_sécurisé
DB_URL=mysql://user:password@host:port/database
PORT=3000
```

## 🏃 Démarrage

```bash
npm start
```

Le serveur démarre sur `http://localhost:3000`

## 📚 Documentation API (Swagger)

Une documentation interactive complète est disponible via Swagger UI :

```
http://localhost:3000/api-docs
```

**Fonctionnalités :**
- 📖 Explorez tous les endpoints
- 🧪 Testez directement depuis le navigateur
- 🔐 Authentification JWT intégrée
- 📋 Schémas et exemples complets

**Voir le guide complet :** [`SWAGGER_GUIDE.md`](./SWAGGER_GUIDE.md)

## 📡 Endpoints API

### Authentification

| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| POST | `/api/register` | Inscription | - |
| POST | `/api/login` | Connexion | - |

### Réservations

| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| POST | `/api/reservations` | Créer une réservation | Client |
| GET | `/api/reservations` | Liste des réservations | Client/Host/Admin |
| PUT | `/api/reservations/:id` | Modifier une réservation | Client |
| DELETE | `/api/reservations/:id` | Annuler une réservation | Client |
| PATCH | `/api/reservations/:id/status` | Valider/Refuser | **Host/Admin** |

### Places (Branches)

| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/api/places` | Liste des places | - |
| GET | `/api/places/:id` | Détails d'une place | - |
| POST | `/api/places` | Créer une place | **Admin** |
| PUT | `/api/places/:id` | Modifier une place | **Admin** |
| DELETE | `/api/places/:id` | Supprimer une place | **Admin** |

### Menu

| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/api/menu` | Liste des plats disponibles | - |
| GET | `/api/menu/all` | Tous les plats (disponibles + indisponibles) | Host/Admin |
| GET | `/api/menu/:id` | Détails d'un plat | - |
| POST | `/api/menu` | Créer un plat | **Host/Admin** |
| PUT | `/api/menu/:id` | Modifier un plat | **Host/Admin** |
| DELETE | `/api/menu/:id` | Supprimer un plat | **Admin** |
| PATCH | `/api/menu/:id/availability` | Activer/Désactiver un plat | **Host/Admin** |

### Créneaux horaires

| Méthode | Route | Description | Auth |
|---------|-------|-------------|------|
| GET | `/api/time-slots` | Liste des créneaux | - |
| GET | `/api/time-slots/availability` | Vérifier disponibilité | - |

## 🔐 Authentification

L'API utilise JWT (JSON Web Tokens). Après connexion, incluez le token dans les headers:

```http
Authorization: Bearer YOUR_JWT_TOKEN
```

### Rôles

- `client`: Utilisateur normal (peut créer/modifier ses réservations)
- `host`: Hôte (peut voir toutes les réservations, valider/refuser, gérer le menu)
- `admin`: Administrateur (tous les droits + gestion des places)

## 📝 Exemples d'utilisation

### 1. Inscription
```bash
curl -X POST http://localhost:3000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "client@example.com",
    "password": "password123",
    "name": "John Doe",
    "phone": "0123456789"
  }'
```

### 2. Connexion
```bash
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "client@example.com",
    "password": "password123"
  }'
```

### 3. Créer une réservation
```bash
curl -X POST http://localhost:3000/api/reservations \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "reservation_date": "2025-11-15",
    "reservation_time": "19:00:00",
    "guests": 4,
    "place_id": 1,
    "notes": "Fenêtre si possible"
  }'
```

### 4. Valider une réservation (Hôte)
```bash
curl -X PATCH http://localhost:3000/api/reservations/123/status \
  -H "Authorization: Bearer HOST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "confirmed"}'
```

### 5. Refuser une réservation (Hôte)
```bash
curl -X PATCH http://localhost:3000/api/reservations/123/status \
  -H "Authorization: Bearer HOST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "rejected"}'
```

### 6. Vérifier la disponibilité
```bash
curl "http://localhost:3000/api/availability?date=2025-11-15&time=19:00:00&place_id=1"
```

### 7. Ajouter un plat au menu (Host/Admin)
```bash
curl -X POST http://localhost:3000/api/menu \
  -H "Authorization: Bearer HOST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Salade César",
    "description": "Salade verte avec poulet grillé et parmesan",
    "price": 12.50,
    "category": "starter",
    "image_url": "https://example.com/cesar.jpg",
    "available": true
  }'
```

### 8. Désactiver un plat temporairement (Host/Admin)
```bash
curl -X PATCH http://localhost:3000/api/menu/5/availability \
  -H "Authorization: Bearer HOST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"available": false}'
```

## 🧪 Tests

### Tests manuels
```bash
# Tester la validation/refus de réservations
./test_reservation_status.sh YOUR_JWT_TOKEN
```

### Tests automatisés (à venir)
```bash
npm test
```

## 📊 Statuts de réservation

| Statut | Description | Compte dans capacité? |
|--------|-------------|-----------------------|
| `pending` | En attente de validation | ✅ Oui |
| `confirmed` | Validée par l'hôte | ✅ Oui |
| `rejected` | Refusée par l'hôte | ❌ Non |
| `cancelled` | Annulée | ❌ Non |

## 🔧 Dépendances principales

```json
{
  "express": "^5.1.0",
  "mysql2": "^3.15.3",
  "bcryptjs": "^3.0.3",
  "jsonwebtoken": "^9.0.2",
  "cors": "^2.8.5",
  "dotenv": "^17.2.3"
}
```

## 🎁 Fonctionnalités bonus

### Notifications Firebase (à activer)

Le service de notification est préparé mais nécessite configuration:

1. Installer Firebase Admin SDK:
   ```bash
   npm install firebase-admin
   ```

2. Configurer Firebase (voir `services/notification.service.js`)

3. Ajouter colonne `fcm_token` dans la table `users`

4. Décommenter le code Firebase

Documentation complète: `docs/USER_STORY_VALIDATION_RESERVATIONS.md`

## 🗄️ Base de données

Voir `database/init.sql` pour le schéma complet.

### Migrations

```bash
# Appliquer une migration
mysql -u user -p database < database/migrations/001_add_rejected_status.sql
```

## 📚 Documentation

- [`docs/USER_STORY_VALIDATION_RESERVATIONS.md`](../docs/USER_STORY_VALIDATION_RESERVATIONS.md) - Validation/refus réservations
- [`docs/IMPLEMENTATION_SUMMARY.md`](../docs/IMPLEMENTATION_SUMMARY.md) - Résumé de l'implémentation

## 🐳 Docker

```bash
# Build
docker build -t resto-api .

# Run
docker run -p 3000:3000 --env-file .env resto-api
```

## 🤝 Contribution

Architecture suivie:
- **Controllers**: Logique métier
- **Routes**: Définition des endpoints
- **Middlewares**: Authentification, validation
- **Services**: Fonctionnalités transversales (notifications, email, etc.)

## 📄 Licence

ISC

---

**Développé avec ❤️ pour le projet Restaurant Reservation**

# 📚 Swagger API Documentation

## 🚀 Accès à la documentation

Une fois le serveur démarré, accédez à la documentation interactive Swagger UI :

```
http://localhost:3000/api-docs
```

## 🎯 Fonctionnalités

### Interface interactive
- **Explorez tous les endpoints** : Voir tous les endpoints disponibles organisés par catégories (Authentication, Reservations, Places, Menu, Time Slots)
- **Testez directement** : Exécutez des requêtes API directement depuis l'interface
- **Schémas détaillés** : Voir les structures de données pour chaque requête et réponse
- **Exemples** : Valeurs d'exemple pour tous les champs

### Authentification dans Swagger

Pour tester les endpoints protégés :

1. **Connectez-vous** via `/api/login`
2. **Copiez le token JWT** de la réponse
3. **Cliquez sur "Authorize"** 🔒 en haut de la page
4. **Entrez** : `Bearer YOUR_TOKEN_HERE`
5. **Validez** : Tous les appels suivants incluront le token

## 📋 Endpoints disponibles

### 🔐 Authentication
- `POST /api/register` - Inscription
- `POST /api/login` - Connexion

### 📝 Reservations
- `POST /api/reservations` - Créer une réservation
- `GET /api/reservations` - Liste des réservations
- `PUT /api/reservations/{id}` - Modifier une réservation
- `DELETE /api/reservations/{id}` - Annuler une réservation
- `PATCH /api/reservations/{id}/status` - Valider/Refuser (Host/Admin)

### 🏢 Places
- `GET /api/places` - Liste des lieux
- `GET /api/places/{id}` - Détails d'un lieu
- `POST /api/places` - Créer un lieu (Admin)
- `PUT /api/places/{id}` - Modifier un lieu (Admin)
- `DELETE /api/places/{id}` - Supprimer un lieu (Admin)

### 🍽️ Menu
- `GET /api/menu` - Liste du menu

### 🕐 Time Slots
- `GET /api/time-slots` - Liste des créneaux
- `GET /api/time-slots/availability` - Vérifier disponibilité

## 🔧 Utilisation

### Exemple de workflow complet

1. **Inscription**
   ```
   POST /api/register
   Body: { "email": "test@example.com", "password": "pass123", "name": "Test User" }
   ```

2. **Connexion**
   ```
   POST /api/login
   Body: { "email": "test@example.com", "password": "pass123" }
   Response: { "token": "eyJhbGc...", "user": {...} }
   ```

3. **Autorisation**
   - Cliquez sur 🔒 "Authorize"
   - Entrez: `Bearer eyJhbGc...`

4. **Créer une réservation**
   ```
   POST /api/reservations
   Body: {
     "reservation_date": "2025-11-15",
     "reservation_time": "19:00:00",
     "guests": 4,
     "place_id": 1
   }
   ```

5. **Lister vos réservations**
   ```
   GET /api/reservations
   ```

### Tester avec différents rôles

**Client (par défaut)**
- Peut créer/modifier/annuler ses propres réservations
- Voir uniquement ses réservations

**Host** (modifier le rôle en DB : `UPDATE users SET role='host' WHERE id=X`)
- Voir toutes les réservations
- Valider/Refuser des réservations
- `PATCH /api/reservations/{id}/status`

**Admin** (modifier le rôle en DB : `UPDATE users SET role='admin' WHERE id=X`)
- Tous les droits de Host
- Gérer les lieux (CRUD sur `/api/places`)

## 📱 Export de la documentation

### Format OpenAPI JSON
```
http://localhost:3000/api-docs.json
```

### Import dans d'autres outils
- **Postman** : File > Import > Paste URL `http://localhost:3000/api-docs.json`
- **Insomnia** : Import > From URL
- **VS Code REST Client** : Utiliser l'extension OpenAPI

## 🎨 Personnalisation

Le fichier `backend/swagger.js` contient toute la configuration :
- Modifier les informations de l'API
- Ajouter des serveurs (dev, staging, prod)
- Personnaliser les schémas

## 🔍 Exemples de requêtes curl

### Inscription
```bash
curl -X POST http://localhost:3000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepass123",
    "name": "John Doe",
    "phone": "0123456789"
  }'
```

### Connexion
```bash
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepass123"
  }'
```

### Créer une réservation (avec token)
```bash
curl -X POST http://localhost:3000/api/reservations \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "reservation_date": "2025-11-15",
    "reservation_time": "19:00:00",
    "guests": 4,
    "notes": "Fenêtre si possible",
    "place_id": 1
  }'
```

### Vérifier disponibilité
```bash
curl "http://localhost:3000/api/time-slots/availability?date=2025-11-15&time=19:00:00&place_id=1"
```

## 🐛 Dépannage

### Swagger UI ne s'affiche pas
1. Vérifier que le serveur est démarré
2. Vérifier l'URL : `http://localhost:3000/api-docs`
3. Vérifier les logs du serveur

### Token JWT invalide
1. Le token expire après 24h
2. Se reconnecter pour obtenir un nouveau token
3. Vérifier le format : `Bearer <token>` (avec espace)

### Erreur 403 (Accès interdit)
- Vérifier le rôle de l'utilisateur
- Certains endpoints nécessitent `host` ou `admin`

## 📦 Dépendances Swagger

```json
{
  "swagger-ui-express": "^5.0.0",
  "swagger-jsdoc": "^6.2.8"
}
```

## 🌐 Environnements

Modifier `backend/swagger.js` pour ajouter vos environnements :

```javascript
servers: [
  {
    url: 'http://localhost:3000',
    description: 'Développement local'
  },
]
```

## 🎓 Ressources

- [Swagger UI Documentation](https://swagger.io/tools/swagger-ui/)
- [OpenAPI Specification](https://swagger.io/specification/)
- [swagger-jsdoc](https://github.com/Surnet/swagger-jsdoc)

---

**Profitez de votre documentation API interactive! 🎉**

# Documentation API

API REST pour la gestion des reservations de restaurant avec systeme multi-branches.

## Base URL

```
https://restau-api.67gigs.codes/api
```

## Documentation Swagger

La documentation interactive Swagger est disponible a l''adresse :
[https://restau-api.67gigs.codes/api-docs](https://restau-api.67gigs.codes/api-docs/#/)

---

## Authentication

Endpoints pour l''inscription et la connexion des utilisateurs.

### POST /register
Inscription d''un nouvel utilisateur

**Body:**
```json
{
  "email": "user@example.com",
  "password": "motdepasse123",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "0612345678",
  "role": "client"
}
```

**Roles disponibles:** `client`, `host`, `admin`

**Reponse:**
```json
{
  "message": "Utilisateur cree avec succes",
  "userId": 1
}
```

---

### POST /login
Connexion d''un utilisateur

**Body:**
```json
{
  "email": "user@example.com",
  "password": "motdepasse123"
}
```

**Reponse:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "client"
  }
}
```

---

## Reservations

Gestion complete des reservations (creation, modification, validation).

### POST /reservations
Creer une nouvelle reservation

**Headers:** `Authorization: Bearer <token>`

**Body:**
```json
{
  "placeId": 1,
  "date": "2025-11-15",
  "timeSlotId": 3,
  "numberOfGuests": 4,
  "specialRequests": "Table pres de la fenetre"
}
```

**Reponse:**
```json
{
  "message": "Reservation creee avec succes",
  "reservationId": 10
}
```

---

### GET /reservations
Liste des reservations

**Headers:** `Authorization: Bearer <token>`

**Permissions:**
- **Client:** Voit uniquement ses propres reservations
- **Host:** Voit toutes les reservations de son restaurant
- **Admin:** Voit toutes les reservations

**Reponse:**
```json
[
  {
    "id": 10,
    "userId": 1,
    "placeId": 1,
    "placeName": "Les AL - Covent Garden",
    "date": "2025-11-15",
    "timeSlot": "19:00",
    "numberOfGuests": 4,
    "status": "pending",
    "specialRequests": "Table pres de la fenetre",
    "createdAt": "2025-11-07T10:30:00Z"
  }
]
```

---

### PUT /reservations/:id
Modifier une reservation existante

**Headers:** `Authorization: Bearer <token>`

**Permissions:** Client (ses reservations uniquement) ou Host/Admin

**Body:**
```json
{
  "date": "2025-11-16",
  "timeSlotId": 5,
  "numberOfGuests": 6,
  "specialRequests": "Allergies: gluten"
}
```

**Reponse:**
```json
{
  "message": "Reservation modifiee avec succes"
}
```

---

### DELETE /reservations/:id
Annuler une reservation

**Headers:** `Authorization: Bearer <token>`

**Permissions:** Client (ses reservations uniquement) ou Host/Admin

**Reponse:**
```json
{
  "message": "Reservation annulee avec succes"
}
```

---

### PATCH /reservations/:id/status
Valider ou refuser une reservation

**Headers:** `Authorization: Bearer <token>`

**Permissions:** Host ou Admin uniquement

**Body:**
```json
{
  "status": "confirmed"
}
```

**Status disponibles:** `pending`, `confirmed`, `rejected`, `completed`, `cancelled`

**Reponse:**
```json
{
  "message": "Statut de la reservation mis a jour"
}
```

---

## Places

Gestion des branches/lieux du restaurant.

### GET /places
Liste de tous les lieux/branches

**Acces:** Public (pas d''authentification requise)

**Reponse:**
```json
[
  {
    "id": 1,
    "name": "Les AL - Covent Garden",
    "address": "123 Long Acre, London WC2E 9PE",
    "phone": "+44 20 1234 5678",
    "capacity": 80,
    "openingHours": {
      "monday": "12:00-23:00",
      "tuesday": "12:00-23:00",
      "wednesday": "12:00-23:00",
      "thursday": "12:00-00:00",
      "friday": "12:00-01:00",
      "saturday": "11:00-01:00",
      "sunday": "11:00-22:00"
    },
    "isActive": true
  }
]
```

---

### POST /places
Creer un nouveau lieu

**Headers:** `Authorization: Bearer <token>`

**Permissions:** Admin uniquement

**Body:**
```json
{
  "name": "Les AL - Camden",
  "address": "45 Camden High Street, London NW1 7JH",
  "phone": "+44 20 9876 5432",
  "capacity": 60,
  "openingHours": {
    "monday": "12:00-23:00",
    "tuesday": "12:00-23:00"
  }
}
```

**Reponse:**
```json
{
  "message": "Lieu cree avec succes",
  "placeId": 2
}
```

---

### GET /places/:id
Obtenir les details d''un lieu

**Acces:** Public

**Reponse:**
```json
{
  "id": 1,
  "name": "Les AL - Covent Garden",
  "address": "123 Long Acre, London WC2E 9PE",
  "phone": "+44 20 1234 5678",
  "capacity": 80,
  "openingHours": {...},
  "description": "Pub anglais authentique au coeur de Covent Garden",
  "amenities": ["WiFi", "Terrasse", "Musique live"],
  "images": ["/images/covent-garden-1.jpg"]
}
```

---

### PUT /places/:id
Modifier un lieu

**Headers:** `Authorization: Bearer <token>`

**Permissions:** Admin uniquement

**Body:** (champs a modifier)
```json
{
  "capacity": 90,
  "phone": "+44 20 1234 9999"
}
```

---

### DELETE /places/:id
Supprimer un lieu

**Headers:** `Authorization: Bearer <token>`

**Permissions:** Admin uniquement

**Reponse:**
```json
{
  "message": "Lieu supprime avec succes"
}
```

---

## Menu

Gestion du menu et des plats.

### GET /menu
Obtenir la liste du menu (plats disponibles uniquement)

**Acces:** Public

**Reponse:**
```json
[
  {
    "id": 1,
    "name": "Fish & Chips",
    "description": "Poisson frais pane avec frites maison",
    "price": 14.50,
    "category": "Plat principal",
    "imageUrl": "/images/fish-chips.jpg",
    "isAvailable": true,
    "allergens": ["poisson", "gluten"]
  }
]
```

---

### POST /menu
Creer un nouveau plat

**Headers:** `Authorization: Bearer <token>`

**Permissions:** Host ou Admin uniquement

**Body:**
```json
{
  "name": "Beef Wellington",
  "description": "Filet de boeuf en croute feuilletee",
  "price": 24.50,
  "category": "Plat principal",
  "imageUrl": "/images/beef-wellington.jpg",
  "allergens": ["gluten", "oeuf"],
  "isAvailable": true
}
```

**Reponse:**
```json
{
  "message": "Plat cree avec succes",
  "menuItemId": 15
}
```

---

### GET /menu/all
Obtenir tous les plats (disponibles et indisponibles)

**Headers:** `Authorization: Bearer <token>`

**Permissions:** Host ou Admin uniquement

**Reponse:** Meme format que GET /menu mais inclut les plats avec `isAvailable: false`

---

### GET /menu/:id
Obtenir les details d''un plat

**Acces:** Public

**Reponse:**
```json
{
  "id": 1,
  "name": "Fish & Chips",
  "description": "Poisson frais pane avec frites maison et sauce tartare",
  "price": 14.50,
  "category": "Plat principal",
  "imageUrl": "/images/fish-chips.jpg",
  "isAvailable": true,
  "allergens": ["poisson", "gluten"],
  "nutritionalInfo": {
    "calories": 850,
    "protein": 35,
    "carbs": 78,
    "fat": 42
  }
}
```

---

### PUT /menu/:id
Modifier un plat

**Headers:** `Authorization: Bearer <token>`

**Permissions:** Host ou Admin uniquement

**Body:** (champs a modifier)
```json
{
  "price": 15.50,
  "description": "Nouvelle description"
}
```

---

### DELETE /menu/:id
Supprimer un plat

**Headers:** `Authorization: Bearer <token>`

**Permissions:** Admin uniquement

**Reponse:**
```json
{
  "message": "Plat supprime avec succes"
}
```

---

### PATCH /menu/:id/availability
Activer/Desactiver la disponibilite d''un plat

**Headers:** `Authorization: Bearer <token>`

**Permissions:** Host ou Admin uniquement

**Body:**
```json
{
  "isAvailable": false
}
```

**Reponse:**
```json
{
  "message": "Disponibilite mise a jour"
}
```

---

## Time Slots

Gestion des creneaux horaires et disponibilites.

### GET /time-slots
Liste des creneaux horaires

**Acces:** Public

**Query Parameters:**
- `placeId` (optionnel): Filtrer par lieu
- `date` (optionnel): Filtrer par date (format: YYYY-MM-DD)

**Reponse:**
```json
[
  {
    "id": 1,
    "placeId": 1,
    "time": "12:00",
    "maxCapacity": 20,
    "isActive": true
  },
  {
    "id": 2,
    "placeId": 1,
    "time": "12:30",
    "maxCapacity": 20,
    "isActive": true
  }
]
```

---

### GET /time-slots/availability
Verifier la disponibilite pour un creneau

**Acces:** Public

**Query Parameters:**
- `placeId` (requis): ID du lieu
- `date` (requis): Date de la reservation (YYYY-MM-DD)
- `timeSlotId` (requis): ID du creneau horaire
- `numberOfGuests` (requis): Nombre de personnes

**Reponse:**
```json
{
  "available": true,
  "remainingCapacity": 12,
  "timeSlot": {
    "id": 3,
    "time": "19:00",
    "maxCapacity": 20
  }
}
```

---

## Codes d''erreur

| Code | Signification |
|------|---------------|
| 200 | Requete reussie |
| 201 | Ressource creee avec succes |
| 400 | Mauvaise requete (parametres invalides) |
| 401 | Non authentifie (token manquant ou invalide) |
| 403 | Non autorise (permissions insuffisantes) |
| 404 | Ressource non trouvee |
| 409 | Conflit (ex: email deja utilise) |
| 500 | Erreur serveur |

---

## Authentification JWT

La plupart des endpoints necessitent un token JWT dans le header :

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Le token est obtenu lors de la connexion (POST /login) et est valide pendant 24 heures.

---

## Permissions par role

| Endpoint | Client | Host | Admin |
|----------|--------|------|-------|
| GET /menu |  |  |  |
| POST /menu |  |  |  |
| GET /reservations |  (ses reservations) |  (toutes) |  (toutes) |
| PATCH /reservations/:id/status |  |  |  |
| POST /places |  |  |  |
| DELETE /places/:id |  |  |  |
# Introduction

Bienvenue dans la documentation du projet **Les AL**, systeme de reservation pour pub anglais authentique.

## Description du Projet

Les AL est une application mobile de reservation de restaurant developpee dans le cadre d'un projet academique. Elle permet aux clients de reserver des tables en ligne, aux hotes de gerer les reservations et aux administrateurs de gerer l'ensemble du systeme multi-restaurants.

### Contexte

L'application simule la gestion d'une chaine de pubs anglais authentiques avec :
- **Gestion multi-branches** : Plusieurs emplacements de restaurants
- **Systeme de roles** : Client, Hote, Administrateur
- **Reservations en temps reel** : Disponibilite des creneaux horaires
- **Gestion des menus** : Consultation et administration des plats

### Architecture

Le projet suit une architecture **client-serveur** avec :
- **Frontend** : Application mobile Flutter (iOS/Android)
- **Backend** : API REST Node.js/Express
- **Base de donnees** : MySQL

---

## Instructions de Lancement

### Pre-requis

Avant de commencer, assurez-vous d'avoir installe :

- **Flutter SDK** 3.x ou superieur
- **Node.js** 20.x ou superieur
- **MySQL** 8.0 ou superieur
- **Git** pour le versioning

### 1. Cloner le Repository

```bash
git clone https://github.com/Nouhamk/restau-reservation-flutter.git
cd restau-reservation-flutter
```

### 2. Configuration de la Base de Donnees

```bash
# Se connecter a MySQL
mysql -u root -p

# Creer la base de donnees
CREATE DATABASE restaurant_db;

# Importer le schema
mysql -u root -p restaurant_db < database/init.sql
```

### 3. Lancer le Backend (API)

```bash
# Aller dans le dossier backend
cd backend

# Installer les dependances
npm install

# Lancer le serveur
npm start
```

Le serveur API sera accessible sur `https://restau-api.67gigs.codes/api`

**Configuration :** Creer un fichier `.env` dans le dossier backend :
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=votre_mot_de_passe
DB_NAME=restaurant_db
JWT_SECRET=votre_secret_jwt
PORT=3000
```

### 4. Lancer le Frontend (Flutter)

```bash
# Aller dans le dossier frontend
cd frontend

# Installer les dependances
flutter pub get

# Verifier les appareils disponibles
flutter devices

# Lancer l'application
flutter run
```

**Options de lancement :**
- `flutter run -d chrome` - Pour le web
- `flutter run -d android` - Pour Android
- `flutter run -d ios` - Pour iOS

**Configuration :** Modifier l'URL de l'API dans `lib/config/api_config.dart` :
```dart
static const String baseUrl = 'https://restau-api.67gigs.codes/api';
```

### 5. Comptes de Test

Utilisez ces comptes pour tester les differents roles :

| Role | Email | Password |
|------|-------|----------|
| **Client** | client@lesalal.com | client123 |
| **Hote** | host@lesalal.com | host123 |
| **Administrateur** | admin@lesalal.com | admin123 |


## Fonctionnalites Realisees

### Authentification et Securite
-  Inscription des utilisateurs avec validation
-  Connexion securisee avec JWT
-  Gestion des roles (Client, Hote, Admin)
-  Protection des routes selon les permissions
-  Deconnexion et gestion de session

### Pour les Clients
-  Consultation des restaurants disponibles
-  Visualisation des menus et plats
-  Recherche par categorie
-  Creation de reservations
-  Modification de reservations
-  Annulation de reservations
-  Historique des reservations
-  Demandes speciales (allergies, preferences)

### Pour les Hotes
-  Tableau de bord avec statistiques
-  Visualisation des reservations du restaurant
-  Validation/Refus des reservations
-  Gestion des creneaux horaires
-  Gestion de la disponibilite des plats
-  Vue calendrier
-  Notifications en temps reel

### Pour les Administrateurs
-  Tableau de bord global multi-restaurants
-  Gestion complete des restaurants (CRUD)
-  Ajout/Modification/Suppression de plats
-  Gestion des categories de menu
-  Gestion des utilisateurs et roles
-  Statistiques globales
-  Configuration des parametres

### Fonctionnalites Techniques
-  API REST complete avec documentation Swagger
-  Base de donnees relationnelle optimisee
-  Gestion des erreurs robuste
-  Validation des donnees
-  Interface responsive
-  Theme personnalise
-  Navigation basee sur les roles
-  State management avec Provider

---

## Design et Theme

L'application utilise une palette de couleurs elegante inspiree des pubs anglais :

| Couleur | Code | Usage |
|---------|------|-------|
| **Deep Navy** | #2C3E50 | Couleur principale |
| **Rose Gold** | #B76E79 | Accents chaleureux |
| **Champagne** | #D4A574 | Touches luxueuses |
| **Sage Green** | #87A878 | Elements naturels |
| **Light Background** | #FAF9F7 | Fond clair |


## Technologies Utilisees

### Frontend
- **Flutter 3.x** : Framework cross-platform
- **Dart** : Langage de programmation
- **Provider** : State management
- **HTTP** : Communication avec l'API

### Backend
- **Node.js** : Runtime JavaScript
- **Express** : Framework web minimaliste
- **MySQL2** : Driver MySQL
- **JWT** : Authentification
- **Bcrypt** : Hashage des mots de passe
- **Swagger** : Documentation API

### Base de Donnees
- **MySQL 8.0** : Base relationnelle
- **Schema normalise** : 3NF
- **Index optimises** : Performances

### Outils
- **Git/GitHub** : Versioning
- **GitHub Projects** : Board Kanban
- **VS Code** : IDE
- **Postman** : Tests API
- **VitePress** : Documentation


## Structure du Projet

```
restau-reservation-flutter/
 frontend/                    # Application Flutter
    lib/
       main.dart
       config/             # Configuration
       models/             # Modeles de donnees
       screens/            # Ecrans
       services/           # Services API
       theme/              # Theme
       widgets/            # Widgets
    pubspec.yaml

 backend/                     # API Node.js
    server.js
    controllers/            # Logique metier
    routes/                 # Routes API
    middlewares/            # Middlewares
    package.json

 database/                    # Base de donnees
    init.sql

 docs/                        # Documentation
     ...
```


## Prochaines Etapes

1. **Explorer la documentation** : Parcourez les autres pages pour plus de details
2. **Tester l'application** : Utilisez les comptes de test pour explorer les fonctionnalites
3. **Consulter l'API** : Explorez la [documentation Swagger](https://restau-api.67gigs.codes/api-docs/#/)
4. **Voir le board Kanban** : Suivez l'avancement sur [GitHub Projects](https://github.com/users/Nouhamk/projects/9/views/1)

---

## Ressources Utiles

-  [Documentation complete](/)
-  [Documentation API](/api/endpoints)
-  [Gestion des taches](/guide/gestion-taches)
-  [Gestion des roles](/guide/roles)
-  [Repository GitHub](https://github.com/Nouhamk/restau-reservation-flutter)
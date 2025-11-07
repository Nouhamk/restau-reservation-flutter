# Les AL - Systeme de Reservation de Restaurant

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Node.js](https://img.shields.io/badge/Node.js-20.x-green)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange)
![License](https://img.shields.io/badge/license-ISC-blue)

Application mobile de reservation pour pub anglais authentique avec gestion multi-branches et systeme de roles avance.

## 📋 Description du Projet

Les AL est une application de reservation de restaurant developpee dans le cadre d'un projet academique. Elle permet aux clients de reserver des tables en ligne, aux hotes de gerer les reservations et aux administrateurs de gerer l'ensemble du systeme multi-restaurants.

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

## 🚀 Instructions de Lancement

### Pre-requis

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

# Configurer les variables d'environnement
# Creer un fichier .env avec :
# DB_HOST=localhost
# DB_USER=root
# DB_PASSWORD=votre_mot_de_passe
# DB_NAME=restaurant_db
# JWT_SECRET=votre_secret_jwt
# PORT=3000

# Lancer le serveur
npm start
```

Le serveur API sera accessible sur `https://restau-api.67gigs.codes/api`

### 4. Lancer le Frontend (Flutter)

```bash
# Aller dans le dossier frontend
cd frontend

# Installer les dependances
flutter pub get

# Configurer l'URL de l'API dans lib/config/api_config.dart
# baseUrl: 'https://restau-api.67gigs.codes/api/'

# Verifier les appareils disponibles
flutter devices

# Lancer l'application
flutter run

# Ou pour un emulateur specifique :
# flutter run -d chrome          # Pour le web
# flutter run -d android         # Pour Android
# flutter run -d ios             # Pour iOS
```

### 5. Comptes de Test

Utilisez ces comptes pour tester les differents roles :

**Client :**
- Email : `test@lesAL.com`
- Password : `test123`

**Hôtes**
- Email : `host@restaurantAL.com`
- Passowrd : `securePassword123`

**Admin**
- Email : `admin@restaurantAL.com`
- Password `securePassword123`

## ✨ Fonctionnalites Realisees

### Authentification et Securite
- ✅ Inscription des utilisateurs avec validation email
- ✅ Connexion securisee avec JWT
- ✅ Gestion des roles (Client, Hote, Admin)
- ✅ Protection des routes selon les permissions
- ✅ Deconnexion et gestion de session

### Pour les Clients
- ✅ Consultation des restaurants disponibles
- ✅ Visualisation des menus et plats
- ✅ Recherche par categorie d'aliments
- ✅ Creation de reservations avec selection de creneau
- ✅ Modification de reservations existantes
- ✅ Annulation de reservations
- ✅ Historique des reservations

### Pour les Hotes
- ✅ Tableau de bord avec statistiques
- ✅ Visualisation de toutes les reservations du restaurant
- ✅ Validation/Refus des reservations
- ✅ Gestion des creneaux horaires
- ✅ Gestion de la disponibilite des plats
- ✅ Vue calendrier des reservations
- ✅ Notifications en temps reel

### Pour les Administrateurs
- ✅ Tableau de bord global multi-restaurants
- ✅ Gestion complete des restaurants (CRUD)
- ✅ Ajout/Modification/Suppression de plats
- ✅ Gestion des categories de menu
- ✅ Gestion des utilisateurs et roles
- ✅ Statistiques globales du systeme
- ✅ Configuration des parametres

### Fonctionnalites Techniques
- ✅ API REST complete avec documentation Swagger
- ✅ Base de donnees relationnelle optimisee
- ✅ Gestion des erreurs robuste
- ✅ Validation des donnees cote client et serveur
- ✅ Interface responsive et adaptive
- ✅ Theme personnalise elegant
- ✅ Navigation intuitive basee sur les roles
- ✅ Chargement asynchrone des donnees
- ✅ Gestion des etats avec Provider

## 🎨 Design et Theme

L'application utilise une palette de couleurs elegante inspiree des pubs anglais :

- **Deep Navy** (#2C3E50) : Couleur principale, sophistiquee
- **Rose Gold** (#B76E79) : Accents chaleureux
- **Champagne** (#D4A574) : Touches luxueuses
- **Sage Green** (#87A878) : Elements naturels
- **Light Background** (#FAF9F7) : Fond clair et apaisant

## 📁 Structure du Projet

```
restau-reservation-flutter/
├── frontend/                    # Application Flutter
│   ├── lib/
│   │   ├── main.dart           # Point d'entree
│   │   ├── config/             # Configuration (API, etc.)
│   │   ├── models/             # Modeles de donnees
│   │   ├── screens/            # Ecrans de l'application
│   │   │   ├── welcome_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── admin_home_screen.dart
│   │   │   ├── host_home_screen.dart
│   │   │   ├── client_home_screen.dart
│   │   │   └── ...
│   │   ├── services/           # Services (API calls)
│   │   ├── theme/              # Theme et design system
│   │   └── widgets/            # Widgets reutilisables
│   ├── assets/                 # Images et ressources
│   └── pubspec.yaml            # Dependances Flutter
│
├── backend/                     # API Node.js/Express
│   ├── server.js               # Point d'entree du serveur
│   ├── db.js                   # Configuration base de donnees
│   ├── controllers/            # Logique metier
│   │   ├── auth.controller.js
│   │   ├── menu.controller.js
│   │   ├── place.controller.js
│   │   ├── reservation.controller.js
│   │   └── timeSlot.controller.js
│   ├── routes/                 # Definitions des routes
│   ├── middlewares/            # Middlewares (auth, etc.)
│   ├── services/               # Services (notifications)
│   └── package.json            # Dependances Node.js
│
├── database/                    # Scripts base de donnees
│   └── init.sql                # Schema et donnees initiales
│
├── docs/                        # Documentation VitePress
│   ├── .vitepress/             # Configuration VitePress
│   ├── guide/                  # Guides utilisateur
│   ├── api/                    # Documentation API
│   └── index.md                # Page d'accueil
│
└── README.md                    # Ce fichier
```

## 🛠️ Technologies Utilisees

### Frontend
- **Flutter 3.x** - Framework cross-platform
- **Dart** - Langage de programmation
- **Provider** - State management
- **HTTP** - Client HTTP pour API calls

### Backend
- **Node.js** - Runtime JavaScript
- **Express** - Framework web
- **MySQL2** - Driver MySQL
- **JWT** - Authentification par tokens
- **Bcrypt** - Hashage des mots de passe
- **Cors** - Gestion des origines croisees
- **Swagger** - Documentation API interactive

### Base de Donnees
- **MySQL 8.0** - Base relationnelle

### Outils de Developpement
- **Git/GitHub** - Versioning et collaboration
- **GitHub Projects** - Gestion Agile avec Kanban
- **GitHub Issues** - User Stories et taches
- **Android Studio** - IDE
- **Postman** - Tests API
- **VitePress** - Documentation technique

## 📚 Documentation

La documentation complete du projet est disponible en ligne :

🔗 **[Documentation officielle](https://nouhamk.github.io/restau-reservation-flutter/)**

Elle contient :
- Guide de demarrage
- Documentation API complete
- Gestion des roles et permissions
- Methodologie Agile et organisation
- Architecture technique

### Documentation API Swagger

L'API dispose d'une documentation interactive Swagger accessible a :

🔗 **[API Swagger](https://restau-api.67gigs.codes/api-docs/#/)**

## 👥 Equipe de Developpement

### Methodologie Agile

Le projet suit une methodologie Agile avec :
- **Board Kanban** : [GitHub Projects](https://github.com/users/Nouhamk/projects/9/views/1)
- **User Stories** : Issues GitHub
- **Reviews** : Code reviews systematiques

### Membres de l'Equipe

- **Nouhaila MOUKADDIME** - Gestion de projet, UI/UX, Authentification
- **Axel Colliaux** - Gestion des menus, Wireframes
- **Noureddine BENSADOK** - Backend, API, Base de donnees
- **Ilias Abdelkader EZZAROUALI** - Systeme de reservations


## 📝 License

Ce projet est sous licence ISC. Voir le fichier LICENSE pour plus de details.

## 🤝 Contribution

Ce projet est un projet academique. Pour toute question ou suggestion :

1. Consulter la [documentation](https://nouhamk.github.io/restau-reservation-flutter/)
2. Ouvrir une [issue](https://github.com/Nouhamk/restau-reservation-flutter/issues)
3. Consulter le [board Kanban](https://github.com/users/Nouhamk/projects/9/views/1)

---

**Projet Academique 2025 - Les AL**

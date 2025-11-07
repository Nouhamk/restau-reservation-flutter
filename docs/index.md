---
layout: home

hero:
  name: Les AL
  text: Systeme de Reservation
  tagline: Documentation technique complete pour le pub anglais authentique
  image:
    src: /restaurant.webp
    alt: Les AL Restaurant
  actions:
    - theme: brand
      text: Guide de demarrage
      link: /guide/getting-started
    - theme: alt
      text: Documentation API
      link: https://restau-api.67gigs.codes/api-docs/#/

features:
  - title: Frontend Flutter
    details: Application mobile cross-platform avec une interface elegante et minimaliste
  
  - title: Backend Node.js
    details: API REST robuste avec authentification JWT et gestion des roles
  
  - title: Base de donnees MySQL
    details: Schema optimise pour les reservations, menus et gestion multi-restaurants
  
  - title: Authentification securisee
    details: Systeme d'authentification avec gestion des roles (Client, Hote, Admin)
  
  - title: Design elegant
    details: Theme lumineux avec palette de couleurs raffinee (deepNavy, roseGold, champagne)
  
  - title: Gestion multi-roles
    details: Interfaces adaptees pour clients, hotes et administrateurs
---

## Demarrage rapide

### Installation du Frontend

```bash
cd frontend
flutter pub get
flutter run
```

### Installation du Backend

```bash
cd backend
npm install
npm start
```

### Configuration de la base de donnees

```bash
mysql -u root -p < database/init.sql
```

## Architecture du projet

Le projet est organise en trois composantes principales :

- **Frontend** : Application Flutter pour iOS et Android
- **Backend** : API REST Node.js/Express
- **Database** : Base de donnees MySQL

```
restau-reservation-flutter/
 frontend/          # Application Flutter
    lib/
       screens/   # Ecrans (admin, host, client)
       services/  # Services (auth, API)
       models/    # Modeles de donnees
       theme/     # Theme et design
 backend/           # API Node.js
    controllers/   # Logique metier
    routes/        # Routes API
    middlewares/   # Middlewares (auth)
    services/      # Services (notifications)
 database/          # Scripts SQL
```

## Technologies utilisees

### Frontend
- **Flutter** : Framework cross-platform
- **Dart** : Langage de programmation
- **Material Design** : Design moderne

### Backend
- **Node.js** : Environnement d'execution
- **Express** : Framework web
- **JWT** : Authentification securisee

### Base de donnees
- **MySQL** : Base relationnelle
- **Schema optimise** : Performances maximales

## Fonctionnalites

### Pour les clients
- Consulter les menus et cartes
- Reserver une table facilement
- Gerer ses reservations

### Pour les hotes
- Gerer toutes les reservations
- Organiser le plan de table
- Configurer les creneaux horaires

### Pour les administrateurs
- Gerer plusieurs restaurants
- Editer les menus et cartes
- Administrer le systeme complet
- Acceder aux statistiques globales

## Contribuer

Consultez le [guide de contribution](https://github.com/Nouhamk/restau-reservation-flutter) pour plus d'informations sur comment participer au projet.
# Introduction

Bienvenue dans la documentation du systeme de reservation **Les AL**, un pub anglais authentique.

## A propos du projet

Les AL est une application complete de gestion de reservations pour restaurants, specialement concue pour un pub anglais. Le systeme permet :

- **Pour les clients** : Consulter les menus, reserver une table, gerer leurs reservations
- **Pour les hotes** : Gerer les reservations, organiser le plan de table, voir les creneaux horaires
- **Pour les administrateurs** : Gerer plusieurs restaurants, editer les menus, administrer le systeme

## Stack technique

### Frontend
- **Flutter** : Framework cross-platform pour iOS et Android
- **Dart** : Langage de programmation
- **Material Design** : Design moderne et elegant

### Backend
- **Node.js** : Environnement d'execution JavaScript
- **Express** : Framework web minimaliste
- **JWT** : Authentification par tokens

### Base de donnees
- **MySQL** : Base de donnees relationnelle
- **Schema optimise** : Pour les reservations et la gestion multi-restaurants

## Fonctionnalites principales

### Authentification et autorisation
- Inscription et connexion securisees
- Gestion des roles (Client, Hote, Admin)
- Tokens JWT avec expiration

### Gestion des reservations
- Creation de reservations
- Selection de creneaux horaires
- Choix du nombre de personnes
- Confirmation et annulation

### Interfaces adaptees par role
- **Client** : Interface simple pour reserver et consulter
- **Hote** : Outils de gestion des tables et reservations
- **Admin** : Panneau d'administration complet

### Design elegant
- Theme lumineux et minimaliste
- Palette de couleurs raffinee :
  - Deep Navy (#2C3E50)
  - Rose Gold (#B76E79)
  - Champagne (#D4A574)
  - Sage Green (#87A878)

## Prochaines etapes

1. [Installation](/guide/installation) : Configurer l'environnement de developpement
2. [Configuration](/guide/configuration) : Parametrer l'application
3. [Authentification](/guide/authentication) : Comprendre le systeme d'auth
4. [Gestion des roles](/guide/roles) : Decouvrir les differents roles

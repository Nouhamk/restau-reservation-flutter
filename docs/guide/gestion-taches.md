# Gestion des taches

Cette page présente la repartition des taches entre les membres de l'équipe pour le projet Les AL.

## Methodologie Agile

Pour ce projet académique, nous avons adopté une méthodologie **Agile** afin d'imiter un environnement d'entreprise réel et rester organisés tout au long du developpement.

### Organisation avec GitHub Projects

Nous utilisons un **board Kanban** sur GitHub Projects pour suivre l'avancement du projet :

 **[Board Kanban du projet](https://github.com/users/Nouhamk/projects/9/views/1)**

Le board est organise en colonnes :
- **Backlog** : Fonctionnalités a developper
- **To Do** : Taches pretes a etre demarrées
- **In Progress** : Taches en cours de developpement
- **Review** : En attente de validation
- **Done** : Taches completées

### User Stories et Issues

Chaque fonctionnalité du projet est documentée sous forme de **User Story** dans les GitHub Issues :

**Format des User Stories :**
```
En tant que [role],
Je veux [action],
Afin de [benefice].
```

**Exemples :**
- En tant que client, je veux consulter le menu du restaurant afin de choisir mes plats
- En tant que hote, je veux valider les reservations afin de gerer la capacite du restaurant
- En tant qu''admin, je veux ajouter de nouveaux plats au menu afin de le mettre a jour

Cette approche nous permet de :
-  Garder une vision claire des besoins utilisateurs
-  Prioriser les fonctionnalites importantes
-  Suivre l''avancement de chaque membre
-  Faciliter la collaboration et les reviews de code


## Equipe de developpement

### Nouhaila MOUKADDIME
**Responsable**: Gestion de projet, Interface utilisateur et authentification

**Realisations :**
- Gestion de projet et création des users stories et documentation
- Création des ecrans de connexion et inscription
- Developpement du welcome screen et home screens pour chaque role
- Implementation du theme centralise pour l'application
- Mise en place de la navigation basee sur les roles (Client/Host/Admin)
- Integration du design system avec palette de couleurs élégante


### Axel Colliaux
**Responsable**: Gestion des menus et wireframes

**Realisations :**
- Developpement de la partie menu et consultation
- Implementation de l'ajout et edition de plats pour les admins
- Creation des wireframes complets du projet
- Conception des maquettes d'interface


### Noureddine BENSADOK
**Responsable**: Backend et infrastructure

**Réalisations :**
- Développement de l'API REST Node.js/Express
- Mise en place de la base de donnees MySQL
- Configuration de l'authentification JWT
- Implementation des middlewares de securité
- Creation des controllers pour toutes les ressources


### Ilias Abdelkader EZZAROUALI
**Responsable**: Systeme de réservations

**Réalisations :**
- Développement de la gestion complete des réservations
- Creation des interfaces de reservation pour clients
- Implementation des outils de gestion pour les hotes
- Systeme de validation et historique

## Technologies utilisees

### Frontend
- **Flutter 3.x** : Framework cross-platform
- **Dart** : Langage de programmation
- **Provider** : State management
- **HTTP client** : Communication avec l''API

### Backend
- **Node.js** : Environnement d''execution JavaScript
- **Express** : Framework web minimaliste
- **MySQL** : Base de donnees relationnelle
- **JWT** : JSON Web Tokens pour l''authentification
- **Swagger** : Documentation API interactive

### Outils de developpement
- **GitHub** : Plateforme de collaboration
- **GitHub Projects** : Board Kanban et suivi Agile
- **GitHub Issues** : User Stories et gestion des taches
- **VS Code** : Editeur de code
- **Postman** : Tests API
- **MySQL Workbench** : Gestion base de donnees
- **VitePress** : Documentation technique


## Bonnes pratiques adoptees

### Code Quality
-  Respect des conventions de nommage
-  Code commente et documente
-  Separation des responsabilites (MVC)
-  Gestion des erreurs appropriee

### Collaboration
-  Communication reguliere via GitHub
-  Reviews de code systematiques
-  Documentation a jour
-  Partage des connaissances

### Agilite
-  Sprints de 2 semaines
-  Stand-ups virtuels
-  Retrospectives d''equipe
-  Adaptation continue du backlog


## Contact et support

Pour toute question ou probleme technique, contacter le membre responsable de la partie concernee.

**Repository:** [restau-reservation-flutter](https://github.com/Nouhamk/restau-reservation-flutter)

**Board Kanban:** [GitHub Projects](https://github.com/users/Nouhamk/projects/9/views/1)

**Issues:** [GitHub Issues](https://github.com/Nouhamk/restau-reservation-flutter/issues)
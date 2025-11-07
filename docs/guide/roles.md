# Gestion des roles

Le systeme Les AL implemente trois roles distincts avec des permissions et interfaces specifiques.

## Les trois roles

### 1. Client (Customer)

Le role par defaut pour les utilisateurs qui souhaitent reserver une table.

**Permissions :**
- Consulter les menus
- Creer des reservations
- Voir ses propres reservations
- Modifier/annuler ses reservations
- Pas d'acces aux donnees d'autres clients
- Pas de gestion des tables
- Pas de fonctions administratives

**Interface :**
- Ecran d'accueil minimaliste
- Cartes de services : Consulter la carte, Reserver, Mes reservations
- Informations pratiques

### 2. Hote (Host)

Role pour le personnel du restaurant qui gere les reservations et le plan de table.

**Permissions :**
- Voir toutes les reservations
- Confirmer/refuser les reservations
- Gerer le plan de table
- Configurer les creneaux horaires
- Consulter la liste des clients
- Pas de modification des menus
- Pas de gestion des utilisateurs
- Pas de fonctions administratives systeme

**Interface :**
- Tableau de bord avec statistiques
- Gestion des reservations (avec badge notifications)
- Plan de table interactif
- Creneaux horaires
- Liste des clients

### 3. Administrateur (Admin)

Role avec controle total du systeme.

**Permissions :**
- Toutes les permissions Client et Hote
- Gerer plusieurs restaurants
- Editer les menus et cartes
- Gerer tous les utilisateurs (clients, hotes, admins)
- Voir toutes les reservations
- Statistiques et rapports globaux
- Parametres systeme

**Interface :**
- Panneau d'administration avec header navy
- Vue d'ensemble du systeme (statistiques)
- Gestion restaurants, menus, utilisateurs
- Reservations globales
- Analytics et rapports

## Implementation technique

### Modele User

```dart
class User {
  final int? id;
  final String email;
  final String? nom;
  final String? telephone;
  final String? role; // 'client', 'host', 'admin'
}
```

### Navigation basee sur le role

Apres l'authentification, l'utilisateur est redirige vers l'ecran approprie :

```dart
Widget _buildRoleScreen() {
  final role = _currentUser?.role?.toLowerCase() ?? 'client';
  switch (role) {
    case 'admin':
    case 'administrateur':
      return const AdminHomeScreen();
    case 'host':
    case 'hote':
      return const HostHomeScreen();
    case 'client':
    case 'customer':
    default:
      return const ClientHomeScreen();
  }
}
```

### Middleware backend

Le backend verifie le role avec un middleware :

```javascript
const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  const decoded = jwt.verify(token, SECRET_KEY);
  req.user = decoded; // { userId, role }
  next();
};

// Route protegee admin uniquement
router.post('/admin/restaurant', authMiddleware, (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Acces refuse' });
  }
  // Logique...
});
```

## Attribuer un role

### A l'inscription

Par defaut, les nouveaux utilisateurs recoivent le role client :

```javascript
const { email, password, name, phone } = req.body;
const role = 'client'; // Role par defaut

await db.query(
  'INSERT INTO users (email, password, name, phone, role) VALUES (?, ?, ?, ?, ?)',
  [email, hashedPassword, name, phone, role]
);
```

### Promotion d'un utilisateur

Un admin peut changer le role d'un utilisateur :

```javascript
// Route admin pour changer un role
router.put('/admin/users/:id/role', authMiddleware, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Acces refuse' });
  }
  
  const { role } = req.body; // 'client', 'host', 'admin'
  await db.query('UPDATE users SET role = ? WHERE id = ?', [role, req.params.id]);
  
  res.json({ message: 'Role mis a jour' });
});
```

## Bonnes pratiques

1. **Toujours verifier le role cote backend** : Ne jamais faire confiance uniquement au frontend
2. **Tokens JWT avec role** : Inclure le role dans le payload JWT
3. **Interfaces separees** : Creer des ecrans dedies pour chaque role
4. **Permissions granulaires** : Definir clairement ce que chaque role peut faire
5. **Logs des actions admin** : Tracer les modifications importantes

## Exemple de flux complet

1. L'utilisateur se connecte
2. Le backend genere un JWT avec `{ userId: 7, role: 'admin' }`
3. Le frontend stocke le token et les donnees utilisateur
4. A l'ouverture de HomeScreen, on lit user.role
5. On affiche AdminHomeScreen si `role === 'admin'`
6. Chaque action (API call) inclut le token
7. Le backend verifie le role avant d'autoriser l'action

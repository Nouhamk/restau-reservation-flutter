-- Table des utilisateurs
CREATE TABLE default.users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  role ENUM('client', 'host', 'admin') DEFAULT 'client',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des réservations
CREATE TABLE default.reservations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  reservation_date DATE NOT NULL,
  reservation_time TIME NOT NULL,
  guests INT NOT NULL,
  status ENUM('pending', 'confirmed', 'cancelled') DEFAULT 'pending',
  notes TEXT,
  place_id INT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des lieux/branches (places)
CREATE TABLE default.places (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  address VARCHAR(500),
  phone VARCHAR(50),
  capacity INT DEFAULT 50,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ajouter contrainte FK pour place_id après création de la table places
ALTER TABLE default.reservations
  ADD CONSTRAINT fk_reservations_place FOREIGN KEY (place_id) REFERENCES places(id) ON DELETE SET NULL;

-- Table des plats du menu
CREATE TABLE default.menu_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  category ENUM('starter', 'main', 'dessert', 'drink') NOT NULL,
  image_url VARCHAR(500),
  available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table de la disponibilité des créneaux
CREATE TABLE default.time_slots (
  id INT AUTO_INCREMENT PRIMARY KEY,
  slot_time TIME NOT NULL,
  max_capacity INT DEFAULT 50,
  UNIQUE KEY (slot_time)
);

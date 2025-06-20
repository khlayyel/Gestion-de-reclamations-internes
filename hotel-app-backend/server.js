// Importation des modules nécessaires
require('dotenv').config(); // Charger les variables d'environnement
const express = require('express'); // Framework web pour Node.js
const mongoose = require('mongoose'); // ODM pour MongoDB
const cors = require('cors'); // Pour gérer les requêtes cross-origin
const http = require('http'); // Module HTTP natif de Node.js
const { Server } = require('socket.io'); // Pour le support WebSocket

// Initialiser l'application Express
const app = express();

// Utiliser CORS pour autoriser les requêtes cross-origin (toutes origines)
app.use(cors());

// Middleware pour parser les requêtes JSON (body parser)
app.use(express.json());

// Importer les routes utilisateurs et réclamations
const userRoutes = require('./routes/userRoutes');
const reclamationRoutes = require('./routes/reclamationRoutes');

// Définir les préfixes d'URL pour les routes
app.use('/api/users', userRoutes); // Routes pour la gestion des utilisateurs
app.use('/api/reclamations', reclamationRoutes); // Routes pour la gestion des réclamations

// Route de base pour vérifier que l'API fonctionne
app.get('/', (req, res) => {
  res.json({ message: 'API is running' });
});

// Création du serveur HTTP à partir de l'application Express
const server = http.createServer(app);
// Initialisation de Socket.io pour la communication en temps réel
const io = new Server(server, {
  cors: {
    origin: '*', // Autorise toutes les origines
    methods: ['GET', 'POST', 'PUT', 'DELETE'], // Méthodes autorisées
  },
});
// Attacher l'instance io à l'application pour l'utiliser dans les contrôleurs
app.set('io', io);

// Connexion à la base de données MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    // Si la connexion réussit
    console.log('✅ MongoDB connecté');
    const PORT = process.env.PORT || 5000;
    // Démarrer le serveur HTTP sur le port défini
    server.listen(PORT, () => {
      console.log(`🚀 Serveur lancé sur le port ${PORT}`);
    });
  })
  .catch(err => console.error('Erreur MongoDB:', err)); // Gestion des erreurs de connexion

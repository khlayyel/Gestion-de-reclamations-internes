// Importation du module express
const express = require('express');
// Création d'un routeur express
const router = express.Router();
// Importation du contrôleur utilisateur
const userController = require('../controllers/userController');

// Route pour enregistrer un utilisateur
router.post('/create', userController.createUser);

// Route pour obtenir tous les utilisateurs
router.get('/get', userController.getAllUsers);

// Route pour la connexion
router.post('/login', userController.loginUser); 

// ✅ Nouvelle route pour mettre à jour un utilisateur par ID
router.put('/update/:id', userController.updateUser);

// Route pour synchroniser un player_id OneSignal avec un utilisateur
router.post('/sync-onesignal-playerid', userController.syncOneSignalPlayerId);

// Route pour supprimer un utilisateur par ID
router.delete('/:id', userController.deleteUser);

// Exportation du routeur pour l'utiliser dans server.js
module.exports = router;

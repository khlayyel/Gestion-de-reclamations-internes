// Importation du module express
const express = require('express');
// Création d'un routeur express
const router = express.Router();
// Importation du contrôleur de réclamation
const reclamationController = require('../controllers/reclamationController');

// Route pour créer une réclamation
router.post('/create', reclamationController.createReclamation);

// Route pour obtenir toutes les réclamations
router.get('/', reclamationController.getAllReclamations);

// Route pour mettre à jour le statut d'une réclamation
router.put('/:id/status', reclamationController.updateStatus);

// Route pour mettre à jour une réclamation
router.put('/update/:id', reclamationController.updateReclamation);

// Route pour supprimer une réclamation
router.delete('/:id', reclamationController.deleteReclamation);

// Route pour obtenir les réclamations selon le rôle de l'utilisateur
router.get('/byUser', reclamationController.getReclamationsByUser);

// Exportation du routeur pour l'utiliser dans server.js
module.exports = router;

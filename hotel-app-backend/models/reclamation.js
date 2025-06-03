// Importation de mongoose pour la gestion de MongoDB
const mongoose = require('mongoose');

// Définition du schéma de la réclamation
const reclamationSchema = new mongoose.Schema({
  objet: { type: String, required: true }, // Objet de la réclamation
  description: { type: String, required: true }, // Description détaillée
  departments: { type: [String], required: true }, // Liste des départements concernés
  priority: { type: Number, required: true, default: 1 }, // Priorité (1=haute, 2=moyenne, 3=basse)
  status: { type: String, enum: ['New', 'In Progress', 'Done'], default: 'New', required: true }, // Statut de la réclamation
  location: { type: String, required: true }, // Emplacement concerné
  assignedTo: { type: String, default: '' }, // Nom de la personne assignée
  createdBy: { type: String, required: true }, // Créateur de la réclamation
  createdAt: { type: Date, default: Date.now }, // Date de création
  updatedAt: { type: Date }, // Date de dernière mise à jour
});

// Exportation du modèle mongoose pour l'utiliser dans les contrôleurs
module.exports = mongoose.model('reclamation', reclamationSchema);

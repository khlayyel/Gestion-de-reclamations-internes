// Importation de mongoose pour la gestion de MongoDB
const mongoose = require('mongoose');

// Définition du schéma utilisateur
const userSchema = new mongoose.Schema({
  name: { type: String, required: true }, // Nom complet de l'utilisateur
  email: { type: String, required: true, unique: true }, // Email unique
  password: { type: String, required: true }, // Mot de passe
  role: { type: String, enum: ['staff', 'admin'], default: 'staff' }, // Rôle (staff ou admin)
  departments: {
    type: [String],
    enum: ['Nettoyage', 'Réception', 'Maintenance', 'Sécurité', 'Restauration', 'Cuisine', 'Blanchisserie', 'Spa', 'Informatique', 'Direction'],
    required: function() { return this.role === 'staff'; } // Obligatoire pour le staff
  },
  ajoutePar: { type: String }, // Nom de l'admin qui a ajouté
  modifiePar: { type: String } // Nom de l'admin qui a modifié
}, { timestamps: true }); // Ajoute createdAt et updatedAt automatiquement

// Création et exportation du modèle mongoose
const User = mongoose.model('User', userSchema);

module.exports = User;

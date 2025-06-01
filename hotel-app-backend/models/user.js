const mongoose = require('mongoose');

// Schéma pour un utilisateur
const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['staff', 'admin'], default: 'staff' },
  departments: {
    type: [String],
    enum: ['Nettoyage', 'Réception', 'Maintenance', 'Sécurité', 'Restauration', 'Cuisine', 'Blanchisserie', 'Spa', 'Informatique', 'Direction'],
    required: function() { return this.role === 'staff'; }
  },
  ajoutePar: { type: String },
  modifiePar: { type: String }
}, { timestamps: true });


const User = mongoose.model('User', userSchema);

module.exports = User;

const Reclamation = require('../models/reclamation');
const User = require('../models/user');

exports.createReclamation = async (req, res) => {
  try {
    const reclamationData = { ...req.body };
    
    // Si un utilisateur est assigné, récupérer son nom
    if (reclamationData.assignedTo) {
      const user = await User.findById(reclamationData.assignedTo);
      if (user) {
        reclamationData.assignedTo = user.name;
      }
    }

    const reclamation = new Reclamation(reclamationData);
    await reclamation.save();
    // Émettre l'événement WebSocket
    req.app.get('io').emit('reclamationsUpdated');
    res.status(201).json(reclamation);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getAllReclamations = async (req, res) => {
  const reclamations = await Reclamation.find();
  res.json(reclamations);
};

exports.updateStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, assignedTo } = req.body;

    console.log('--- [updateStatus] ---');
    console.log('ID:', id);
    console.log('status:', status);
    console.log('assignedTo:', assignedTo);

    // Vérifier si la réclamation existe
    const reclamation = await Reclamation.findById(id);
    if (!reclamation) {
      return res.status(404).json({ error: 'Réclamation non trouvée' });
    }

    // Mettre à jour la réclamation avec le statut et le nom de l'utilisateur assigné
    const updatedReclamation = await Reclamation.findByIdAndUpdate(
      id,
      { 
        status, 
        assignedTo, // Use the name directly since we're storing names in the reclamation
        updatedAt: new Date() 
      },
      { new: true }
    );

    console.log('Réclamation mise à jour (status):', updatedReclamation);
    // Émettre l'événement WebSocket
    req.app.get('io').emit('reclamationsUpdated');
    res.json(updatedReclamation);
  } catch (err) {
    console.log('Erreur updateStatus:', err);
    res.status(400).json({ error: `Erreur: ${err.message}` });
  }
};

exports.updateReclamation = async (req, res) => {
  const { id } = req.params;
  const updateData = { ...req.body };

  // Ajout de logs pour debug
  console.log('--- [updateReclamation] ---');
  console.log('ID:', id);
  console.log('updateData:', updateData);

  try {
    // Si un utilisateur est assigné, récupérer son nom
    if (updateData.assignedTo) {
      const user = await User.findById(updateData.assignedTo);
      if (user) {
        updateData.assignedTo = user.name;
      }
    }

    const updatedReclamation = await Reclamation.findByIdAndUpdate(
      id,
      { ...updateData, updatedAt: new Date() },
      { new: true }
    );

    if (!updatedReclamation) {
      console.log('Réclamation non trouvée');
      return res.status(404).json({ message: 'Réclamation non trouvée' });
    }

    console.log('Réclamation mise à jour:', updatedReclamation);
    // Émettre l'événement WebSocket
    req.app.get('io').emit('reclamationsUpdated');
    res.status(200).json(updatedReclamation);
  } catch (error) {
    console.log('Erreur lors de la mise à jour:', error);
    res.status(500).json({ message: 'Erreur lors de la mise à jour', error });
  }
};

exports.deleteReclamation = async (req, res) => {
  try {
    await Reclamation.findByIdAndDelete(req.params.id);
    // Émettre l'événement WebSocket
    req.app.get('io').emit('reclamationsUpdated');
    res.status(200).json({ message: 'Réclamation supprimée' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la suppression', error });
  }
};

// Nouvelle route pour filtrer les réclamations selon le rôle
exports.getReclamationsByUser = async (req, res) => {
  try {
    const { userId } = req.query;
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });

    let reclamations;
    if (user.role === 'admin') {
      reclamations = await Reclamation.find();
    } else if (user.role === 'staff') {
      reclamations = await Reclamation.find({ departments: { $in: user.departments } });
    } else {
      reclamations = [];
    }
    res.json(reclamations);
  } catch (err) {
    res.status(500).json({ message: 'Erreur lors de la récupération des réclamations', error: err.message });
  }
};

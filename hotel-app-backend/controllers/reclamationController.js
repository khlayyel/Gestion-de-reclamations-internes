const Reclamation = require('../models/reclamation');
const User = require('../models/user');
const nodemailer = require('nodemailer');

// Configuration du service d'envoi d'email (Gmail ici)
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

// Fonction utilitaire pour envoyer une notification email lors de la création d'une réclamation
async function sendReclamationNotification(reclamation, emails) {
  const { objet, description, departments, priority, status, location, createdBy } = reclamation;
  const subject = "Nouvelle Réclamation";
  const body = `
    <h2>Nouvelle réclamation créée</h2>
    <p><b>Objet :</b> ${objet}</p>
    <p><b>Description :</b> ${description}</p>
    <p><b>Départements concernés :</b> ${departments.join(', ')}</p>
    <p><b>Priorité :</b> ${priority}</p>
    <p><b>Statut :</b> ${status}</p>
    <p><b>Emplacement :</b> ${location}</p>
    <p><b>Créée par :</b> ${createdBy}</p>
    <a href="https://reclamations-internes.vercel.app/" style="display:inline-block;padding:12px 24px;background:#1976d2;color:#fff;text-decoration:none;border-radius:6px;margin-top:16px;font-weight:bold;">Accéder à l'application de réclamation</a>
  `;
  console.log('--- [ENVOI EMAIL RECLAMATION] ---');
  console.log('Début de l\'envoi des emails de notification...');
  console.log('Emails ciblés :', emails);
  for (const email of emails) {
    try {
      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: email,
        subject,
        html: body
      });
      console.log(`Email envoyé avec succès à : ${email}`);
    } catch (err) {
      console.error(`Erreur lors de l'envoi à ${email} :`, err);
    }
  }
  console.log('--- [FIN ENVOI EMAIL RECLAMATION] ---');
}

// Créer une nouvelle réclamation
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

    // Création et sauvegarde de la réclamation
    const reclamation = new Reclamation(reclamationData);
    await reclamation.save();

    // Notifier tous les admins et staffs concernés
    const admins = await User.find({ role: 'admin' });
    const staffs = await User.find({ role: 'staff', departments: { $in: reclamation.departments } });
    const emails = [
      ...admins.map(a => a.email),
      ...staffs.map(s => s.email)
    ].filter((v, i, a) => a.indexOf(v) === i); // Unicité
    await sendReclamationNotification(reclamation, emails);

    // Émettre l'événement WebSocket
    req.app.get('io').emit('reclamationsUpdated');
    res.status(201).json(reclamation);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Obtenir toutes les réclamations
exports.getAllReclamations = async (req, res) => {
  const reclamations = await Reclamation.find();
  res.json(reclamations);
};

// Mettre à jour le statut d'une réclamation
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
        assignedTo, // Utilise le nom directement
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

// Mettre à jour une réclamation (tous champs)
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

    // Mise à jour de la réclamation
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

// Supprimer une réclamation
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

// Obtenir les réclamations selon le rôle de l'utilisateur
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

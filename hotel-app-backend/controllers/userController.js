const User = require('../models/user');
const bcrypt = require('bcryptjs');
const { sendUserCredentialsEmail } = require('../utils/emailService');
const { sendNotification } = require('../utils/notificationService');

// Créer un nouvel utilisateur
exports.createUser = async (req, res) => {
  const { name, email, password, role, departments, ajoutePar } = req.body;

  console.log('Données reçues:', req.body);

  try {
    // Validation des champs requis
    if (!name || !email || !password) {
      return res.status(400).json({ 
        message: 'Tous les champs sont requis (nom, email, mot de passe)' 
      });
    }
    if (role === 'staff' && (!departments || !departments.length)) {
      return res.status(400).json({ 
        message: 'Le staff doit avoir au moins un département' 
      });
    }

    // Vérifier si l'email existe déjà
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Cet email est déjà utilisé' });
    }

    // Hashage du mot de passe
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    let userData = { name, email, password: hashedPassword, role: role || 'staff' };
    if (role === 'staff') {
      userData.departments = departments;
    }
    // Ajout du champ ajoutePar si fourni
    if (ajoutePar) {
      userData.ajoutePar = ajoutePar;
    }
    // Si admin, ne pas mettre de départements

    const newUser = new User(userData);
    await newUser.save();
    console.log('Utilisateur créé avec succès:', newUser);

    // Envoyer l'email de bienvenue avec le mot de passe en clair
    await sendUserCredentialsEmail({
      email,
      name,
      password, // mot de passe en clair
      role,
      departments,
      action: 'create',
      adminName: ajoutePar
    });

    res.status(201).json({ message: 'Utilisateur créé avec succès', user: newUser });
  } catch (error) {
    console.error('Erreur lors de la création:', error);
    res.status(500).json({ message: 'Erreur lors de la création de l\'utilisateur', error: error.message });
  }
};


// Obtenir tous les utilisateurs
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find();
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la récupération des utilisateurs', error });
  }
};


exports.loginUser = async (req, res) => {
  const { name, password } = req.body;

  try {
    const user = await User.findOne({ name });

    if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });

    // Comparaison du mot de passe avec bcrypt
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Mot de passe incorrect' });
    }

    res.status(200).json({
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      departments: user.departments || [],
    });
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email, password, role, departments, modifiePar } = req.body;

    const updateData = { name, email, role, departments, modifiePar };

    // Si un nouveau mot de passe est fourni, le hasher
    if (password) {
      const salt = await bcrypt.genSalt(10);
      updateData.password = await bcrypt.hash(password, salt);
    }

    const updatedUser = await User.findByIdAndUpdate(id, updateData, { new: true });

    if (!updatedUser) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    // Envoyer un email de notification pour chaque mise à jour
    await sendUserCredentialsEmail({
      email: updatedUser.email,
      name: updatedUser.name,
      password, // mot de passe en clair (sera undefined si non fourni, ce qui est géré par le service email)
      role: updatedUser.role,
      departments: updatedUser.departments,
      action: 'update',
      adminName: modifiePar
    });

    // Envoyer une notification push à l'utilisateur modifié
    if (updatedUser.playerIds && updatedUser.playerIds.length > 0) {
      const heading = "Votre compte a été mis à jour";
      const content = "Vos informations ont été modifiées par un administrateur. Consultez vos e-mails pour plus de détails.";
      await sendNotification(updatedUser.playerIds, heading, content);
    }

    res.status(200).json({ message: 'Utilisateur modifié avec succès', user: updatedUser });
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la modification de l\'utilisateur', error: error.message });
  }
};

// Nouvelle fonction pour mettre à jour le playerId
exports.updatePlayerId = async (req, res) => {
  const { userId, playerId } = req.body;

  if (!userId || !playerId) {
    return res.status(400).json({ message: 'userId et playerId sont requis.' });
  }

  try {
    // Ajoute le nouveau playerId au tableau s'il n'y est pas déjà
    const user = await User.findByIdAndUpdate(
      userId,
      { $addToSet: { playerIds: playerId } }, // $addToSet évite les doublons
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé.' });
    }

    res.status(200).json({ message: 'Player ID mis à jour avec succès.' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la mise à jour du Player ID.', error: error.message });
  }
};

exports.deleteUser = async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'Utilisateur supprimé' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la suppression', error });
  }
};
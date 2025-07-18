const User = require('../models/user');
const bcrypt = require('bcryptjs');
const { sendUserCredentialsEmail } = require('../utils/emailService');
const { sendNotification } = require('../utils/notificationService');
const fetch = require('node-fetch');

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

    // Envoyer une notification push à l'utilisateur modifié (sauf si c'est lui-même qui se modifie)
    if (updatedUser.playerIds && updatedUser.playerIds.length > 0) {
      // On suppose que l'ID de l'admin modificateur est dans req.session.userId ou req.body.modifiePar
      // Si ce n'est pas le même user, on notifie
      if (!req.session || updatedUser._id.toString() !== req.session.userId) {
        const heading = "Votre compte a été modifié";
        const content = "Un administrateur a modifié votre compte. Consultez vos emails ou l'application pour plus de détails.";
        await sendNotification(updatedUser.playerIds, heading, content);
      }
    }

    res.status(200).json({ message: 'Utilisateur modifié avec succès', user: updatedUser });
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la modification de l\'utilisateur', error: error.message });
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

exports.syncOneSignalPlayerId = async (req, res) => {
  const { externalId } = req.body;
  if (!externalId) return res.status(400).json({ message: 'externalId requis' });

  const APP_ID = process.env.ONESIGNAL_APP_ID || '6ce72582-adbc-4b70-a16b-6af977e59707';
  const API_KEY = process.env.ONESIGNAL_REST_API_KEY;

  const url = `https://api.onesignal.com/apps/${APP_ID}/users/by/external_id/${externalId}`;
  try {
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Authorization': `Key ${API_KEY}`,
        'accept': 'application/json'
      }
    });
    const data = await response.json();
    if (!data.subscriptions || !data.subscriptions.length) {
      return res.status(404).json({ message: 'Aucune subscription trouvée pour ce user.' });
    }
    const playerId = data.subscriptions[0].id;

    // Met à jour le user dans MongoDB
    const user = await User.findByIdAndUpdate(
      externalId,
      { $addToSet: { playerIds: playerId } },
      { new: true }
    );
    if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé.' });

    res.json({ playerId });
  } catch (e) {
    res.status(500).json({ message: 'Erreur lors de la synchronisation du Player ID', error: e.message });
  }
};
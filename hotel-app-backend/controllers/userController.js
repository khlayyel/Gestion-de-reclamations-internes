const User = require('../models/user');
const bcrypt = require('bcryptjs');

// Créer un nouvel utilisateur
exports.createUser = async (req, res) => {
  const { name, email, password, role, departments } = req.body;

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
    if (req.body.ajoutePar) {
      userData.ajoutePar = req.body.ajoutePar;
    }
    // Si admin, ne pas mettre de départements

    const newUser = new User(userData);
    await newUser.save();
    console.log('Utilisateur créé avec succès:', newUser);
    res.status(201).json(newUser);
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
    const { role, departments, password } = req.body;
    let updateData = { ...req.body };
    if (role === 'staff') {
      updateData.departments = departments;
    } else if (role === 'admin') {
      updateData.departments = undefined;
    }
    // Ajout du champ modifiePar si fourni
    if (req.body.modifiePar) {
      updateData.modifiePar = req.body.modifiePar;
    }
    // Si un nouveau mot de passe est fourni, le hasher
    if (password) {
      const salt = await bcrypt.genSalt(10);
      updateData.password = await bcrypt.hash(password, salt);
    }
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    );
    if (!updatedUser) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
    res.json(updatedUser);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la mise à jour', error });
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
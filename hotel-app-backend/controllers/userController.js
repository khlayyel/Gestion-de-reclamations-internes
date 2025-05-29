const User = require('../models/user');

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

    let userData = { name, email, password, role: role || 'staff' };
    if (role === 'staff') {
      // On prend le premier département sélectionné (ou adapter le modèle si tu veux plusieurs)
      userData.department = departments[0];
    }
    // Si admin, ne pas mettre de département

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

    if (user.password !== password) {
      return res.status(401).json({ message: 'Mot de passe incorrect' });
    }

    res.status(200).json({
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      department: user.department,
    });
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

exports.updateUser = async (req, res) => {
  try {
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true } // renvoie le document modifié
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
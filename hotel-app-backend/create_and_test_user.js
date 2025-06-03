const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/user');

const MONGO_URI = 'mongodb+srv://ziedsoltani11:zied123456@cluster0.1kcjq64.mongodb.net/hotelApp?retryWrites=true&w=majority&appName=Cluster0';

async function main() {
  try {
    await mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
    console.log('Connecté à MongoDB');

    // 1. Création d'un nouvel utilisateur staff
    const plainPassword = 'motdepasseTest123';
    const hashedPassword = await bcrypt.hash(plainPassword, 10);
    const newUser = new User({
      name: 'Test Staff',
      email: 'test.staff@example.com',
      password: hashedPassword,
      role: 'staff',
      departments: ['Maintenance'],
      ajoutePar: 'script',
    });
    await newUser.save();
    console.log('Utilisateur staff créé:', newUser);

    // 2. Modification du mot de passe staff
    const newPlainPassword = 'nouveauMotDePasse456';
    const newHashedPassword = await bcrypt.hash(newPlainPassword, 10);
    newUser.password = newHashedPassword;
    await newUser.save();
    console.log('Mot de passe modifié pour (staff):', newUser.email);

    // 3. Vérification du login staff
    const userFromDb = await User.findOne({ email: 'test.staff@example.com' });
    const isMatch = await bcrypt.compare(newPlainPassword, userFromDb.password);
    if (isMatch) {
      console.log('Login staff réussi : le mot de passe correspond (haché OK)');
    } else {
      console.log('Échec du login staff : le mot de passe ne correspond pas');
    }

    // 4. Création d'un nouvel utilisateur admin
    const adminPlainPassword = 'adminTestPass123';
    const adminHashedPassword = await bcrypt.hash(adminPlainPassword, 10);
    const newAdmin = new User({
      name: 'Test Admin',
      email: 'test.admin@example.com',
      password: adminHashedPassword,
      role: 'admin',
      ajoutePar: 'script',
    });
    await newAdmin.save();
    console.log('Utilisateur admin créé:', newAdmin);

    // 5. Modification du mot de passe admin
    const adminNewPlainPassword = 'adminNouveauPass456';
    const adminNewHashedPassword = await bcrypt.hash(adminNewPlainPassword, 10);
    newAdmin.password = adminNewHashedPassword;
    await newAdmin.save();
    console.log('Mot de passe modifié pour (admin):', newAdmin.email);

    // 6. Vérification du login admin
    const adminFromDb = await User.findOne({ email: 'test.admin@example.com' });
    const adminIsMatch = await bcrypt.compare(adminNewPlainPassword, adminFromDb.password);
    if (adminIsMatch) {
      console.log('Login admin réussi : le mot de passe correspond (haché OK)');
    } else {
      console.log('Échec du login admin : le mot de passe ne correspond pas');
    }

    // Nettoyage : suppression des utilisateurs de test
    await User.deleteOne({ email: 'test.staff@example.com' });
    await User.deleteOne({ email: 'test.admin@example.com' });
    console.log('Utilisateurs de test supprimés.');

    process.exit(0);
  } catch (err) {
    console.error('Erreur lors du test utilisateur:', err);
    process.exit(1);
  }
}

main(); 
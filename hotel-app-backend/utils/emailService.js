const nodemailer = require('nodemailer');

// La configuration du transporteur utilise les variables d'environnement.
// Assurez-vous de configurer EMAIL_USER et EMAIL_PASS dans votre environnement.
const transporter = nodemailer.createTransport({
  service: 'gmail', // ou tout autre service compatible
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

/**
 * Envoie un e-mail à un utilisateur avec ses identifiants.
 * @param {object} userData - Données de l'utilisateur.
 * @param {string} userData.email - L'email du destinataire.
 * @param {string} userData.name - Le nom d'utilisateur.
 * @param {string} [userData.password] - Le mot de passe en clair (si applicable).
 * @param {string} userData.role - Le rôle de l'utilisateur ('staff' ou 'admin').
 * @param {string[]} [userData.departments] - Les départements (si staff).
 * @param {string} userData.action - 'create' ou 'update'.
 * @param {string} userData.adminName - Le nom de l'admin qui a effectué l'action.
 */
const sendUserCredentialsEmail = async (userData) => {
  const { email, name, password, role, departments, action, adminName } = userData;

  let subject = '';
  let htmlContent = '';

  // Construire la partie HTML pour les départements si l'utilisateur est un staff
  let departmentsHtml = '';
  if (role === 'staff' && departments && departments.length > 0) {
    departmentsHtml = `<li><strong>Départements :</strong> ${departments.join(', ')}</li>`;
  }

  if (action === 'create') {
    subject = 'Bienvenue ! Vos identifiants de connexion';
    htmlContent = `
      <h1>Bienvenue, ${name} !</h1>
      <p>Votre compte pour l'application de gestion hôtelière a été créé avec succès par <strong>${adminName}</strong>.</p>
      <p>Voici vos identifiants pour vous connecter :</p>
      <ul>
        <li><strong>Nom d'utilisateur :</strong> ${name}</li>
        <li><strong>Email :</strong> ${email}</li>
        ${departmentsHtml}
        <li><strong>Mot de passe :</strong> ${password}</li>
      </ul>
      <p>Nous vous recommandons de garder ces informations en lieu sûr.</p>
      <p>Cordialement,</p>
      <p>L'administration de l'hôtel</p>
    `;
  } else if (action === 'update') {
    subject = 'Mise à jour de votre compte utilisateur';
    let passwordHtml = '';
    // Si un nouveau mot de passe a été fourni, l'inclure
    if (password) {
      passwordHtml = `
        <p>Votre mot de passe a été modifié. Voici votre nouveau mot de passe :</p>
        <ul>
          <li><strong>Nouveau mot de passe :</strong> ${password}</li>
        </ul>
      `;
    }

    htmlContent = `
      <h1>Bonjour, ${name} !</h1>
      <p>Votre compte a été mis à jour par <strong>${adminName}</strong>.</p>
      <p>Voici un résumé de vos informations actuelles :</p>
      <ul>
        <li><strong>Nom d'utilisateur :</strong> ${name}</li>
        <li><strong>Email :</strong> ${email}</li>
        ${departmentsHtml}
      </ul>
      ${passwordHtml}
      <p>Si vous n'êtes pas à l'origine de cette modification, veuillez contacter l'administration immédiatement.</p>
      <p>Cordialement,</p>
      <p>L'administration de l'hôtel</p>
    `;
  } else {
    // Si l'action n'est ni 'create' ni 'update', on ne fait rien.
    console.log(`Action non reconnue: ${action}. Pas d'email envoyé.`);
    return;
  }

  const mailOptions = {
    from: `"Administration de l'hôtel" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: subject,
    html: htmlContent,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`Email envoyé avec succès à ${email}`);
  } catch (error) {
    console.error(`Erreur lors de l'envoi de l'email à ${email}:`, error);
    // On ne bloque pas le processus de création/mise à jour si l'email échoue
  }
};

module.exports = { sendUserCredentialsEmail }; 
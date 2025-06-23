const puppeteer = require('puppeteer');

const SITE_URL = 'https://reclamations-internes.vercel.app';

(async () => {
  const browser = await puppeteer.launch({ headless: false });
  const page = await browser.newPage();

  // Autoriser les notifications
  const context = browser.defaultBrowserContext();
  await context.overridePermissions(SITE_URL, ['notifications']);

  await page.goto(SITE_URL, { waitUntil: 'networkidle2' });
  await new Promise(r => setTimeout(r, 2000));

  console.log('Veuillez saisir manuellement le nom d\'utilisateur et le mot de passe, puis CLIQUEZ VOUS-MÊME sur "Se connecter". Le script va attendre 40 secondes pour récupérer le Player ID...');
  await new Promise(r => setTimeout(r, 40000));

  // Récupère le Player ID OneSignal
  let playerId = null;
  for (let i = 0; i < 60; i++) {
    playerId = await page.evaluate(() => {
      try {
        return window.OneSignal?.User?.pushSubscription?.id || null;
      } catch (e) { return null; }
    });
    if (playerId) break;
    await new Promise(r => setTimeout(r, 500));
  }

  if (playerId) {
    console.log('✅ Player ID OneSignal trouvé :', playerId);
  } else {
    console.log('❌ Player ID OneSignal non trouvé');
  }

  await browser.close();
})(); 
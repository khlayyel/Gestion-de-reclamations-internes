const https = require('https');

/**
 * Envoie une notification push via OneSignal.
 * @param {string[]} playerIds - Un tableau des player_id des destinataires.
 * @param {string} heading - Le titre de la notification.
 * @param {string} content - Le contenu du message.
 */
const sendNotification = (playerIds, heading, content) => {
  const data = {
    app_id: process.env.ONESIGNAL_APP_ID,
    include_player_ids: playerIds,
    headings: { en: heading },
    contents: { en: content },
  };

  const headers = {
    "Content-Type": "application/json; charset=utf-8",
    "Authorization": `Basic ${process.env.ONESIGNAL_REST_API_KEY}`
  };

  const options = {
    host: "onesignal.com",
    port: 443,
    path: "/api/v1/notifications",
    method: "POST",
    headers: headers
  };

  const req = https.request(options, function(res) {
    res.on('data', function(data) {
      console.log("OneSignal Response:");
      console.log(JSON.parse(data));
    });
  });

  req.on('error', function(e) {
    console.log("ERROR:");
    console.log(e);
  });

  req.write(JSON.stringify(data));
  req.end();
};

module.exports = { sendNotification }; 
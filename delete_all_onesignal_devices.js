const fetch = require('node-fetch');

// Remplace par tes vraies clés :
const APP_ID = '6ce72582-adbc-4b70-a16b-6af977e59707';
const API_KEY = 'os_v2_app_nttslavnxrfxbillnl4xpzmxa6uy6ibijgeecbmvtf7mjwdj6xfu67aiprk3ttwanesr6tzl2totdemvhxhovptuae3i2ha2qcbgmfq';

async function getAllPlayers() {
  let players = [];
  let offset = 0;
  let hasMore = true;
  while (hasMore) {
    const res = await fetch(`https://onesignal.com/api/v1/players?app_id=${APP_ID}&limit=300&offset=${offset}`, {
      headers: { 'Authorization': `Basic ${API_KEY}` }
    });
    const data = await res.json();
    players = players.concat(data.players);
    hasMore = data.players.length === 300;
    offset += 300;
  }
  return players;
}

async function deletePlayer(playerId) {
  const res = await fetch(`https://onesignal.com/api/v1/players/${playerId}?app_id=${APP_ID}`, {
    method: 'DELETE',
    headers: { 'Authorization': `Basic ${API_KEY}` }
  });
  if (res.status === 200 || res.status === 204) {
    console.log(`Supprimé: ${playerId}`);
  } else {
    console.log(`Erreur suppression ${playerId}: ${res.status}`);
  }
}

(async () => {
  const players = await getAllPlayers();
  console.log(`Nombre total de devices à supprimer: ${players.length}`);
  for (const p of players) {
    await deletePlayer(p.id);
  }
  console.log('Tous les devices ont été supprimés.');
})(); 
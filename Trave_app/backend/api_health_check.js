// backend/api_health_check.js
const fetch = require('node-fetch');

const apis = [
  'https://trave-app2-0.onrender.com/ai/chat',
'https://trave-app2-0.onrender.com/achievements',
'https://trave-app2-0.onrender.com/products',
'https://trave-app2-0.onrender.com/emergency/help',
'https://trave-app2-0.onrender.com/food/trace',
'https://trave-app2-0.onrender.com/music/compose',
'https://trave-app2-0.onrender.com/nft/mint'
];

(async () => {
  for (const url of apis) {
    try {
      const res = await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}' });
      const text = await res.text();
      let json;
      try { json = JSON.parse(text); } catch { json = null; }
      console.log(`[${res.status}] ${url} - ${json ? 'JSON OK' : 'Invalid JSON'}`);
    } catch (e) {
      console.log(`[ERROR] ${url} - ${e.message}`);
    }
  }
})(); 
'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "351db6122003eb93ec8b35bea0b1f5f4",
"assets/AssetManifest.bin.json": "4dc3d5065ff1d6cea7772ed61177899e",
"assets/AssetManifest.json": "6f97dabf5c0cb0f367d9eaf2ab325425",
"assets/assets/images/background/bg.png": "1ba623332b5107847637481c8482baa0",
"assets/assets/images/background/bg2.png": "25da19408fe47d7c14f311aa0719d186",
"assets/assets/images/background/bg3.jpg": "82700ded9e7883a966feda63ccf6fcea",
"assets/assets/images/background/bg4.png": "98d31b50362ff6cc54e9b2a62230fd5a",
"assets/assets/images/background/bg5.png": "84c7910bf5c82c1bbd9d9f4093e777eb",
"assets/assets/images/background/bg6.png": "f5ed73ef7f7b6ff56ef64aa64c793ba3",
"assets/assets/images/background/card1.jpg": "e41519a13d0524597b2615e5707b9626",
"assets/assets/images/background/card2.jpg": "b563aa4d7dafad37988b24b98a4d810f",
"assets/assets/images/background/icon_bg.png": "98de04fab9fe081ea04615d3838285a1",
"assets/assets/images/profile/character1.jpg": "2fa30a9c48542a97974e18c600acfea2",
"assets/assets/images/profile/character2.png": "135aae263055a7a7be20ffcc2f4c8a82",
"assets/assets/images/profile/character3.png": "43b8ae2a85f8c89b6d987ab28974f328",
"assets/assets/images/profile/character4.png": "17f74666eff259fc02df214d99cf39a2",
"assets/assets/images/profile/character5.png": "72b775282eee27fe33fb44d07a3cc489",
"assets/assets/images/profile/character6.png": "313e1082dcdf706023b146ed8a15d5b7",
"assets/assets/images/profile/character7.png": "b28456ebcc303d44584164f221d85752",
"assets/assets/images/profile/character8.png": "b5f919954dfc0ef050971bbba86ba47a",
"assets/assets/images/spots/%25E4%25BB%2580%25E5%2588%25B9%25E6%25B5%25B7%25E4%25B8%2587%25E5%25AE%2581%25E6%25A1%25A5.png": "c8a61d2d9cec259bdaafa0fe9059c931",
"assets/assets/images/spots/%25E5%2585%2588%25E5%2586%259C%25E5%259D%259B.png": "c45b6e222bd27a156f9a1135f1e43de7",
"assets/assets/images/spots/%25E5%2589%258D%25E9%2597%25A8.png": "308bd72e64225e9a66c7eb783fcc2dc8",
"assets/assets/images/spots/%25E5%25A4%25A9%25E5%259D%259B.png": "96076022eb3d735583dfa37b8bed3d35",
"assets/assets/images/spots/%25E6%2595%2585%25E5%25AE%25AB.png": "90a780c1c71be150a692615ee72bde6e",
"assets/assets/images/spots/%25E6%25B0%25B8%25E5%25AE%259A%25E9%2597%25A8.png": "02c0c53ab69f9ca1d66452e38035c2aa",
"assets/assets/images/spots/%25E9%2592%259F%25E9%25BC%2593%25E6%25A5%25BC.png": "ab972f1c9d071e5f328b52f409b2a1d9",
"assets/assets/images/spots/zhongzhou_music2.png": "b902f0f2abba37b1dba6cd1683f088b3",
"assets/assets/images/tmp/1.jpg": "abfe821a1533ed1fbf01d890fb5f1068",
"assets/assets/images/tmp/2.jpg": "e9a8dd9e2e0902d6de6c230d23a5a127",
"assets/assets/images/tmp/3.jpg": "2ddc4ebfbad8a207f6149c49db6bdfba",
"assets/assets/images/tmp/4.png": "8e760e937e8cf0db725e78bf8452331f",
"assets/assets/images/tmp/5.jpg": "b8152b2f8ea37e7a85c32dc1c3f7ae7c",
"assets/assets/images/tmp/6.jpg": "fb5b46af1328abef421c19b8e355777e",
"assets/assets/images/tmp/7.jpg": "6435d5b0c438723bb7f99c728727cef7",
"assets/assets/images/tmp/8.jpg": "c07900a49e73c05596be0fd0d5ceb09a",
"assets/assets/images/tmp/9.jpg": "978a3e5c52e7c9952c3ea26bd3bffff6",
"assets/assets/images/zhimeizhai.png": "03e3f9d928c9361afd046169545e579c",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "929f20a8bb389197c54b67b870becb56",
"assets/NOTICES": "b642538504f32bd1112fcd6388bcb662",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/record_web/assets/js/record.fixwebmduration.js": "1f0108ea80c8951ba702ced40cf8cdce",
"assets/packages/record_web/assets/js/record.worklet.js": "356bcfeddb8a625e3e2ba43ddf1cc13e",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "127cc778b5c522c40c02a1827306673a",
"/": "127cc778b5c522c40c02a1827306673a",
"main.dart.js": "a12dc15ebdba2a8e69da1c0487270228",
"manifest.json": "2e039f827aecd89660e028d3c62ddd56",
"version.json": "fc784168e49bd2071a1914f7a2ecd047"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}

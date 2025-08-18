'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "3185def7f7637a5b1d5618aeecbdf7e8",
"assets/AssetManifest.bin.json": "4eb4577a8e0fe18362eb6b43f8304949",
"assets/AssetManifest.json": "f3599c846b27955c1d9c7f81811c598c",
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
"assets/assets/images/spots/gugong.png": "90a780c1c71be150a692615ee72bde6e",
"assets/assets/images/spots/qianmen.png": "308bd72e64225e9a66c7eb783fcc2dc8",
"assets/assets/images/spots/shichahai_wanningqiao.png": "c8a61d2d9cec259bdaafa0fe9059c931",
"assets/assets/images/spots/tiantan.png": "96076022eb3d735583dfa37b8bed3d35",
"assets/assets/images/spots/xiannongtan.png": "c45b6e222bd27a156f9a1135f1e43de7",
"assets/assets/images/spots/yongdingmen.png": "02c0c53ab69f9ca1d66452e38035c2aa",
"assets/assets/images/spots/zhonggulou.png": "ab972f1c9d071e5f328b52f409b2a1d9",
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
"assets/assets/videos/zhongzhou.mp4": "899e2b02e8219e501c49a9dc6721faa8",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "34ccefd34babb6bfb72c1b715e7549b8",
"assets/NOTICES": "1b4dfecb87b24c9fc46d1c44bf528a2a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/record_web/assets/js/record.fixwebmduration.js": "1f0108ea80c8951ba702ced40cf8cdce",
"assets/packages/record_web/assets/js/record.worklet.js": "6d247986689d283b7e45ccdf7214c2ff",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "2018f2ff04eff1938bb44ad20cc36e4c",
"index.html": "9de89a0c77816399ab5bb1a204fd37f5",
"/": "9de89a0c77816399ab5bb1a204fd37f5",
"main.dart.js": "a12dc15ebdba2a8e69da1c0487270228",
"manifest.json": "2e039f827aecd89660e028d3c62ddd56",
"version.json": "fc784168e49bd2071a1914f7a2ecd047"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
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

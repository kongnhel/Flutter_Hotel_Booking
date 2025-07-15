'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "c3d7d0647acc6bd4106c4f274612129a",
"assets/AssetManifest.bin.json": "6d36191e6a61034ff4cb1ceca9ac1f36",
"assets/AssetManifest.json": "5d0d95998015781b1d1edad3f0ec1d28",
"assets/assets/icons/bed.svg": "625e40f1063034a1ac92bedb172462ee",
"assets/assets/icons/bell.svg": "1f7bbd833bdda4b2e758d41bc8c0ad02",
"assets/assets/icons/bin.svg": "3737f814d3fcdcda76b83c2b17393ab4",
"assets/assets/icons/booking.svg": "46851702dfd5d0d47e96afb3b2f54ee4",
"assets/assets/icons/call.svg": "78625de1925bad7c9362b81b4662907e",
"assets/assets/icons/camera.svg": "05599a237f6a6d343923e1650f6b004c",
"assets/assets/icons/car.svg": "65daa5c5ccef0e6dbb0444f4caf3cd58",
"assets/assets/icons/clock.svg": "498685a292428c9a11f7466c77bd5243",
"assets/assets/icons/edit.svg": "356822dcf334d4222d067b67dd15b6bd",
"assets/assets/icons/exit.svg": "43013171377aaa5a421e451bfeaf941e",
"assets/assets/icons/explore.svg": "959f67502284c1b9bc65ef2e4cb4881b",
"assets/assets/icons/favorite-border.svg": "ec6223055097995a57e4bc7153d946dd",
"assets/assets/icons/favorite.svg": "c9c64fe77dc11781142a50ca9349267d",
"assets/assets/icons/favorited.svg": "39d0754668854beed46ad1504520620f",
"assets/assets/icons/filter.svg": "3d975fa561612ca70706af801212fb93",
"assets/assets/icons/food.svg": "26def81471b2d0d8183fc9198ba6e00b",
"assets/assets/icons/gift.svg": "1344e9a998672c5bf969a6f9ed795d90",
"assets/assets/icons/home.svg": "133ce3f86906cf46c6618abb24212cfe",
"assets/assets/icons/hotel.svg": "b2e3eda097c978d09faebca7a62ce5a3",
"assets/assets/icons/info.svg": "d42f796dc3223d212786a82208f09d64",
"assets/assets/icons/lock.svg": "d793844b39448b685f3424ec2598af15",
"assets/assets/icons/pin-area.svg": "ffd19f1bf2af817a3c03b86675530fd5",
"assets/assets/icons/pin.svg": "0cd3348f80b7660fd74455c5ee68193a",
"assets/assets/icons/pool.svg": "bf11d50fa516470d108579cefd378728",
"assets/assets/icons/search.svg": "b43c3e6d723a24f2d3645ecbf430fadf",
"assets/assets/icons/setting.svg": "0844b197c4f18213fc3a97e703f1acd8",
"assets/assets/icons/shield.svg": "eaba61706b0f78bf84f58d1b9838c9dc",
"assets/assets/icons/snack.svg": "d44593f24cad82d018d1b356cc471517",
"assets/assets/icons/wifi.svg": "8a3f1dac962d6309be6f264ac76bd600",
"assets/assets/images/booking_hotel_logo.png": "b59d4518425675460bf8ae115860caae",
"assets/assets/images/kong.jpg": "79fb940c57dbe38fc4936d59654db461",
"assets/assets/images/logo_2.png": "97b4823d4efcec00baf1781d3d325be4",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "dfb5e947606e78101367ea2b126e6a46",
"assets/NOTICES": "71d912033a4d038cc6602fffe0a8f8cc",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "e2fe1d3a2b0aab99446a7414fc09148d",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "d19cec3cc262aa3e96d7c964f2afba5c",
"/": "d19cec3cc262aa3e96d7c964f2afba5c",
"main.dart.js": "c047cda1f70bbc9061e58788c3bc0361",
"manifest.json": "29cc6ddf67fa3a38e3b03fa0990c4ee6",
"version.json": "994029a9378629a262c96e5a8be9609c"};
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

// Firebase Cloud Messaging Service Worker
// Đây là file cần thiết để FCM hoạt động trên web

importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

// Initialize Firebase trong service worker
firebase.initializeApp({
  apiKey: 'AIzaSyAqzATgT5NNhigt5TutL2hI1dL4lp2QHRc',
  appId: '1:1062697430678:web:261ee82429df2e1aa95cb7',
  messagingSenderId: '1062697430678',
  projectId: 'fridge-to-fork-a17de',
  authDomain: 'fridge-to-fork-a17de.firebaseapp.com',
  storageBucket: 'fridge-to-fork-a17de.firebasestorage.app',
  measurementId: 'G-RG88L92YN8',
});

// Retrieve an instance of Firebase Messaging
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);
  
  const notificationTitle = payload.notification?.title || 'Fridge to Fork';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

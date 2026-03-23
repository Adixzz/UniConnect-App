importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

// Replace this with your actual Firebase Web Config from the console
firebase.initializeApp({
  apiKey: "AIzaSyBPCcOI9m8KNHyBGmypjJ4z8zLUlxXlVWc",
  authDomain: "uniconnect-133ae.firebaseapp.com",
  projectId: "uniconnect-133ae",
  storageBucket: "uniconnect-133ae.firebasestorage.app",
  messagingSenderId: "707990130657",
  appId: "1:707990130657:web:02d0edce80648722dccca0",
});

const messaging = firebase.messaging();

// Handle background notifications
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/firebase-logo.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
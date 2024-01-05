importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");

//Using singleton breaks instantiating messaging()
// App firebase = FirebaseWeb.instance.app;


firebase.initializeApp({
    apiKey: "AIzaSyBsaWvigCHqSPPBIHabwZiCWgCmte2O6sY",
    authDomain: "snack-dating-2981c.firebaseapp.com",
    databaseURL: "https://snack-dating-2981c.firebaseio.com",
    projectId: "snack-dating-2981c",
    storageBucket: "snack-dating-2981c.appspot.com",
    messagingSenderId: "930184663597",
    appId: "1:930184663597:web:162f3af2423081edfb1ea4",
    measurementId: "G-Q6DJ9JJLLN"
});


const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);
});
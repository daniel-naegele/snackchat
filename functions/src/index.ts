import * as functions from 'firebase-functions';
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

exports.chatNotification = functions.firestore
    .document('chats/{chatId}').onUpdate((change, context) => {
        const currentData = change.after.data();
        const previousMessages = change.before.data().messages;
        const currentMessages = currentData.messages;
        if (currentMessages === undefined) return -1;
        if (previousMessages !== undefined && previousMessages.length === currentMessages.length) return -1;
        const newMessage = currentMessages[currentMessages.length - 1];
        const members = currentData.members;
        const author = newMessage.author;
        const targetIndex = members.indexOf(author) === 0 ? 1 : 0;
        return db.doc('users/' + members[targetIndex]).get().then((result: FirebaseFirestore.DocumentData) => {
            if (!result.exists) return -1;
            const blocked = result.data().blocked;
            if (blocked !== undefined) {
                if (blocked.includes(author)) return -1;
            }
            const fcm = result.data().fcm;
            if (fcm === undefined) return -1;
            const message = {
                data: {
                    id: change.after.id,
                    type: 'accepted',
                },
                token: fcm,
                notification: {
                    title: 'Chat: ' + author,
                    body: newMessage.text,
                },
                apns: {
                    payload: {
                        aps: {
                            sound: "default",
                        }
                    }
                }
            };

            admin.messaging().send(message)
                .then((response: any) => {
                    // Response is a message ID string.
                    console.log('Successfully sent message: ', response);
                })
                .catch((error: any) => {
                    console.log('Error sending message: ', error);
                });
            return 0;
        });
    });
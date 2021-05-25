import * as functions from 'firebase-functions';
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

exports.chatNotification = functions
    .region('europe-west3')
    .firestore
    .document('chats/{chatId}/messages/{messageId}')
    .onCreate(async (snapshot, context) => {
        const newMessage = snapshot.data();
        const author = newMessage.author;
        const chatRef = db.doc('chats/' + snapshot.ref.parent.parent?.id);

        await chatRef.update({last_message: newMessage.timestamp});

        const chat = await chatRef.get();
        const members = chat.data()?.members;
        const targetIndex = members.indexOf(author) === 0 ? 1 : 0;

        const targetUser = await db.doc('users/' + members[targetIndex]).get();

        if (!targetUser.exists) return -1;
        const blocked = targetUser.data()?.blocked;
        if (blocked !== undefined) {
            if (blocked.includes(author)) return -1;
        }

        const fcm = targetUser.data()?.fcm;
        if (fcm === undefined || fcm === '') return -1;

        const message = {
            data: {
                id: chat.id,
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
                console.log('Successfully sent message: ', response);
            })
           .catch((error: any) => {
              console.log('Error sending message: ', error);
           });
        return 0;
    });
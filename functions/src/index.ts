import * as functions from 'firebase-functions';
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

exports.reportMail = functions
    .region('europe-west3')
    .firestore
    .document('reports/{reportId}')
    .onCreate(async (snapshot, context) => {
        const report = snapshot.data();
        const by = report.by;
        const reported = report.reported;

        const chatQuery = await db.collection('chats')
            .where('members', 'array-contains', reported)
            .get();

        const chat =  chatQuery.docs.find(data => data.data().members.includes(by));

        // @ts-ignore
        const messages = await db.collection('/chats/' + chat.id + '/messages').orderBy('timestamp', 'desc').get();

        var body = '';
        messages.docs.forEach((msg) => {
            body = body.concat('Author: ' + msg.data().author + '</br>');
            body = body.concat('Time: ' + msg.data().timestamp.toDate().toISOString() + '</br>');
            body = body.concat('Text: ' + msg.data().text + '</br></br>');
        });

        await admin.firestore().collection('mail').add({
            to: 'info@naegele.dev',
            from: 'noreply@naegele.dev',
            message: {
                subject: 'SnackChat Report ' + snapshot.id,
                html: 'Report by ' + by + '. Reported: ' + reported + '</br></br></br>' + body,
            },
        });

        return 0;
    });

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


exports.chatCreateNotification = functions
    .region('europe-west3')
    .firestore
    .document('chats/{chatId}')
    .onCreate(async (snapshot, context) => {
        const data = snapshot.data();


        const creator = data.members[0];
        const targetUser = await db.doc('users/' + data.members[1]).get();

        if (!targetUser.exists) return -1;

        const blocked = targetUser.data()?.blocked;
        if (blocked !== undefined) {
            if (blocked.includes(creator)) return -1;
        }

        const fcm = targetUser.data()?.fcm;
        if (fcm === undefined || fcm === '') return -1;

        const message = {
            data: {
                id: snapshot.id,
                type: 'accepted',
            },
            token: fcm,
            notification: {
                title: 'New chat',
                body: 'A user has started a new chat with you',
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
                console.log('Successfully sent chat create notification: ', response);
            })
            .catch((error: any) => {
                console.log('Error sending chat create notification: ', error);
            });
        return 0;
    });
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:snack_dating/composition/components.dart';
import 'package:snack_dating/db_schema/chat.dart';
import 'package:snack_dating/screens/chat_page.dart';

class Chats extends HookWidget {
  final box = Hive.box('snack_box');
  late final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  late final blocked;

  Chats() {
    stream = FirebaseFirestore.instance
        .collection('chats')
        .where('members', arrayContains: box.get('uid'))
        .orderBy('last_message', descending: true)
        .snapshots();
    blocked = box.get('blocked') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>?> snapshot =
        useStream(stream);
    if (!snapshot.hasData) return Center(child: Text('Loading...'));
    final querySnapshot = snapshot.data!;
    List<ChatMetadata> documents = querySnapshot.docs.map((e) {
      final data = ChatMetadata.fromJson(e.data());
      data.id = e.id;
      return data;
    }).toList();

    documents.removeWhere((element) {
      return blocked.contains(getOtherUser(element.members));
    });

    if (documents.length == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            AppLocalizations.of(context)!.noChats,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

    return ChatList(chats: documents);
  }

  String getOtherUser(List members) {
    final uid = box.get('uid');
    members.removeWhere((element) => element == uid);
    String id = members[0];
    return id;
  }
}

class ChatList extends StatefulWidget {
  final List<ChatMetadata> chats;

  const ChatList({Key? key, required this.chats}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  Widget _chat = Container();

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    final isWideScreen = data.size.width > 720;
    return Row(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 120, maxWidth: 360),
          child: ListView.builder(
            itemCount: widget.chats.length,
            itemBuilder: (context, index) {
              final chat = widget.chats[index];
              return ChatTile(
                chatMetadata: chat,
                callback: () => !isWideScreen
                    ? Navigator.pushNamed(
                        context,
                        '/chats/${chat.id}',
                      )
                    : setChat(chat.id!),
              );
            },
          ),
        ),
        if (isWideScreen) ...[
          VerticalDivider(
            thickness: 2,
            width: 2,
          ),
          _chat,
        ]
      ],
    );
  }

  setChat(String id) {
    setState(() {
      _chat = Expanded(
        child: ChatPage(id),
      );
    });
  }
}

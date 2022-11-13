import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/screen/chat_screen.dart';
import 'package:flutter_chat_app/screen/group/group_info.dart';

class GroupChatScreen extends StatelessWidget {
  GroupChatScreen({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController msg = TextEditingController();

  List<Map<String, dynamic>> dummy = [
    {"message": 'Dis Nut created group "Group Name"', "type": "notif"},
    {"message": "Text 1", "sendby": "one", "type": "text"},
    {"message": "Text 2", "sendby": "two", "type": "text"},
    {"message": "Text 3", "sendby": "a", "type": "text"},
    {"message": "Text 4", "sendby": "four", "type": "text"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Group Name"), actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GroupInfo(),
                  )),
              icon: const Icon(Icons.more_vert))
        ]),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder<QuerySnapshot>(
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (true) {
                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        itemCount: dummy.length,
                        itemBuilder: (context, index) {
                          return messages(dummy[index], context);
                        },
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              typeMessage()
            ]));
  }

  // void send() async {
  //   Map<String, dynamic> messages = {
  //     "sendby": _auth.currentUser!.displayName,
  //     "message": msg.text,
  //     "type": "text",
  //     "time": FieldValue.serverTimestamp()
  //   };

  //   await _firestore
  //       .collection('chatroom')
  //       .doc(chatRoomId)
  //       .collection("chats")
  //       .add(messages);
  // }

  Widget typeMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Material(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
            elevation: 5,
            child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2, bottom: 2),
                child: TextField(
                  controller: msg,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () => null,
                        icon: const Icon(Icons.photo_library)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    hintText: 'Type your message here...',
                    hintStyle: const TextStyle(fontSize: 14),
                    border: InputBorder.none,
                  ),
                )),
          )),
          MaterialButton(
            shape: const CircleBorder(),
            color: Colors.blue,
            onPressed: () {
              if (msg.text.isNotEmpty) {
                //send();
                msg.clear();
              }
            },
            child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.send, color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget messages(Map<String, dynamic> map, BuildContext context) {
    //map["type"] == "img" ? tag = map['message'] : null;
    return Padding(
        padding: const EdgeInsets.all(12),
        child: map['type'] == "notif"
            ? notif(map, context)
            : chatBubble(map, context));
  }

  Widget chatBubble(Map<String, dynamic> map, BuildContext context) {
    bool user = (map['sendby'] == _auth.currentUser!.displayName);
    return Column(
      crossAxisAlignment:
          user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(map['sendby'],
                style: const TextStyle(color: Colors.black87))),
        Material(
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(50),
            topLeft:
                user ? const Radius.circular(50) : const Radius.circular(0),
            bottomRight: const Radius.circular(50),
            topRight:
                user ? const Radius.circular(0) : const Radius.circular(50),
          ),
          color: user ? Colors.blue : Colors.white,
          elevation: 5,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: map["type"] == "text"
                  ? Text(
                      map['message'],
                      style: TextStyle(
                        color: user ? Colors.white : Colors.blue,
                        fontSize: 15,
                      ),
                    )
                  : SizedBox(
                      height: 280,
                      width: 150,
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ShowImage(
                              imageUrl: map['message'],
                            ),
                          ),
                        ),
                        child: map['message'] != ""
                            ? Hero(
                                tag: tag,
                                child: Image.network(
                                  map['message'],
                                  fit: BoxFit.scaleDown,
                                ),
                              )
                            : const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                      ),
                    )),
        )
      ],
    );
  }

  Widget notif(Map<String, dynamic> map, BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
        Widget>[
      Material(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          color: Colors.blueGrey,
          elevation: 5,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                map['message'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ))),
      const SizedBox(
        height: 10,
      )
    ]);
  }
}

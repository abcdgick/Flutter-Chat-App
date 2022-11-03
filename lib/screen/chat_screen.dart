import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController msg = TextEditingController();
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatScreen({super.key, required this.userMap, required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(userMap['name'])),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatroom')
                  .doc(chatRoomId)
                  .collection("chats")
                  .orderBy("time", descending: false)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.data != null) {
                  return Expanded(
                    child: ListView.builder(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        return messages(map);
                      },
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            Container(
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
                        padding:
                            const EdgeInsets.only(left: 8.0, top: 2, bottom: 2),
                        child: TextField(
                          controller: msg,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            hintText: 'Type your message here...',
                            hintStyle: TextStyle(fontSize: 14),
                            border: InputBorder.none,
                          ),
                        )),
                  )),
                  MaterialButton(
                    shape: const CircleBorder(),
                    color: Colors.blue,
                    onPressed: () {
                      if (msg.text.isNotEmpty) {
                        send();
                        msg.clear();
                      }
                    },
                    child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(Icons.send, color: Colors.white)),
                  )
                ],
              ),
            )
          ],
        ));
  }

  void send() async {
    Map<String, dynamic> messages = {
      "sendby": _auth.currentUser!.displayName,
      "message": msg.text,
      "time": FieldValue.serverTimestamp()
    };

    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection("chats")
        .add(messages);
  }

  Widget messages(Map<String, dynamic> map) {
    bool user = (map['sendby'] == _auth.currentUser!.displayName);
    print(user);
    return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(map['sendby'],
                    style: const TextStyle(color: Colors.black87))),
            Material(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                topLeft: user ? Radius.circular(50) : Radius.circular(0),
                bottomRight: Radius.circular(50),
                topRight: user ? Radius.circular(0) : Radius.circular(50),
              ),
              color: user ? Colors.blue : Colors.white,
              elevation: 5,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  map['message'],
                  style: TextStyle(
                    color: user ? Colors.white : Colors.blue,
                    fontFamily: 'Poppins',
                    fontSize: 15,
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

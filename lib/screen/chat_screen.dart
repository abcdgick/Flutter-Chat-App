import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/screen/user_screen.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:uuid/uuid.dart';

var tag;

class ChatScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController msg = TextEditingController();
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  Uint8List? imageFile;

  ChatScreen({super.key, required this.userMap, required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          titleSpacing: 0,
          title: StreamBuilder<DocumentSnapshot>(
            stream:
                _firestore.collection("users").doc(userMap["uid"]).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return Row(
                  children: [
                    ClipOval(
                      child: SizedBox.fromSize(
                        size: const Size.fromRadius(22),
                        child: Image.network(
                          userMap['profile'],
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(userMap["name"],
                            style: const TextStyle(fontSize: 18)),
                        Text(snapshot.data!["status"],
                            style: const TextStyle(fontSize: 12))
                      ],
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
          actions: <Widget>[
            IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserProfile(
                        profile: userMap["profile"],
                        about: userMap["about"],
                        name: userMap["name"],
                        email: userMap["email"],
                      ),
                    )),
                icon: const Icon(Icons.more_vert))
          ]),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('chatroom')
                .doc(chatRoomId)
                .collection("chats")
                .orderBy("time", descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data != null) {
                return Expanded(
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> map = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      return messages(map, context);
                    },
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
          typeMessage(),
        ],
      ),
    );
  }

  void send() async {
    Map<String, dynamic> messages = {
      "sendby": _auth.currentUser!.displayName,
      "message": msg.text,
      "type": "text",
      "time": FieldValue.serverTimestamp()
    };

    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection("chats")
        .add(messages);
  }

  Widget messages(Map<String, dynamic> map, BuildContext context) {
    bool user = (map['sendby'] == _auth.currentUser!.displayName);
    map["type"] == "img" ? tag = map['message'] : null;
    return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
        ));
  }

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
                        onPressed: () => getImage(),
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
    );
  }

  Future getImage() async {
    imageFile = await ImagePickerWeb.getImageAsBytes();
    if (imageFile != null) uploadImage();
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    UploadTask uploadTask =
        ref.putData(imageFile!, SettableMetadata(contentType: 'image/jpg'));
    TaskSnapshot taskSnapshot = await uploadTask
        .whenComplete(() => print('Done'))
        .catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(),
      body: Hero(
        tag: tag,
        child: Container(
          height: size.height,
          width: size.width,
          color: Colors.black,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}

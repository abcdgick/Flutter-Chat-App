import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/screen/group/list_group.dart';
import 'package:flutter_chat_app/screen/home_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';

class AddMembers extends StatefulWidget {
  const AddMembers({super.key});

  @override
  State<AddMembers> createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Create Group');
  bool _isLoading = false;
  Map<String, dynamic>? userMap;

  final TextEditingController gname = TextEditingController();
  final TextEditingController search = TextEditingController();

  List<Map<String, dynamic>> memberList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: customSearchBar,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = const Icon(Icons.cancel);
                    customSearchBar = ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.search),
                        color: Colors.white,
                        onPressed: () {
                          onSearch(search.text);
                        },
                      ),
                      title: TextField(
                        decoration: const InputDecoration(
                          hintText: 'type in account email...',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        controller: search,
                      ),
                    );
                  } else {
                    customIcon = const Icon(Icons.search);
                    customSearchBar = const Text('Create Group');
                    search.clear();
                  }
                });
              },
              icon: customIcon)
        ],
      ),
      body: _isLoading
          ? const LoadingBody()
          : ListView.builder(
              itemCount: memberList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.account_circle),
                  title: Text(memberList[index]["name"]),
                  subtitle: Text(memberList[index]["email"]),
                  trailing: IconButton(
                      onPressed: () => remove(index),
                      icon: const Icon(Icons.close)),
                );
              },
            ),
      floatingActionButton: memberList.length >= 2
          ? FloatingActionButton(
              child: const Icon(Icons.forward),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Group Name"),
                    content: TextField(
                      controller: gname,
                      decoration: const InputDecoration(hintText: "Group name"),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("CANCEL"),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            createGroup();
                          },
                          child: const Text("CREATE"))
                    ],
                  ),
                );
              },
            )
          : const SizedBox(),
    );
  }

  void onSearch(String text) async {
    bool exist = false;
    setState(() {
      _isLoading = true;
    });
    await _firestore
        .collection("users")
        .where("email", isEqualTo: text)
        .get()
        .then(
      (value) {
        setState(() {
          if (value.size != 0) {
            userMap = value.docs[0].data();
            for (int i = 0; i < memberList.length; i++) {
              if (memberList[i]["uid"] == userMap!["uid"]) {
                exist = true;
              }
            }
            if (!exist) {
              memberList.add({
                "name": userMap!["name"],
                "email": userMap!["email"],
                "uid": userMap!["uid"],
                "isAdmin": false
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User already in group'),
                ),
              );
            }
            userMap = null;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User does not exists'),
              ),
            );
          }
          _isLoading = false;
        });
      },
    );
  }

  void getCurrentUserDetail() async {
    await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        memberList.add({
          "name": value["name"],
          "email": value["email"],
          "uid": value["uid"],
          "isAdmin": true,
        });
      });
    });
  }

  void remove(int index) {
    if (!memberList[index]["isAdmin"]) {
      setState(() {
        memberList.removeAt(index);
      });
    }
  }

  void createGroup() async {
    setState(() {
      _isLoading = true;
    });

    String groupId = Uuid().v1();

    await _firestore.collection('groups').doc(groupId).set({
      "members": memberList,
      "id": groupId,
      "profile":
          "https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-jokris.appspot.com/o/profiles%2FGroup.jpg?alt=media&token=0903f306-9761-4bbb-9413-693c65966a5c"
    });

    for (int i = 0; i < memberList.length; i++) {
      String uid = memberList[i]['uid'];

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(groupId)
          .set({
        "name": gname.text,
        "id": groupId,
      });
    }

    await _firestore.collection('groups').doc(groupId).collection('chats').add({
      "message":
          "${_auth.currentUser!.displayName} Created Group ${gname.text}",
      "type": "notif",
      "time": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Group ${gname.text} successfully created"),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => GroupList()), (route) => false);
  }
}

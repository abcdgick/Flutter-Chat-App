import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/screen/group/add_members.dart';
import 'package:flutter_chat_app/screen/group/chat_screen.dart';
import 'package:flutter_chat_app/screen/home_screen.dart';

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List groupList = [];
  bool _isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Groups")),
      body: _isLoading
          ? const LoadingBody()
          : ListView.builder(
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                return ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => GroupChatScreen(
                              groupName: groupList[index]["name"],
                              groupId: groupList[index]["id"],
                            ))),
                    leading: const Icon(Icons.group),
                    title: Text(groupList[index]["name"]));
              },
            ),
      floatingActionButton: FloatingActionButton(
          tooltip: "Create Group",
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddMembers())),
          child: const Icon(Icons.add)),
    );
  }

  void getGroup() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection("users")
        .doc(uid)
        .collection("groups")
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        _isLoading = false;
      });
    });
  }
}

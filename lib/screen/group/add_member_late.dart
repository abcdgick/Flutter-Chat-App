import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/screen/home_screen.dart';

class AddMemberLate extends StatefulWidget {
  final String groupId, groupName;
  List memberList;
  AddMemberLate(
      {required this.groupId,
      required this.groupName,
      required this.memberList,
      super.key});

  @override
  State<AddMemberLate> createState() => _AddMemberLateState();
}

class _AddMemberLateState extends State<AddMemberLate> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Add Member');
  Map<String, dynamic>? userMap;
  bool _isLoading = false;
  List memberListTemp = [];
  List newMember = [];

  final TextEditingController search = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    memberListTemp = widget.memberList;
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
                      customSearchBar = const Text('Add Member');
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
                itemCount: memberListTemp.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {},
                    leading: const Icon(Icons.account_circle),
                    title: Text(memberListTemp[index]["name"]),
                    subtitle: Text(memberListTemp[index]["email"]),
                  );
                },
              ),
        floatingActionButton: newMember.isNotEmpty
            ? FloatingActionButton(
                child: const Icon(Icons.forward),
                onPressed: () {
                  addMember();
                  Navigator.of(context).pop();
                },
              )
            : const SizedBox());
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
            for (int i = 0; i < memberListTemp.length; i++) {
              if (memberListTemp[i]["uid"] == userMap!["uid"]) {
                exist = true;
              }
            }
            if (!exist) {
              memberListTemp.add({
                "name": userMap!["name"],
                "email": userMap!["email"],
                "uid": userMap!["uid"],
                "isAdmin": false
              });

              newMember.add({
                "name": userMap!["name"],
                "email": userMap!["email"],
                "uid": userMap!["uid"],
                "isAdmin": false
              });
            }
            userMap = null;
          }
          _isLoading = false;
        });
      },
    );
  }

  void addMember() async {
    await _firestore
        .collection("groups")
        .doc(widget.groupId)
        .update({"members": memberListTemp});

    for (var member in newMember) {
      await _firestore
          .collection('users')
          .doc(member['uid'])
          .collection('groups')
          .doc(widget.groupId)
          .set({"name": widget.groupName, "id": widget.groupId});
    }
  }
}

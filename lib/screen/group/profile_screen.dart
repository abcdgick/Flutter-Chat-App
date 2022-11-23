import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/screen/home_screen.dart';
import 'package:flutter_chat_app/screen/profile_screen.dart';

class GroupProfile extends StatefulWidget {
  final bool isAdmin;
  final String groupId;
  String groupName;
  GroupProfile(
      {required this.isAdmin,
      required this.groupId,
      required this.groupName,
      super.key});

  @override
  State<GroupProfile> createState() => _GroupProfileState();
}

class _GroupProfileState extends State<GroupProfile> {
  bool _isLoading = false;

  var tag;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group ${widget.groupName} Profile"),
      ),
      body: _isLoading
          ? const LoadingBody()
          : SingleChildScrollView(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection("groups")
                    .doc(widget.groupId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    tag = snapshot.data!["profile"];
                    return Container(
                      padding: const EdgeInsets.all(10.0),
                      height: MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          kBottomNavigationBarHeight,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                tag = snapshot.data!['profile'];
                                Navigator.of(context)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (_) => SaveImage(
                                        imageUrl: snapshot.data!['profile'],
                                        tag: tag,
                                        collection: "groups",
                                        doc: widget.groupId,
                                        isAdmin: widget.isAdmin),
                                  ),
                                )
                                    .then((value) {
                                  setState(() {});
                                });
                              },
                              child: Hero(
                                tag: snapshot.data!['profile'],
                                child: ClipOval(
                                  child: SizedBox.fromSize(
                                    size: const Size.fromRadius(120),
                                    child: Image.network(
                                      snapshot.data!['profile'],
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              )),
                          vSpace(50),
                          tile(),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
    );
  }

  void save(String name) async {
    List memberList = [];
    setState(() {
      _isLoading = true;
      widget.groupName = name;
    });

    await _firestore
        .collection("groups")
        .doc(widget.groupId)
        .get()
        .then(((value) {
      memberList = value["members"];
    }));

    for (var member in memberList) {
      await _firestore
          .collection('users')
          .doc(member["uid"])
          .collection('groups')
          .doc(widget.groupId)
          .update({
        "name": name,
      });
    }

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Group name has been updated'),
      ),
    );
  }

  Widget vSpace(double d) {
    return SizedBox(height: d);
  }

  Widget tile() {
    return ListTile(
      leading: const Icon(Icons.group_outlined),
      title: const Text("Name",
          style: TextStyle(color: Colors.black54, fontSize: 15)),
      subtitle: Text(widget.groupName,
          style: const TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
      trailing: widget.isAdmin
          ? IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.blueGrey,
              ),
              onPressed: () {
                textEditingController.text = widget.groupName;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Edit your Group Name"),
                    content: TextFormField(
                      controller: textEditingController,
                      decoration:
                          const InputDecoration(hintText: "Your Group Name"),
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
                            if (textEditingController.text !=
                                    widget.groupName &&
                                textEditingController.text != "") {
                              save(textEditingController.text);
                            }
                          },
                          child: const Text("SAVE"))
                    ],
                  ),
                );
              },
            )
          : null,
    );
  }
}

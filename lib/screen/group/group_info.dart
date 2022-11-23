import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/screen/group/add_member_late.dart';
import 'package:flutter_chat_app/screen/group/profile_screen.dart';
import 'package:flutter_chat_app/screen/home_screen.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName;
  const GroupInfo({required this.groupId, required this.groupName, super.key});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  List memberList = [];
  String profileUrl = "";
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 200,
            actions: [
              checkAdmin()
                  ? PopupMenuButton<String>(
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: const Text("Edit Group Info"),
                            onTap: () =>
                                WidgetsBinding.instance.addPostFrameCallback(
                              (timeStamp) => Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                    builder: (context) => GroupProfile(
                                          isAdmin: checkAdmin(),
                                          groupId: widget.groupId,
                                          groupName: widget.groupName,
                                        )),
                              )
                                  .then((value) {
                                setState(() {});
                              }),
                            ),
                          ),
                          PopupMenuItem(
                            child: const Text("Delete Group"),
                            onTap: () =>
                                WidgetsBinding.instance.addPostFrameCallback(
                              (timeStamp) => delete(),
                            ),
                          )
                        ];
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => GroupProfile(
                                  isAdmin: checkAdmin(),
                                  groupId: widget.groupId,
                                  groupName: widget.groupName,
                                )),
                      ),
                    )
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.groupName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              background: profileUrl == ""
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Image.network(
                      profileUrl,
                      fit: BoxFit.fitHeight,
                    ),
            ),
          ),
          SliverToBoxAdapter(
              child: SizedBox(
            height: 50,
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      "${memberList.length} members",
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          )),
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ListTile(
                onTap: () {},
                leading: const Icon(Icons.account_circle),
                title: Text(memberList[index]["name"]),
                subtitle: Text(memberList[index]["email"]),
                trailing: memberList[index]["isAdmin"]
                    ? const Text(
                        "Admin",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                      )
                    : checkAdmin()
                        ? IconButton(
                            onPressed: () => removeMember(index),
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ))
                        : const SizedBox(),
              );
            },
            childCount: memberList.length,
          ))
        ],
      ),
      floatingActionButton: checkAdmin()
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => AddMemberLate(
                              groupId: widget.groupId,
                              groupName: widget.groupName,
                              memberList: memberList,
                            )))
                    .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Users Successfully Added'),
                          ),
                        ))
                    .then((value) => getDetails());
              })
          : const SizedBox(),
      bottomNavigationBar: BottomAppBar(
          child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            "Leave Group",
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
          onTap: () => makeSure(),
        ),
      )),
    );
  }

  Future getDetails() async {
    await _firestore
        .collection("groups")
        .doc(widget.groupId)
        .get()
        .then(((value) {
      profileUrl = value["profile"];
      memberList = value["members"];
      _isLoading = false;
      setState(() {});
    }));
  }

  bool checkAdmin() {
    bool isAdmin = false;
    for (var element in memberList) {
      if (element["uid"] == _auth.currentUser!.uid) {
        isAdmin = element["isAdmin"];
      }
    }
    return isAdmin;
  }

  void removeMember(int index) {
    if (checkAdmin()) {
      if (_auth.currentUser!.uid != memberList[index]["uid"]) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Are You Sure?"),
            content: Text("Remove ${memberList[index]['name']}?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("NO"),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    removeMember2(index);
                  },
                  child: const Text("YES"))
            ],
          ),
        );
      }
    }
  }

  Future removeMember2(int index) async {
    String uid = memberList[index]["uid"];

    setState(() {
      _isLoading = true;
      memberList.removeAt(index);
    });

    await _firestore.collection("groups").doc(widget.groupId).update({
      "members": memberList,
    }).then((value) async {
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("groups")
          .doc(widget.groupId)
          .delete();

      setState(() {
        _isLoading = false;
      });
    });
  }

  void makeSure() {
    if (!checkAdmin()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Are You Sure?"),
          content: const Text("Leave Group?"),
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
                  leave();
                },
                child: const Text("LEAVE"))
          ],
        ),
      );
    } else if (memberList.length == 1) {
      delete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A captain cannot just abandoned ship'),
        ),
      );
    }
  }

  Future leave() async {
    setState(() {
      _isLoading = true;
    });

    for (int i = 0; i < memberList.length; i++) {
      if (memberList[i]["uid"] == _auth.currentUser!.uid) {
        memberList.removeAt(i);
        break;
      }
    }

    await _firestore.collection("groups").doc(widget.groupId).update({
      "members": memberList,
    });

    await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("groups")
        .doc(widget.groupId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Left ${widget.groupName}'),
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false);
  }

  void delete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are You Sure?"),
        content: const Text("Delete Group?"),
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
                delete2();
              },
              child: const Text("DELETE"))
        ],
      ),
    );
  }

  Future delete2() async {
    setState(() {
      _isLoading = true;
    });

    for (var member in memberList) {
      await _firestore
          .collection("users")
          .doc(member["uid"])
          .collection("groups")
          .doc(widget.groupId)
          .delete();
    }

    memberList.clear();

    await _firestore
        .collection("groups")
        .doc(widget.groupId)
        .delete()
        .then((value) => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted ${widget.groupName}'),
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false);
  }
}

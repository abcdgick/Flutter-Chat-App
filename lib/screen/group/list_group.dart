import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/db/account.dart';
import 'package:flutter_chat_app/screen/group/add_members.dart';
import 'package:flutter_chat_app/screen/group/chat_screen.dart';
import 'package:flutter_chat_app/screen/group/group_info.dart';
import 'package:flutter_chat_app/screen/home_screen.dart';
import 'package:flutter_chat_app/screen/profile_screen.dart';

final List<Widget> _children = [HomeScreen(), GroupList(), ProfilePage()];

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> profile = [];

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
      appBar: AppBar(
        title: const Text("Groups"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingBody()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: groupList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: 2),
                      onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => GroupChatScreen(
                                        groupName: groupList[index]["name"],
                                        groupId: groupList[index]["id"],
                                      )))
                              .then((value) {
                            getGroup();
                          }),
                      leading: InkWell(
                          onTap: () => Navigator.of(context)
                                  .push(MaterialPageRoute(
                                builder: (context) => GroupInfo(
                                  groupId: groupList[index]["id"],
                                  groupName: groupList[index]["name"],
                                ),
                              ))
                                  .then((value) {
                                getGroup();
                              }),
                          child: ClipOval(
                            child: SizedBox.fromSize(
                              size: const Size.fromRadius(30),
                              child: Image.network(
                                profile[index],
                                fit: BoxFit.fill,
                              ),
                            ),
                          )),
                      title: Text(groupList[index]["name"],
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)));
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
          tooltip: "Create Group",
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddMembers())),
          child: const Icon(Icons.add)),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Groups",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  void onTap(int index) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => _children[index]));
  }

  Future<void> getGroup() async {
    profile = [];
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection("users")
        .doc(uid)
        .collection("groups")
        .get()
        .then((value) {
      groupList = value.docs;
    });

    for (var group in groupList) {
      await _firestore
          .collection("groups")
          .doc(group["id"])
          .get()
          .then((value) {
        profile.add(value["profile"]);
      });
    }

    setState(() {});

    _isLoading = false;
  }

  Future<String> getImage(String id) async {
    final dis = await _firestore.collection("groups").doc(id).get();

    String url = dis["profile"];
    return url;
  }
}

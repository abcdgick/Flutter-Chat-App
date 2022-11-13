import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/db/account.dart';
import 'package:flutter_chat_app/screen/chat_screen.dart';
import 'package:flutter_chat_app/screen/group/list_group.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Flutter Chat App');
  final TextEditingController search = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? userMap;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = _auth.currentUser!.uid;
    setStatus("Online");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    setStatus("Offline");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: customSearchBar,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.logout), onPressed: () => logout(context)),
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
                    customSearchBar = const Text('Flutter Chat App');
                    search.clear();
                  }
                });
              },
              icon: customIcon)
        ],
      ),
      body: _isLoading
          ? const LoadingBody()
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: userMap != null
                    ? ListTile(
                        onTap: () {
                          String roomId = chatRoomId(
                              (_auth.currentUser?.displayName)!,
                              userMap!['name']);
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatRoomId: roomId,
                              userMap: userMap!,
                            ),
                          ));
                        },
                        leading: const Icon(Icons.account_circle,
                            color: Colors.black),
                        title: Text(userMap!['name'],
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(userMap!['email']),
                        trailing: const Icon(Icons.chat, color: Colors.black),
                      )
                    : null,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.group),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const GroupList(),
        )),
      ),
    );
  }

  void onSearch(String text) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    print(text);
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
          if (value.size != 0) userMap = value.docs[0].data();
          _isLoading = false;
          print(userMap);
        });
      },
    );
  }

  String chatRoomId(String user1, String user2) {
    if (user1.toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void setStatus(String status) async {
    await _firestore.collection("users").doc(uid).update({"status": status});
  }
}

class LoadingBody extends StatelessWidget {
  const LoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitCircle(
        size: 100,
        itemBuilder: ((context, index) {
          final colors = [Colors.blue];
          final color = colors[index % colors.length];

          return DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle));
        }),
      ),
    );
  }
}

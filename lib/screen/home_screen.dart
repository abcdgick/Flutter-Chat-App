import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/db/account.dart';
import 'package:flutter_chat_app/screen/chat_screen.dart';
import 'package:flutter_chat_app/screen/group/list_group.dart';
import 'package:flutter_chat_app/screen/profile_screen.dart';
import 'package:flutter_chat_app/screen/user_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final List<Widget> _children = [HomeScreen(), GroupList(), ProfilePage()];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text(
    'Flutter Chat App',
    style: TextStyle(fontWeight: FontWeight.bold),
  );
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
                          onSearch(search.text, context);
                        },
                      ),
                      title: TextField(
                        decoration: const InputDecoration(
                          hintText: 'type in account email...',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
                    customSearchBar = const Text('Flutter Chat App',
                        style: TextStyle(fontWeight: FontWeight.bold));
                    userMap = null;
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
                height: MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    kBottomNavigationBarHeight,
                alignment:
                    userMap != null ? Alignment.topLeft : Alignment.center,
                child: userMap != null
                    ? ListTile(
                        dense: true,
                        visualDensity: VisualDensity(vertical: 2),
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
                        leading: InkWell(
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => UserProfile(
                                    profile: userMap!["profile"],
                                    about: userMap!["about"],
                                    name: userMap!["name"],
                                    email: userMap!["email"],
                                  ),
                                )),
                            child: ClipOval(
                              child: SizedBox.fromSize(
                                size: const Size.fromRadius(30),
                                child: Image.network(
                                  userMap!['profile'],
                                  fit: BoxFit.fill,
                                ),
                              ),
                            )),
                        title: Text(userMap!['name'],
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(userMap!['email']),
                        trailing: const Icon(Icons.chat, color: Colors.black),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Image(
                              image: NetworkImage(
                                  "https://media.tenor.com/hFF7PF8xvN4AAAAi/neco-arc-taunt.gif"),
                              width: 250,
                              height: 180),
                          SizedBox(height: 40),
                          Text(
                            "Created by Jonathan Krisna - 2020130017",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          )
                        ],
                      ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
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

  void onSearch(String text, BuildContext context) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
            if (userMap!["name"] == _auth.currentUser!.displayName) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("You can't chat with yourself!"),
                ),
              );
              userMap = null;
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User does not exist'),
              ),
            );
          }
          _isLoading = false;
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

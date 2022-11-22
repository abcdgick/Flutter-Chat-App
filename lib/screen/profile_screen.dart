import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/db/account.dart';
import 'package:flutter_chat_app/screen/group/list_group.dart';
import 'package:flutter_chat_app/screen/home_screen.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:uuid/uuid.dart';

final List<Widget> _children = [HomeScreen(), GroupList(), ProfilePage()];
var tag;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  Map<String, dynamic>? userMap;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => logout(context),
          color: Colors.red,
        ),
      ),
      body: _isLoading
          ? const LoadingBody()
          : SingleChildScrollView(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection("users")
                    .doc(_auth.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      padding: const EdgeInsets.all(10.0),
                      height: MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          kBottomNavigationBarHeight,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ShowImage(
                                        imageUrl: snapshot.data!['profile'],
                                      ),
                                    ),
                                  ),
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
                          tile(const Icon(Icons.person), "Name",
                              snapshot.data!['name']),
                          vSpace(20),
                          tile(const Icon(Icons.info), "About",
                              snapshot.data!['about']),
                          vSpace(20),
                          tile(const Icon(Icons.email), "Email",
                              snapshot.data!['email']),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
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

  void init() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      _isLoading = true;
    });
    await _firestore
        .collection("users")
        .where("name", isEqualTo: _auth.currentUser!.displayName)
        .get()
        .then(
      (value) {
        setState(() {
          if (value.size != 0) {
            userMap = value.docs[0].data();
            tag = userMap!['profile'];
          }
          _isLoading = false;
        });
      },
    );
  }

  void save(String dis) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .update({dis.toLowerCase(): textEditingController.text});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$dis updated successfully'),
      ),
    );
  }

  Widget vSpace(double d) {
    return SizedBox(height: d);
  }

  Widget tile(Icon dis, String title, String subs) {
    return ListTile(
      leading: dis,
      title: Text(title,
          style: const TextStyle(color: Colors.black54, fontSize: 15)),
      subtitle: Text(subs,
          style: const TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
      trailing: IconButton(
        icon: const Icon(
          Icons.edit,
          color: Colors.blueGrey,
        ),
        onPressed: () {
          textEditingController.text = subs;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Edit your $title"),
              content: TextFormField(
                controller: textEditingController,
                decoration: InputDecoration(hintText: "Your $title"),
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
                      if (textEditingController.text != subs) save(title);
                    },
                    child: const Text("SAVE"))
              ],
            ),
          );
        },
      ),
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  Uint8List? imageFile;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: () async {
              if (await editProfile()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile Image Successfully Updated"),
                  ),
                );
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
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

  Future<bool> editProfile() async {
    imageFile = await ImagePickerWeb.getImageAsBytes();
    if (imageFile != null) {
      String fileName = Uuid().v1();
      int status = 1;

      var ref = FirebaseStorage.instance
          .ref()
          .child('profiles')
          .child("$fileName.jpg");

      UploadTask uploadTask =
          ref.putData(imageFile!, SettableMetadata(contentType: 'image/jpg'));
      TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => print('Done'));

      if (status == 1) {
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        await _firestore
            .collection("users")
            .doc(_auth.currentUser!.uid)
            .update({"profile": imageUrl});

        return true;
      }
    }
    return false;
  }
}

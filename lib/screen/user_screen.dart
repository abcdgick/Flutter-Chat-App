import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/screen/home_screen.dart';

var tag;

class UserProfile extends StatelessWidget {
  final String profile, name, about, email;
  UserProfile(
      {required this.profile,
      required this.name,
      required this.about,
      required this.email,
      super.key}) {
    // TODO: implement UserProfile
    tag = profile;
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$name Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Container(
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
                          imageUrl: profile,
                        ),
                      ),
                    ),
                child: Hero(
                  tag: profile,
                  child: ClipOval(
                    child: SizedBox.fromSize(
                      size: const Size.fromRadius(120),
                      child: Image.network(
                        profile,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                )),
            vSpace(50),
            tile(const Icon(Icons.person), "Name", name),
            vSpace(20),
            tile(const Icon(Icons.info), "About", about),
            vSpace(20),
            tile(const Icon(Icons.email), "Email", email),
          ],
        ),
      )),
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
    );
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

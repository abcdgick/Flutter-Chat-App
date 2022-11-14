import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class GroupInfo extends StatelessWidget {
  final String groupName;
  const GroupInfo({required this.groupName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(groupName),
              centerTitle: true,
              background: const FlutterLogo(),
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(
            height: 30,
            child: Center(
              child: Text(
                "30 member",
                style: TextStyle(fontSize: 16),
              ),
            ),
          )),
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text("User $index"));
            },
            childCount: 30,
          ))
        ],
      ),
      bottomNavigationBar: const BottomAppBar(
          child: Padding(
        padding: EdgeInsets.all(8),
        child: ListTile(
          leading: Icon(Icons.logout, color: Colors.red),
          title: Text(
            "Leave Group",
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
          onTap: null,
        ),
      )),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riomik/models/user.dart';
import 'package:riomik/pages/home.dart';
import 'package:riomik/pages/profile.dart';
import 'package:riomik/pages/search.dart';
import 'package:riomik/screens/chat_screen.dart';
import 'package:riomik/screens/login_screen.dart';
import 'package:riomik/screens/welcome_screen.dart';
import 'package:riomik/widgets/header.dart';
import 'package:riomik/widgets/post.dart';
import 'package:riomik/widgets/progress.dart';
import 'package:riomik/pages/edit_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'activity_feed.dart';

class Timeline extends StatefulWidget {

  final User currentUser;
  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final _auth = FirebaseAuth.instance;
  List<Post> posts;
  List<String> followingLists = [];
  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
    snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingsRef
        .document(currentUser.id)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingLists = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUserFollower();
      //return Text('No Posts');
    } else {
      return ListView(children: posts);
    }
  }

  buildUserFollower() {
    return StreamBuilder(
      stream:
      userRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingLists.contains(user.id);
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        return Container(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      size: 30.0,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'Follow New Friend',
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(children: userResults),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: IconButton(icon: Icon(Icons.search, size: 40,),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Search()));
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 10),
            child: IconButton(icon: Icon(Icons.notifications_active, size: 30),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ActivityFeed()));
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 15),
            child: IconButton(icon: Icon(Icons.account_box_outlined, size: 30),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(profileId:currentUser?.id)));
                }),
          )
        ],
      ),


      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepOrange,
                    Colors.redAccent,
                  ]
                )
              ),
                child: Container(
                  child: Stack(
                    children: [
                      Material(
                         child: Text('Name'),
                      ),
                      CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.blueGrey,
                        backgroundImage: CachedNetworkImageProvider(""),

                      ),
                    ],
                  ),
                ),
            ),
            ListTile(
              title: Text('email'),
              onTap: (){},
            ),
           CustomListTile(Icons.person_rounded,'My Profile',()=>{
           Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(profileId:currentUser?.id)))
           }),
            CustomListTile(Icons.control_point_sharp,'Total Point',()=>{}),
            CustomListTile(Icons.money,'Balance',()=>{

            }),
            CustomListTile(Icons.logout, 'Log Out', ()=>
            {
              //only Chat Screen Signout
              _auth.signOut(),
              Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()))
            }),


          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
class CustomListTile extends StatelessWidget {
  IconData icon;
  String text;
  Function onTap;
  CustomListTile(this.icon,this.text, this.onTap);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
        ),
        child: InkWell(
          splashColor: Colors.red,
          child: Container(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(icon),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(text, style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ],
                ),
                Icon(Icons.arrow_right),
              ],
            ),
          ),
          onTap: onTap,
        ),
      ),

    );
  }
}

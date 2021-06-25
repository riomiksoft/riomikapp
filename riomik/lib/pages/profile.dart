import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riomik/models/user.dart';
import 'package:riomik/pages/edit_profile.dart';
import 'package:riomik/pages/home.dart';
import 'package:riomik/widgets/header.dart';
import 'package:riomik/widgets/post.dart';
import 'package:riomik/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  List<Post> posts = [];
  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollow();
  }
  checkIfFollow() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollower')
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollower')
        .getDocuments();
    setState(() {
      followersCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingsRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }
  getProfilePosts()async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
    .document(widget.profileId)
    .collection('usersPosts')
    .orderBy('timestamp', descending: true)
    .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });

  }
  Column buildPostColumn(String label, int count){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

  }
  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 4.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 200.0,
          height: 30.0,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isFollowing ? Colors.black : Colors.white,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  editProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile(currentUserId:currentUserId)));
  }
  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: 'Edit Profile',
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(text: 'Unfollow', function: handleUnfollowUser);
    } else if (!isFollowing) {
      return buildButton(text: 'Follow', function: handleFollowUser);
    }
  }
  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    followersRef
        .document(widget.profileId)
        .collection('userFollower')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followingsRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    followersRef
        .document(widget.profileId)
        .collection('userFollower')
        .document(currentUserId)
        .setData({});
    followingsRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser.username,
      'userId': currentUser.id,
      'userProfileImg': currentUser.photoUrl,
      'timestamp': timestamp,
    });
  }

  buildProfileHeader(){
    return FutureBuilder(
      future: userRef.document(widget.profileId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Colors.blueGrey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),

                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(top: 20.0),
                          child: Text(
                            user.username,
                            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildPostColumn('Posts', postCount),
                            buildPostColumn('Followers', followersCount),
                            buildPostColumn('Following', followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),


                      ],
                    ),
                  ),
                ],

              ),

              /*Container(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
              ),
               */
              /*Container(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
                */
            Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.bio,
                ),
              ),

            ],
          ),
        );
      },
    );
  }
  buildProfilePost(){
if(isLoading){
  return circularProgress();
}else if(posts.isEmpty) {
  return Container(
    color: Colors.white,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text('No New Posts',
          style: TextStyle(color: Colors.black, fontSize: 30.0, fontWeight: FontWeight.bold, ),
          ),

        ),

      ],
    ),
  );
  }
  return Column(
    children: posts,
  );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: header(context, titleText: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(
            height: 0.0,
          ),
          buildProfilePost(),
        ],
      ),
    );
  }
}

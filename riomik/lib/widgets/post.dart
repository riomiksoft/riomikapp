import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riomik/models/user.dart';
import 'package:riomik/pages/activity_feed.dart';
import 'package:riomik/pages/comments.dart';
import 'package:riomik/pages/home.dart';
import 'package:riomik/widgets/custom_image.dart';
import 'package:riomik/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
  });
  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );

  }
  int getLikeCount(likes){
    if(likes==0){
      return 0;
    }
    int count = 0;
    likes.values.forEach((val){
      if(val == true){
        count +=1;
      }
    });
    return count;
  }
  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    location: this.location,
    description: this.description,
    mediaUrl: this.mediaUrl,
    likes: this.likes,
    likesCount: getLikeCount(this.likes),
  );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likesCount;
  Map likes;
  bool isLiked;
  bool showHeart = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likesCount
  });
  buildPostHeader(){
    return FutureBuilder(
      future: userRef.document(ownerId).get(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          ),
          title: GestureDetector(
            onTap: ()=>showProfile(context, profileId: user.id),
            child: Text(
              user.username,
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
            ),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: (){},
            icon: Icon(Icons.more_vert),
          ),
        );

      },
    );
  }
  buildPostContainer(){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only( left: 10.0, right: 10.0, top: 0, bottom: 5.0),
              child: Text(
                description,
                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
          ],
        ),
      ],
    );
  }
  handleLikePost(){
    bool _isLiked = likes[currentUserId]==true;
    if(_isLiked){
      postsRef
          .document(ownerId)
          .collection('usersPosts')
          .document(postId)
          .updateData({'likes.$currentUserId':false});
      setState(() {
        likesCount -=1;
        isLiked=false;
        likes[currentUserId]=false;
      });
    }else if(!_isLiked){
      postsRef
          .document(ownerId)
          .collection('usersPosts')
          .document(postId)
          .updateData({'likes.$currentUserId':true});
      setState(() {
        likesCount +=1;
        isLiked=true;
        likes[currentUserId]=true;
        showHeart=true;
      });
      Timer(Duration(milliseconds: 300),(){
        setState(() {
          showHeart=false;
        });
      });
    }
  }
  activityToLikeFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .setData({
        'type': 'like',
        'userId': currentUser.id,
        'username': currentUser.username,
        'medialUrl': mediaUrl,
        'userProfileImg': currentUser.photoUrl,
        'timestamp': timestamp,
        'postId': postId
      });
    }
  }

  removeActivityToLikeFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage(){
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showHeart? Animator(
            duration: Duration(milliseconds: 300),
            cycles: 0,
            tween: Tween(begin: 0.8,end: 1.4),
            curve: Curves.bounceInOut,
            builder: (anim)=>Transform.scale(
              scale: anim.value,
              child: Icon(
                Icons.volunteer_activism,size: 100,color: Colors.red,
              ),

            ),
          ): Text(''),
        ],
      ),
    );
  }
  buildPostFooter(){
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0,top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('$likesCount Love',
              style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold, fontSize: 20),),
              Padding(
                padding: EdgeInsets.only(top: 40.0,left: 20.0),
              ),
              GestureDetector(
                onTap: handleLikePost,
                child: Icon(
                 isLiked?Icons.volunteer_activism : Icons.local_florist,size: 30.0,color: Colors.pink,
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 50.0),
              ),
              GestureDetector(
                onTap: () => showComments(
                  context,
                  postId: postId,
                  ownerId: ownerId,
                  mediaUrl: mediaUrl,
                ),
                child: Icon(
                  Icons.sticky_note_2,size: 30.0,color: Colors.blue,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 50.0),
              ),
              GestureDetector(
                onTap: (){},
                child: Icon(
                  Icons.share_sharp,size: 30.0,color: Colors.indigoAccent,
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId]==true);
    return Column(
      children: <Widget>[
        buildPostHeader(),
        buildPostContainer(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postMediaUrl: mediaUrl,
      postOwnerId: ownerId,
    );
  }));
}

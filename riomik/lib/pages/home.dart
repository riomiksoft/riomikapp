import 'package:flutter/src/material/floating_action_button_location.dart';
import 'package:riomik/components/rounded_button.dart';
import 'package:riomik/models/user.dart';
import 'package:riomik/pages/activity_feed.dart';
import 'package:riomik/pages/create_account.dart';
import 'package:riomik/pages/profile.dart';
import 'package:riomik/pages/search.dart';
import 'package:riomik/pages/timeline.dart';
import 'package:riomik/pages/upload.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riomik/screens/chat_screen.dart';
import 'package:riomik/screens/login_screen.dart';
import 'package:riomik/screens/registration_screen.dart';
import 'create_account.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:animator/animator.dart';
import 'package:timeago/timeago.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riomik/screens/chat_screen.dart';

import 'games.dart';
import 'lives.dart';
final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageReference = FirebaseStorage.instance.ref();
final userRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('follower');
final followingsRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');
final DateTime timestamp = DateTime.now();
User currentUser;
class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;
  @override
  void initState(){
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account){
      handleSignIn(account);
    }, onError: (err){
      print('Error User SignIn: $err');
    });
    googleSignIn.signInSilently(suppressErrors: false)
        .then((account){
          handleSignIn(account);
    }).catchError((err){
      print('Error User SignIn: $err');
    });

  }
  handleSignIn(GoogleSignInAccount account)async{
    if(account != null){
     await createUserFirestore();
      setState(() {
        isAuth = true;
      });
    }
    else{
      setState(() {
        isAuth = false;
      });
    }

  }
  createUserFirestore() async{
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.document(user.id).get();
    if(!doc.exists){
     final username = await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAccount()));
     final bloodgroup = await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAccount()));
     userRef.document(user.id).setData({
       'id' : user.id,
       'email' : user.email,
       'username' : username,
       'bloodGroup' : bloodgroup,
       'displayName' : user.displayName,
       'photoUrl' : user.photoUrl,
       'bio' : '',
       'timestamp' : timestamp,


     });
    await followersRef
    .document(user.id)
     .collection('userFollowers')
     .document(user.id)
     .setData({});

     doc = await userRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
    print(currentUser.bloodGroup);
  }
  @override
  void dispose(){
    pageController.dispose();
    super.dispose();
  }
  onPageChanged(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }
  onTap(int pageIndex){
    pageController.animateToPage(pageIndex,
    duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
  login(){
    googleSignIn.signIn();
  }
  logout(){
    googleSignIn.signOut();
  }
  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[

          Timeline(currentUser:currentUser),
          ChatScreen(),
          //ActivityFeed(),
          Upload(currentUser:currentUser),
          //Search(),
         RaisedButton(
            child: Text('Logout'),
            onPressed: logout,
          ),
          Games(),
          Live(),
          //Profile(profileId:currentUser?.id)


        ],
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
      ),
      //Post or Upload Image Here floating Action Button
/*
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Upload(currentUser:currentUser)));
        },
        child: Icon(Icons.add, color: Colors.indigo,),
        elevation: 4.0,
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

 */
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [

          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.message_sharp)),
          //BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline,size: 50,)),
          //BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.games_outlined,)),
          BottomNavigationBarItem(icon: Icon(Icons.video_call_outlined,)),
         // BottomNavigationBarItem(icon: Icon(Icons.account_circle)),


        ],

      ),



    );
  }
  Scaffold buildUnAuthScreen(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.2),
              Theme.of(context).accentColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
                'Riomik',
              style: TextStyle(
                fontSize: 90.0,
                fontFamily: 'Signatra',
                color: Colors.deepOrangeAccent,
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(title: 'Login', colour: Colors.pink,
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButton(title: 'Create New Account', colour: Colors.pink,
              onPressed: () {
                //Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
            Divider(height: 5, color: Colors.blueGrey,),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 200.0,
                height: 40.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}

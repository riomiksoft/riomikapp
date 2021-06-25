import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:riomik/models/user.dart';
import 'package:riomik/pages/home.dart';
import 'package:riomik/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayValid = true;
  bool _bioValid = true;
  @override
  void initState() {
    super.initState();
    getUser();
  }
  getUser() async{
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }
  Column buildDisplayNameField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Text(
            'Display Name',
            style: TextStyle(fontSize: 20.0, color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayController,
          decoration: InputDecoration(
            hintText: 'Update Display Name',
            errorText: _displayValid ? null : 'Display name is Too Short',
          ),
        ),
      ],
    );
  }
  Column buildBioField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Text(
            'Bio',
            style: TextStyle(fontSize: 20.0, color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: 'Update Bio',
            errorText: _bioValid ? null : 'Bio is Too Long',
          ),
        ),
      ],
    );
  }
  updateProfileData(){
    setState(() {
      displayController.text.trim().length < 3 ||
      displayController.text.isEmpty ? _displayValid = false : _displayValid = true;
      bioController.text.trim().length > 100 ? _bioValid = false : _bioValid = true;
    });
    if(_displayValid && _bioValid){
      userRef.document(widget.currentUserId).updateData({
        'displayName' : displayController.text,
        'bio' : bioController.text,
      });
    }
    SnackBar snackBar = SnackBar(content: Text('Profile Updated'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: ()=>Navigator.pop(context),
            icon: Icon(Icons.done, size: 30.0, color: Colors.green),
          ),
        ],
      ),
      body: isLoading? circularProgress(): ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: CircleAvatar(
                    radius: 40.0,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: <Widget>[
                      buildDisplayNameField(),
                      buildBioField(),
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: updateProfileData,
                  child: Text(
                    'Update Profile',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20.0, fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: FlatButton.icon(
                    onPressed: (){},
                    label: Text(
                      'Logout',
                      style: TextStyle(fontSize: 20.0, color: Colors.red),
                    ),
                    icon: Icon(Icons.cancel, size: 30.0, color: Colors.red,),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

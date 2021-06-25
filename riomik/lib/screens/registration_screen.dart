
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riomik/components/rounded_button.dart';
import 'package:riomik/constants.dart';
import 'package:riomik/pages/home.dart';
import 'package:riomik/screens/chat_screen.dart';

class RegistrationScreen extends StatefulWidget {

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String name;
  String email;
  String password;
  String blood;
  String lastdonate;
  String newdonate;
  String location;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
            /*
              Flexible(
                child: Hero(
                  tag: 'logo',

                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),

                ),
              ),

             */

             
              SizedBox(
                height: 48.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                  onChanged: (value) {
                  name = value;

                  },
                  decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Your Name')
              ),

              SizedBox(
                height: 8.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Your Email')
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Your Password')
              ),
              SizedBox(
                height: 24.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    blood = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Your Blood Group')
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    lastdonate = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Your Last Donate')
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    newdonate = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(hintText: 'Enter New Donate')
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    location = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(hintText: 'Enter Your Current Location')
              ),
              SizedBox(
                height: 8.0,
              ),
              RoundedButton(title: 'Register', colour: Colors.lightBlueAccent,
                onPressed: () async{
                try{
                  final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                  if(newUser!=null){
                    //Navigator.pushNamed(context, Home.id);
                    //Navigator.pushNamed(context, ChatScreen.id);
                  }
                }catch(e){
                  print(e);
                }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

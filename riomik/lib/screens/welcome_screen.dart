import 'package:flutter/material.dart';
import 'package:riomik/components/rounded_button.dart';
import 'package:riomik/screens/login_screen.dart';
import 'package:riomik/screens/registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
              /*
                Hero(
                  tag: 'logo',

                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60.0,
                  ),

                ),

               */
                Text(
                  'Riomik',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(title: 'Login', colour: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
             RoundedButton(title: 'Register', colour: Colors.lightBlueAccent,
              onPressed: () {
                 //Navigator.pushNamed(context, RegistrationScreen.id);
              },
             ),
            Divider(),
            RoundedButton(title: 'Sign In with Google', colour: Colors.lightBlueAccent,
              onPressed: () {
                //Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}



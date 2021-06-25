import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riomik/pages/activity_feed.dart';
import 'package:riomik/pages/home.dart';
import 'package:riomik/pages/profile.dart';
import 'package:riomik/pages/search.dart';
import 'package:riomik/screens/login_screen.dart';
import 'package:riomik/screens/registration_screen.dart';
import 'package:riomik/screens/welcome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riomik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.deepOrangeAccent,
      ),

      home: Home(),
    );
  }
}

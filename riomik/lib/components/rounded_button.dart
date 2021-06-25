import 'package:flutter/material.dart';
import 'package:riomik/screens/login_screen.dart';
class RoundedButton extends StatelessWidget {
  final Color colour;
  final String title;
  final Function onPressed;

  const RoundedButton({ this.colour, this.title, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: Colors.pink,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
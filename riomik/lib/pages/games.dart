import 'package:flutter/material.dart';
class Games extends StatefulWidget {
  @override
  _GamesState createState() => _GamesState();
}

class _GamesState extends State<Games> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.red,
      appBar: AppBar(
        title: Text('Gaming Zone', style: TextStyle(),),
      ),
      body: Container(
color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  child: Text('Game is comming Soon'),
                )
              ],
            ),
            Row(),
          ],
        ),
      ),
    );
  }
}

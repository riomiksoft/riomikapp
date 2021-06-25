import 'package:flutter/material.dart';
class Live extends StatefulWidget {
  @override
  _LiveState createState() => _LiveState();
}

class _LiveState extends State<Live> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.red,
      appBar: AppBar(
        title: Text('Live Streaming Zone', style: TextStyle(),),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  child: Text('Live Streaming is comming Soon'),
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

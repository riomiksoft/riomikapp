import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riomik/constants.dart';
import 'package:riomik/models/user.dart';
import 'package:riomik/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
class ChatScreen extends StatefulWidget {
  static const  String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser()async{
    try{
    final user = await _auth.currentUser();
    if(user != null){
loggedInUser = user;

    }
    }
    catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 10),
            child: IconButton(icon: Icon(Icons.call_rounded, size: 30),
                onPressed: (){

                }),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 10),
            child: IconButton(icon: Icon(Icons.video_call_rounded, size: 30),
                onPressed: (){

                }),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 10),
            child: IconButton(icon: Icon(Icons.settings, size: 30),
                onPressed: (){

                }),
          ),

        ],
        title: Text('Chat'),
        backgroundColor: Colors.red[400],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                       'text' : messageText,
                        'sender' : loggedInUser.email,
                      });
                    },
                    child: Icon(Icons.send_rounded, color: Colors.red[300], size: 30,),

                    /*Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),*/
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class  MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final messages = snapshot.data.documents.reversed;
          List<MessageBubble> messageBubbles = [];
          for(var message in messages){
            final messageText = message.data['text'];
            final messageSender = message.data['sender'];
            final currentUser = loggedInUser.email;
            if(currentUser  == messageSender){
            }
            final messageBubble = MessageBubble(
              sender: messageSender,
              text: messageText,
              isMe: currentUser == messageSender,
            );
            messageBubbles.add(messageBubble);

          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              children: messageBubbles,
            ),
          );

        }
    );
  }
}


class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  const MessageBubble({ this.sender, this.text, this.isMe});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black,
          ),
          ),
          Material(
            borderRadius: BorderRadius.circular(30),
            elevation: 5.0,
            color: isMe ? Colors.pink[200] : Colors.orange[200],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.black : Colors.black,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

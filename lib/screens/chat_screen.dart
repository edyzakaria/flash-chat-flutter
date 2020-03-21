import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  String messageText;

  //Provide a trigger for loggedinUser
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //clear the message when sending the text
                      messageTextController.clear();
                      //Implement send functionality.
                      //use messageText, loggedInUser.email, also consider the messages collection and fields in firestore.
                      _firestore.collection("messages").add({
                        "text": messageText,
                        //text is the field in firestore
                        "sender": loggedInUser.email,
                        //sender is the field in firestore
                        "dateTime": DateTime.now(),
                      }); //need to make sure this "messages" is the collection in firestore.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
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

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //the type QuerySnapshot is gotten from firestore snapshots...
      stream: _firestore.collection("messages").orderBy("dateTime", descending: true).snapshots(),
      //from here the QuerySnapshot coming
      builder: (context, snapshot) {
        List<MessageBubble> messageBubbles = [];
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data
            .documents; //by defining the type of streambuilder QuerySnapshot then the snapshot data type change to querysnapshot too.
        for (var message in messages) {
          final messageText = message.data["text"];
          final messageSender = message.data["sender"];
          final messageTime = message.data["dateTime"];
          final currentUser = loggedInUser.email;
          final messageBubble = MessageBubble(
              text: messageText,
              sender: messageSender,
              time: messageTime,
              isMe: currentUser == messageSender,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true, //to always stick to the bottom of the list.
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.time, this.isMe});
  final String sender;
  final String text;
  final Timestamp time;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            isMe ? "" : sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: isMe ? Radius.circular(30.0) : Radius.circular(0.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
              topRight: isMe ? Radius.circular(0.0) : Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            "${time.toDate().hour.toString().padLeft(2, '0')}:${time
              .toDate().minute.toString().padLeft(2, '0')}:${time
              .toDate().second.toString().padLeft(2, '0')}",
            style: TextStyle(
              fontSize: 9.0,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

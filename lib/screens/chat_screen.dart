import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }
  void getCurrentUser(){
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    }catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                _authentication.signOut();
                Navigator.pop(context);
              },
              icon: Icon(Icons.logout, color: Colors.white),
            ),
          ],
          title: Text('Chat screen'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chats/60eo1lpvjS0FtWZWCaOO/message') // 데이터베이스의 주소
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            // 스트림으로 전달받은 데이터에 접근이 가능 하다
            final docs =
                snapshot.data!.docs; //데이터 필드에는 모든 데이터가있기때문에 data뒤에 느낌표를 붙여준다
            return ListView.builder(
              itemCount: docs.length,
              // 문서내의 모든 데이터의 개수( 채팅앱처럼 개수가 매번 바뀌게되면 의미가 없어진다)
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    docs[index]['text'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                );
              },
            );
          },
        ));
  }
}
    
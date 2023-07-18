import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {

  var _userEnterMessage = '';
  final _controller = TextEditingController(); // 쓴 내용 지우기

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': _userEnterMessage,
      'time': Timestamp.now(), // 시간순서에 따라 정렬해준다 (cloud_firestore가 패키지에서 제공된다)
      'userId': user.uid,
      'userName': userData.data()!['userName'], // 유저 데이터를 가져온다
      'userImage': userData['picked_image']
    });
    _controller.clear(); // 입력된 텍스트 삭제
    _userEnterMessage = ''; // 텍스트 보내고 난 후에 보내는 메시지 비활성화
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded( // Expanded를 사용하는 이유는 TextField가 쓸대없이 많은 공간을 차지하려고 해서 에러 발생 때문
            child: TextField(
              maxLines: null,
              controller: _controller,
              decoration: InputDecoration(labelText: 'Send a Message...'),
              onChanged: (value) {
                setState(() {
                  _userEnterMessage =
                      value; // 키를입력할때마다 업데이트 할수도있고 메시지를 활성화나 잠그거나 할 수 있다
                });
              },
            ),
          ),
          IconButton(
            onPressed: _userEnterMessage.trim().isEmpty ? null : _sendMessage,
            // 메소드 뒤에 괄호가 붙은다는 것은 실행되고 리턴된다는 의미
            // 메소드 뒤에 괄호가 없으면 onPressed 함수가 _sendMessage의 위치를 참조할수 있다는 의미(포인터 느낌)
            icon: Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

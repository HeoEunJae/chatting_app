import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.
      collection('chat').
      orderBy('time', descending: true). // 정렬 방식엔 acending 방식과 decending 방식이있는데 최신글이 아래로가려면 decending 방식 사용
      snapshots(), // 데이터베이스의 주소
      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        // 데이터를 바로 가져오기전에 로딩창을 보여주는 프로그레스 인디케이터를 사용한다.
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs; // 스트림으로 전달받은 데이터에 접근이 가능 하다
        //데이터 필드에는 모든 데이터가있기때문에 data뒤에 느낌표를 붙여준다
        return ListView.builder(
          reverse: true, // 메시지의 위치 변경
          itemCount: chatDocs.length,
          itemBuilder: (context, index) { // 문서내의 모든 데이터의 개수( 채팅앱처럼 개수가 매번 바뀌게되면 의미가 없어진다)
            return Text(chatDocs[index]['text']);
          },
        );
      },
    );
  }
}

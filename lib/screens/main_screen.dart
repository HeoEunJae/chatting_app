import 'dart:io';

import 'package:chat_app/add_image/add_image.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/config/palette.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 기본적인 인증관련 담당
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // user id 정보는 엑스트라 데이터로써 얘가 담당한다
import 'package:firebase_storage/firebase_storage.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _authentication = FirebaseAuth.instance;
  bool isSingupScreen = true;

  // 전송시 비동기 시간동안 돌아가는 것을 대체해준다
  bool showSpinner = false;

  // 유효성 검사를 위한 키값 세팅
  final _formKey = GlobalKey<FormState>();

  // 밸류값을 실제적인 밸리데이션 기능에 사용하기 위한 변수
  String userName = '';
  String userEmail = '';
  String userPassword = '';
  File? userPickedImage;

  void pickedImage(File image) {
    userPickedImage = image; // add image에서 선택된 이미지가 저장됨
  }

  // 유효성 검사를 위한 저장 currentstate를에서만 통해 저장
  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  void showAlret(BuildContext context) {
    // 프로필 팝업창 꾸미기
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: AddImage(pickedImage),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      // 겹겹이 쌓을 수 있게하는 위젯 / 위젯들을 원하는 곳에 위치 시킬 수 있다
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              // 원하는 곳에 위치 시킬 수 있다. (상.하.좌.우)
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('image/red.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.only(top: 90, left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // RichText가 텍스트를 쪼개서 원하는 곳에 디자인 할 수 있게 해주는거
                        RichText(
                          text: TextSpan(
                            text: 'Welcome',
                            style: TextStyle(
                              letterSpacing: 1.0,
                              fontSize: 25,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text: isSingupScreen
                                    ? ' to Yummy chat!'
                                    : ' Back',
                                style: TextStyle(
                                  letterSpacing: 1.0,
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          isSingupScreen
                              ? 'Singup to continue'
                              : 'Singin to continue',
                          style: TextStyle(
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ), // 배경
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
                top: 180,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  padding: EdgeInsets.all(20.0),
                  height: isSingupScreen ? 280 : 250,
                  width: MediaQuery.of(context).size.width - 40,
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        )
                      ]),
                  //실제 디바이스의 width 길이를 구해준다
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 25),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Login 텍스트
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSingupScreen = false;
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: !isSingupScreen
                                          ? Palette.activeColor
                                          : Palette.textColor1,
                                    ),
                                  ),
                                  if (!isSingupScreen)
                                  //inline if - dart 2.3부터 도입 한 컬럼 위젯 내에 요소들을 어떤 예외적인 조건을 보다 쉽고 명확하게 지정해 줄수 있는 기능
                                    Container(
                                      height: 2,
                                      width: 55,
                                      color: Colors.orange,
                                    ),
                                ],
                              ),
                            ),
                            // SignUp 텍스트
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSingupScreen = true;
                                });
                              },
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSingupScreen
                                              ? Palette.activeColor
                                              : Palette.textColor1,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      if (isSingupScreen)
                                        GestureDetector(
                                          onTap: () {
                                            showAlret(context);
                                          },
                                          child: Icon(
                                            Icons.image,
                                            color: isSingupScreen
                                                ? Colors.cyan
                                                : Colors.grey[300],
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (isSingupScreen)
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 3, 35, 0),
                                      height: 2,
                                      width: 65,
                                      color: Colors.orange,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // 회원정보 입력 구간 **********************************
                        // 텍스트 필드에디터는 많아지면 controller가 많아지고 복잡해진다
                        // 그래서 텍스트 폼 필드를 사용한다.
                        if (isSingupScreen) // Sign up *******************
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Form(
                              key: _formKey, // 키값 세팅
                              child: Column(
                                children: [
                                  // Username 필드******************
                                  TextFormField(
                                    key: ValueKey(1),
                                    // key값을 통해 입력값이 꼬이지 않도록 정리해준다
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 4) {
                                        return 'Please enter at least 4 characters.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userName = value!;
                                    },
                                    onChanged: (value) {
                                      userName = value;
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.account_circle,
                                        color: Palette.iconColor,
                                      ),
                                      // enableBoarder만 쓰면 텍스트 필드 클릭시 Boder가 사라진다
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      hintText: 'User name',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  // UserEmail 필드******************
                                  TextFormField(
                                    // 이메일 전용 키보드 세팅
                                    keyboardType: TextInputType.emailAddress,
                                    key: ValueKey(2),
                                    // key값을 통해 입력값이 꼬이지 않도록 정리해준다
                                    validator: (value) {
                                      if (value!.isEmpty ||
                                          !value.contains('@')) {
                                        return 'Please enter a valid email address.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userEmail = value!;
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Palette.iconColor,
                                      ),
                                      // enableBoarder만 쓰면 텍스트 필드 클릭시 Boder가 사라진다
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      hintText: 'User Email',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  // Password 필드******************
                                  TextFormField(
                                    obscureText: true,
                                    // 비밀번호 표시 가리기
                                    key: ValueKey(3),
                                    // key값을 통해 입력값이 꼬이지 않도록 정리해준다
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 6) {
                                        return 'Password must be at least 7 characters long.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userPassword = value!;
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Palette.iconColor,
                                      ),
                                      // enableBoarder만 쓰면 텍스트 필드 클릭시 Boder가 사라진다
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      hintText: 'Password',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (!isSingupScreen) // Log in *******************
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Form(
                              key: _formKey, // 키값 세팅
                              child: Column(
                                children: [
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    key: ValueKey(4),
                                    // key값을 통해 입력값이 꼬이지 않도록 정리해준다
                                    validator: (value) {
                                      if (value!.isEmpty ||
                                          !value.contains('@')) {
                                        return 'Please enter a valid email address.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userEmail = value!;
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Palette.textColor1,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Palette.textColor1),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Palette.textColor1),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      hintText: 'Email',
                                      hintStyle:
                                      TextStyle(color: Palette.textColor1),
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextFormField(
                                    obscureText: true,
                                    key: ValueKey(5),
                                    // key값을 통해 입력값이 꼬이지 않도록 정리해준다
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 6) {
                                        return 'Password must be at least 7 characters long.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userPassword = value!;
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Palette.textColor1,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Palette.textColor1),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Palette.textColor1),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      hintText: 'Password',
                                      hintStyle:
                                      TextStyle(color: Palette.textColor1),
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ), // 텍스트필드
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
                top: isSingupScreen ? 430 : 390,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                    padding: EdgeInsets.all(15),
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50)),
                    child: GestureDetector(
                      onTap: () async {
                        // 빌드메서드를 다시 호출할때 사용
                        setState(() {
                          showSpinner = true;
                        });
                        // 회원가입 화면
                        if (isSingupScreen) {
                          if (userPickedImage == null) {
                            setState(() {
                              showSpinner = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please pick your image'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                            return;
                          }
                          _tryValidation();
                          try {
                            final newUser = await _authentication
                                .createUserWithEmailAndPassword(
                                    email: userEmail, password: userPassword);
                            final refImage = FirebaseStorage.instance
                                .ref()
                                . // ref는 클라우스 스토리지 버킷경로에 접근 가능하게 해줌
                                child('picked_image')
                                . // 폴더를 지정해주는 child
                                child(newUser.user!.uid +
                                    'png'); // 이미지의 이름을 지정해주는 child

                            await refImage
                                .putFile(userPickedImage!); // 파일 or 이미지 올리기
                            final url = await refImage.getDownloadURL();

                            await FirebaseFirestore.instance // user id 생성 해준다
                                .collection('user')
                                .doc(newUser.user!.uid)
                                .set(
                              {
                                'userName': userName,
                                'email': userEmail,
                                'picked_image': url
                              },
                            );
                            if (newUser.user != null) {
                              // 로딩화면 없애주기
                              setState(() {
                                showSpinner = false;
                              });
                            }
                          } catch (e) {
                            print(e);
                            if (mounted) {
                              // setState 메서드는 해당 객체가 이미 사라졌는데 호출함으로써 오류가 발생한다
                              // 이때 mount란걸 사용한다
                              // true 일때만 setstate메서드를 호출하게된다
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Please check your email and password'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                              setState(() {
                                // 유효성검사 실행시 입력이 없을 경우 progress indicator 멈추게함
                                showSpinner = false;
                              });
                            }
                          }
                        }
                        // 로그인 화면
                        if (!isSingupScreen) {
                          _tryValidation();
                          try {
                            final newUser = await _authentication
                                .signInWithEmailAndPassword(
                                email: userEmail, password: userPassword);
                          } catch (e) {
                            print(e);
                            setState(() {
                              // 유효성검사 실행시 입력이 없을 경우 progress indicator 멈추게함
                              showSpinner = false;
                            });
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Colors.orange,
                                  Colors.red,
                                ],
                                // 그라데이션 방향 어디에서 어디로 그라에디션을 줄건지
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 1), // 그림자의 범위( X -> Y 까지)
                              ),
                            ]),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ), // 로그인 버튼
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
                top: isSingupScreen
                    ? MediaQuery.of(context).size.height - 125
                    : MediaQuery.of(context).size.height - 155,
                right: 0,
                left: 0,
                child: Column(
                  children: [
                    Text(isSingupScreen ? 'or Signup with' : 'or Signin with'),
                    SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          minimumSize: Size(155, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          backgroundColor: Palette.googleColor),
                      icon: Icon(Icons.add),
                      label: Text('Google'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

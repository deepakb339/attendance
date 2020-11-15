import 'package:attendance/admin.dart';
import 'package:attendance/constants.dart';
import 'package:attendance/faculty.dart';
import 'package:attendance/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email, password;
  int _value = 1;
  final _auth = FirebaseAuth.instance;
  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 70),
          child: Text(
            'Attendance Viewer',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildEmailRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          setState(() {
            email = value + '@gmail.com';
          });
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              FontAwesomeIcons.solidUser,
              color: mainColor,
            ),
            labelText: 'Username'),
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        keyboardType: TextInputType.text,
        obscureText: true,
        onChanged: (value) {
          setState(() {
            password = value;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            color: mainColor,
          ),
          labelText: 'Password',
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.4 * (MediaQuery.of(context).size.height / 20),
          width: 5 * (MediaQuery.of(context).size.width / 10),
          margin: EdgeInsets.only(bottom: 20),
          child: RaisedButton(
            elevation: 5.0,
            color: mainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () {
              // if (_auth.currentUser() != null) {
              //   _auth.signOut();
              // } else {
              _auth
                  .signInWithEmailAndPassword(email: email, password: password)
                  .then((FirebaseUser) async {
                final currentUser = await _auth.currentUser();
                String userid = currentUser.uid;
                if (_value == 1) {
                  DocumentReference documentReference = Firestore.instance
                      .collection('students')
                      .document(userid);
                  documentReference.get().then((datasnapshot) {
                    if (datasnapshot.data['role'] == 'student') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Studentpage()));
                    } else {
                      Fluttertoast.showToast(
                          msg: "You are not a valid student",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: mainColor,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  });
                } else if (_value == 2) {
                  DocumentReference documentReference =
                      Firestore.instance.collection('faculty').document(userid);
                  documentReference.get().then((datasnapshot) {
                    if (datasnapshot.data['role'] == 'faculty') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FacultyPage()));
                    } else {
                      Fluttertoast.showToast(
                          msg: "You are not a valid faculty member",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: mainColor,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  });
                } else if (_value == 3) {
                  DocumentReference documentReference =
                      Firestore.instance.collection('admin').document(userid);
                  documentReference.get().then((datasnapshot) {
                    if (datasnapshot.data['role'] == 'admin') {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AdminPage()));
                    } else {
                      Fluttertoast.showToast(
                          msg: "You are not an admin",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: mainColor,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  });
                }
              }).catchError((e) {
                print(e);
                Fluttertoast.showToast(
                    msg: e,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: mainColor,
                    textColor: Colors.white,
                    fontSize: 16.0);
              });
              // }
            },
            child: Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: MediaQuery.of(context).size.height / 40,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 30,
                      ),
                    ),
                  ],
                ),
                _buildEmailRow(),
                SizedBox(height: 30.0),
                _buildPasswordRow(),
                SizedBox(height: 30.0),
                Container(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all()),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                        value: _value,
                        items: [
                          DropdownMenuItem(
                            child: Text("Student"),
                            value: 1,
                          ),
                          DropdownMenuItem(
                            child: Text("Faculty"),
                            value: 2,
                          ),
                          DropdownMenuItem(child: Text("Admin"), value: 3)
                        ],
                        onChanged: (value) {
                          setState(() {
                            _value = value;
                          });
                        }),
                  ),
                ),
                SizedBox(height: 30.0),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgetBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40),
          child: FlatButton(
            onPressed: () {},
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: 'Forget Password? ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'Click here',
                  style: TextStyle(
                    color: mainColor,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ]),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f3f7),
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            child: Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(70),
                        bottomRight: const Radius.circular(70),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildLogo(),
                    SizedBox(height: 10.0),
                    _buildContainer(),
                    SizedBox(height: 10.0),
                    _buildForgetBtn(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

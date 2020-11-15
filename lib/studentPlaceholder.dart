import 'package:attendance/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StudentPlaceholderWidget extends StatefulWidget {
  @override
  _StudentPlaceholderWidgetState createState() =>
      _StudentPlaceholderWidgetState();
}

class _StudentPlaceholderWidgetState extends State<StudentPlaceholderWidget> {
  String rollno, name, uname, cname, semester, subject, fassigned, password;
  List<String> s;
  final String adminU = 'admin@gmail.com';
  final String aPassword = 'admin123';
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          child: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          Row(
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
                  onPressed: () => _showDialog(),
                  child: Text(
                    "Add Student",
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1.5,
                      fontSize: MediaQuery.of(context).size.height / 40,
                    ),
                  ),
                ),
              )
            ],
          ),
          Card(
            elevation: 5,
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Roll no"),
                  Text("Name"),
                  Text("Course"),
                  Text("Subject"),
                  Text("Semester"),
                  Text("Faculty"),
                ],
              ),
            ),
          ),
          Card(
            elevation: 5,
            margin: EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: StreamBuilder(
              stream: Firestore.instance.collection('students').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && !snapshot.data.documents.isEmpty) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot =
                            snapshot.data.documents[index];
                        return Container(
                          margin: EdgeInsets.all(10.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                      documentSnapshot['rollno'].toString()),
                                ),
                                Expanded(
                                  child:
                                      Text(documentSnapshot['name'].toString()),
                                ),
                                Expanded(
                                  child: Text(documentSnapshot['courseName']
                                      .toString()),
                                ),
                                Expanded(
                                    child: Text(
                                  documentSnapshot['subject'].join(', '),
                                )),
                                Expanded(
                                  child: Text(
                                      documentSnapshot['semester'].toString()),
                                ),
                                Expanded(
                                  child: Text(
                                      documentSnapshot['facultyAssigned']
                                          .toString()),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                } else if (snapshot.connectionState ==
                        ConnectionState.waiting &&
                    snapshot.data == null) {
                  return LinearProgressIndicator();
                } else {
                  return Text('NO Data Available');
                }
              },
            ),
          )
        ],
      )),
    );
  }

  _showDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Student'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(height: 10.0),
                TextField(
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    setState(() {
                      this.rollno = text;
                      this.uname = text + '@gmail.com';
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      labelText: 'Roll number',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                ),
                SizedBox(height: 10.0),
                TextField(
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    setState(() {
                      this.name = text;
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      labelText: 'Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                ),
                SizedBox(height: 10.0),
                TextField(
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    setState(() {
                      this.cname = text;
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      labelText: 'Course Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                ),
                SizedBox(height: 10.0),
                TextField(
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    setState(() {
                      this.semester = text;
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      labelText: 'Semester',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                ),
                SizedBox(height: 10.0),
                TextField(
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    setState(() {
                      this.subject = text;
                      this.s = text.split(",");
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      labelText: 'Subject',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                ),
                SizedBox(height: 10.0),
                TextField(
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    setState(() {
                      this.fassigned = text;
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      labelText: 'Faculty Assigned',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                ),
                SizedBox(height: 10.0),
                TextField(
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    setState(() {
                      this.password = text;
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      labelText: 'Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                ),
              ],
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Add'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _createUser();
                Fluttertoast.showToast(
                    msg: "Successfuly Added",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: mainColor,
                    textColor: Colors.white,
                    fontSize: 16.0);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createUser() async {
    try {
      _auth.signOut();
      _auth.createUserWithEmailAndPassword(email: uname, password: password);
      // final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      //         email: uname, password: password))
      //     .user;
      await _auth.signInWithEmailAndPassword(email: uname, password: password);
      final FirebaseUser currentUser = await _auth.currentUser();
      // assert(user.uid == currentUser.uid);
      _firestore
          .collection('students')
          .document(currentUser.uid.toString())
          .setData({
        'rollno': rollno,
        'name': name,
        'courseName': cname,
        'semester': semester,
        'subject': s,
        'facultyAssigned': fassigned,
        'role': 'student'
      });
    } catch (e) {
      print(e);
    }
  }
}

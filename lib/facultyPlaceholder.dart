import 'package:attendance/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FacultyPlaceholderWidget extends StatefulWidget {
  @override
  _FacultyPlaceholderWidgetState createState() =>
      _FacultyPlaceholderWidgetState();
}

class _FacultyPlaceholderWidgetState extends State<FacultyPlaceholderWidget> {
  String fid, name, uname, subject, password;
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
                    "Add Faculty",
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
                  Text("Faculty ID"),
                  Text("Name"),
                  Text("Subject"),
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
              stream: Firestore.instance.collection('faculty').snapshots(),
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
                                  child:
                                      Text(documentSnapshot['fid'].toString()),
                                ),
                                Expanded(
                                  child:
                                      Text(documentSnapshot['name'].toString()),
                                ),
                                Expanded(
                                  child: Text(
                                      documentSnapshot['subject'].toString()),
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
          title: Text('Add Faculty'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(height: 10.0),
                TextField(
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    setState(() {
                      this.fid = text;
                      this.uname = text + '@gmail.com';
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      labelText: 'Faculty ID',
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
                      this.subject = text;
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
          .collection('faculty')
          .document(currentUser.uid.toString())
          .setData({
        'fid': fid,
        'name': name,
        'subject': subject,
        'role': 'faculty',
      });
    } catch (e) {
      print(e);
    }
  }
}

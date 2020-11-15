import 'package:attendance/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FMarkAttendancePage extends StatefulWidget {
  FMarkAttendancePage({Key key}) : super(key: key);

  @override
  _FMarkAttendancePageState createState() => _FMarkAttendancePageState();
}

class _FMarkAttendancePageState extends State<FMarkAttendancePage> {
  bool flag = false;
  static DateTime selectedDate = DateTime.now();
  static DateTime _dateTime = DateTime.now();
  static DateTime _dateTime2 = DateTime.now();
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  static String date;
  static String subject;
  @override
  void initState() {
    super.initState();
    date = (selectedDate.day.toString() +
        "/" +
        selectedDate.month.toString() +
        "/" +
        selectedDate.year.toString());
    subject = "not get";
    _getRollno();
  }

  _getRollno() async {
    final FirebaseUser currentUser = await _auth.currentUser();
    DocumentReference documentReference =
        _firestore.collection('faculty').document(currentUser.uid.toString());
    documentReference.get().then((datasnapshot) {
      setState(() {
        subject = datasnapshot.data['subject'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Students Attendance'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: Icon(FontAwesomeIcons.signOutAlt, color: Colors.white),
              onPressed: () {
                FirebaseAuth.instance.signOut().whenComplete(() =>
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage())));
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selectedDate,
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() {
                    selectedDate = newDateTime;
                    date = (newDateTime.day.toString() +
                        "/" +
                        newDateTime.month.toString() +
                        "/" +
                        newDateTime.year.toString());
                  });
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Start Time:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TimePickerSpinner(
                        is24HourMode: true,
                        onTimeChange: (time) {
                          setState(() {
                            _dateTime = time;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('End Time:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TimePickerSpinner(
                        is24HourMode: true,
                        onTimeChange: (time) {
                          setState(() {
                            _dateTime2 = time;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            flag == true ? CircularProgressIndicator() : Text(""),
            _buildBody(context),
            RaisedButton(
              elevation: 5.0,
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              onPressed: () async {
                setState(() {
                  flag = true;
                });
                await Future.delayed(const Duration(seconds: 10));
                setState(() {
                  flag = false;
                });
                final snackBar = SnackBar(
                  content: Text('Marked Successfully'),
                );
                Scaffold.of(context).showSnackBar(snackBar);
              },
              child: Text(
                "Mark Attendance",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('students')
          .where('subject', arrayContains: subject)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Exercise(
          title: record.name,
        ),
      ),
    );
  }
}

class Record {
  final String name;
  bool selected = false;
  final DocumentReference reference;

  Record(this.name, this.selected, this.reference);

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        name = map['name'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:>";
}

class Exercise extends StatefulWidget {
  final String title;

  Exercise({this.title});

  @override
  _ExerciseState createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {
  bool selected = false;
  final _firestore = Firestore.instance;
  String roll = 's1001';
  Map<String, dynamic> userDocumentt;
  @override
  void initState() {
    super.initState();
    if (widget.title == 'Deepak') {
      roll = 's1001';
    } else if (widget.title == 'Aman') {
      roll = 's1002';
    } else if (widget.title == 'Hitesh') {
      roll = 's1003';
    } else if (widget.title == 'Vivek') {
      roll = 's1004';
    }
    _getRollno();
  }

  _getRollno() async {
    StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('students')
          .where('name', isEqualTo: widget.title)
          .snapshots(),
      builder: (context, snapshot) {
        DocumentSnapshot documentSnapshot = snapshot.data.documents[0];
        setState(() {
          roll = documentSnapshot['rollno'];
        });
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      trailing: Checkbox(
          value: selected,
          onChanged: (bool val) {
            setState(() {
              selected = val;
              Map<String, dynamic> data = {
                'name': widget.title,
                'date': _FMarkAttendancePageState.date,
                'etime': _FMarkAttendancePageState._dateTime2.hour.toString() +
                    ":" +
                    _FMarkAttendancePageState._dateTime2.second.toString(),
                'rollno': roll,
                'status': 'Present',
                'stime': _FMarkAttendancePageState._dateTime.hour.toString() +
                    ":" +
                    _FMarkAttendancePageState._dateTime.second.toString(),
                'subject': _FMarkAttendancePageState.subject
              };
              Map<String, dynamic> data2 = {
                'name': widget.title,
                'date': _FMarkAttendancePageState.date,
                'etime': _FMarkAttendancePageState._dateTime2.hour.toString() +
                    ":" +
                    _FMarkAttendancePageState._dateTime2.second.toString(),
                'rollno': roll,
                'status': 'Absent',
                'stime': _FMarkAttendancePageState._dateTime.hour.toString() +
                    ":" +
                    _FMarkAttendancePageState._dateTime.second.toString(),
                'subject': _FMarkAttendancePageState.subject
              };
              if (val == true) {
                _firestore.collection('attendancedaywise').add(data);
              } else {
                _firestore.collection('attendancedaywise').add(data2);
              }
            });
          }),
    );
  }
}

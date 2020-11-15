import 'package:attendance/sDayWiseAttendance.dart';
import 'package:attendance/sSubjectWiseAttendance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'main.dart';
import 'overallAttendance.dart';

class Studentpage extends StatefulWidget {
  Studentpage({Key key}) : super(key: key);

  @override
  _StudentpageState createState() => _StudentpageState();
}

class _StudentpageState extends State<Studentpage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    SDayWiseAttendance(),
    SSubjectWiseAttendance(),
    OverallAttendance()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Attendance Viewer'),
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
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.dailymotion),
            title: Text('DayWiseAttendance'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.addressCard),
            title: Text('SubjectWiseAttendance'),
          ),
          new BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.chalkboardTeacher),
              title: Text('Overall Attendance'))
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

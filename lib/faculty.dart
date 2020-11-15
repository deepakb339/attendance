import 'package:attendance/fShowAttendance.dart';
import 'package:attendance/fmarkAttendance.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FacultyPage extends StatefulWidget {
  FacultyPage({Key key}) : super(key: key);

  @override
  _FacultyPageState createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    FMarkAttendancePage(),
    FShowAttendancePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.checkCircle),
            title: Text('Mark'),
          ),
          new BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.addressBook), title: Text('Show'))
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

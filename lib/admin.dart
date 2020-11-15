import 'package:attendance/facultyPlaceholder.dart';
import 'package:attendance/main.dart';
import 'package:attendance/studentPlaceholder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminPage extends StatefulWidget {
  AdminPage({Key key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    StudentPlaceholderWidget(),
    FacultyPlaceholderWidget()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Admin Management'),
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
            icon: Icon(FontAwesomeIcons.bookOpen),
            title: Text('Student'),
          ),
          new BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.chalkboardTeacher),
              title: Text('Faculty'))
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

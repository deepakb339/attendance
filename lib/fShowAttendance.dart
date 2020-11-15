import 'package:attendance/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class FShowAttendancePage extends StatefulWidget {
  FShowAttendancePage({Key key}) : super(key: key);

  @override
  _FShowAttendancePageState createState() => _FShowAttendancePageState();
}

class _FShowAttendancePageState extends State<FShowAttendancePage> {
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();

  void _printScreen() {
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      final doc = pw.Document();

      final image = await wrapWidget(
        doc.document,
        key: _printKey,
        pixelRatio: 2.0,
      );

      doc.addPage(pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Expanded(
                child: pw.Image(image),
              ),
            );
          }));

      return doc.save();
    });
  }

  DateTime selectedDate = DateTime.now();
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  String date, subject;
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
        title: Text('View Students Attendance'),
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
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20.0,
            ),
            RaisedButton(
              elevation: 5.0,
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              onPressed: _printScreen,
              child: Text(
                "Generate Report",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            RepaintBoundary(
              key: _printKey,
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
                  Card(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Rollno"),
                          Text("Name"),
                          Text("Start Time"),
                          Text("End Time"),
                          Text("Attendance"),
                        ],
                      ),
                    ),
                  ),
                  StreamBuilder(
                    stream: _firestore
                        .collection('attendancedaywise')
                        .where('date', isEqualTo: date)
                        .where('subject', isEqualTo: subject)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          !snapshot.data.documents.isEmpty) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot documentSnapshot =
                                  snapshot.data.documents[index];
                              return Card(
                                margin: EdgeInsets.all(10.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(documentSnapshot['rollno']
                                            .toString()),
                                      ),
                                      Expanded(
                                        child: Text(documentSnapshot['name']
                                            .toString()),
                                      ),
                                      Expanded(
                                        child: Text(documentSnapshot['stime']
                                            .toString()),
                                      ),
                                      Expanded(
                                        child: Text(documentSnapshot['etime']
                                            .toString()),
                                      ),
                                      Expanded(
                                        child: Text(documentSnapshot['status']
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
                        return Center(
                            child: Container(
                                margin: EdgeInsets.all(20.0),
                                child: Text(
                                  'NO Data Available',
                                  style: TextStyle(fontSize: 30),
                                )));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SDayWiseAttendance extends StatefulWidget {
  @override
  _SDayWiseAttendanceState createState() => _SDayWiseAttendanceState();
}

class _SDayWiseAttendanceState extends State<SDayWiseAttendance> {
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
  String date, rollno;
  @override
  void initState() {
    super.initState();
    date = (selectedDate.day.toString() +
        "/" +
        selectedDate.month.toString() +
        "/" +
        selectedDate.year.toString());
    rollno = "not get";
    _getRollno();
  }

  _getRollno() async {
    final FirebaseUser currentUser = await _auth.currentUser();
    DocumentReference documentReference =
        _firestore.collection('students').document(currentUser.uid.toString());
    documentReference.get().then((datasnapshot) {
      setState(() {
        rollno = datasnapshot.data['rollno'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                        Text("Subject"),
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
                      .where('rollno', isEqualTo: rollno)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && !snapshot.data.documents.isEmpty) {
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
                                      child: Text(documentSnapshot['subject']
                                          .toString()),
                                    ),
                                    Expanded(
                                      child: Text(
                                          documentSnapshot['stime'].toString()),
                                    ),
                                    Expanded(
                                      child: Text(
                                          documentSnapshot['etime'].toString()),
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
    );
  }
}

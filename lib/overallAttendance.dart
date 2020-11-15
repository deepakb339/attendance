import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OverallAttendance extends StatefulWidget {
  @override
  _OverallAttendanceState createState() => _OverallAttendanceState();
}

class _OverallAttendanceState extends State<OverallAttendance> {
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

  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  String subject, rollno;
  @override
  void initState() {
    super.initState();
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
            child: StreamBuilder(
              stream: _firestore
                  .collection('attedanceoverall')
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
                        return Container(
                          padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                          width: double.maxFinite,
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Stack(children: <Widget>[
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Stack(
                                    children: <Widget>[
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, top: 5),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  RichText(
                                                    textAlign: TextAlign.left,
                                                    text: TextSpan(
                                                      text:
                                                          "Overall Attendance",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 25,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Spacer(),
                                                  Card(
                                                    color: Colors.blue,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Text(
                                                          ((int.parse(documentSnapshot[
                                                                          'attended']) /
                                                                      int.parse(
                                                                          documentSnapshot[
                                                                              'held'])) *
                                                                  100)
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  RichText(
                                                    textAlign: TextAlign.left,
                                                    text: TextSpan(
                                                      text: "Present : " +
                                                          documentSnapshot[
                                                                  'attended']
                                                              .toString(),
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 25,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  RichText(
                                                    textAlign: TextAlign.left,
                                                    text: TextSpan(
                                                      text: "Absent : " +
                                                          documentSnapshot[
                                                                  'absent']
                                                              .toString(),
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 25,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  RichText(
                                                    textAlign: TextAlign.left,
                                                    text: TextSpan(
                                                      text: "Total Classes : " +
                                                          documentSnapshot[
                                                                  'held']
                                                              .toString(),
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 25,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                )
                              ]),
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
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sabang/view/Lokasi.dart';
import 'package:sabang/view/Peta.dart';
import 'package:sabang/view/Update.dart';

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  CollectionReference ref = Firestore.instance.collection('lokasi');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => Navigator.of(context)
          ..push(MaterialPageRoute(builder: (ctx) => Lokasi())),
        child: Icon(
          Icons.add_location,
          color: Colors.white,
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(left: 10, top: 10, right: 10),
        child: StreamBuilder<QuerySnapshot>(
          stream: ref.snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
            switch (snap.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return Center(child: CircularProgressIndicator());
              default:
                return ListView(
                  physics: ClampingScrollPhysics(),
                  children: snap.data.documents.map((DocumentSnapshot doc) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.0),
                      child: Material(
                        elevation: 5.2,
                        child: ListTile(
                          title: Text(
                            doc.data['judul'],
                            style: TextStyle(fontSize: 13),
                          ),
                          leading: IconButton(
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: Colors.green,
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => Peta(
                                        documentSnapshot: doc,
                                      )),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => Update(
                                        document: doc,
                                      )),
                            ),
                          ),
                          onTap: () => Scaffold.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(doc.data['judul']),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 5),
                              action: SnackBarAction(
                                textColor: Colors.white,
                                label: "Hapus?",
                                onPressed: () => hapus(context, doc),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
            }
          },
        ),
      ),
    );
  }

  hapus(BuildContext context, DocumentSnapshot doc) async {
    showDialog(
        context: context,
        child: AlertDialog(
          content: Text("Yakin Ingin Hapus Lokasi ini?"),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Tidak", style: TextStyle(color: Colors.red)),
            ),
            FlatButton(
              onPressed: () async {
                await ref
                    .document(doc.documentID)
                    .delete()
                    .whenComplete(() => Navigator.of(context).pop());
              },
              child: Text("Ya", style: TextStyle(color: Colors.green)),
            ),
          ],
        ));
  }
}

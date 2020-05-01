import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class Update extends StatefulWidget {
  final DocumentSnapshot document;

  const Update({Key key, this.document}) : super(key: key);
  @override
  _UpdateState createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  DocumentSnapshot get doc => widget.document;
  File _image;
  CollectionReference ref = Firestore.instance.collection("lokasi");
  final Geolocator _geo = new Geolocator()..forceAndroidLocationManager;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  var judul = TextEditingController();
  var lat = TextEditingController();
  var long = TextEditingController();
  var desk = TextEditingController();

  @override
  void initState() {
    setState(() {
      isLoading = false;
      judul.text = doc.data['judul'];
      lat.text = doc.data['latitude'].toString();
      long.text = doc.data['longitude'].toString();
      desk.text = doc.data['deskripsi'];
      _image = null;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Update Lokasi"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.edit, size: 40),
        onPressed: () => ubahLokasi(context)
          ..whenComplete(() {
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Lokasi Berhasil Diubah"),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ));
            Timer(Duration(seconds: 4), () {
              Navigator.of(scaffoldKey.currentContext).pop();
            });
          })
          ..catchError((e) {
            print("Error: $e");
          }),
      ),
      body: !isLoading
          ? SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Column(
                  children: <Widget>[
                    image(),
                    imagePicker(),
                    SizedBox(height: 10),
                    TextFormField(
                        controller: judul,
                        decoration: InputDecoration(
                            border:
                                OutlineInputBorder(borderSide: BorderSide()),
                            labelText: "Judul",
                            suffixIcon: Icon(Icons.create))),
                    SizedBox(height: 10),
                    TextFormField(
                        controller: lat,
                        readOnly: true,
                        onTap: getLocation,
                        decoration: InputDecoration(
                            border:
                                OutlineInputBorder(borderSide: BorderSide()),
                            labelText: "Latitude",
                            suffixIcon: Icon(Icons.place))),
                    SizedBox(height: 10),
                    TextFormField(
                        controller: long,
                        onTap: getLocation,
                        readOnly: true,
                        decoration: InputDecoration(
                            border:
                                OutlineInputBorder(borderSide: BorderSide()),
                            labelText: "Longitude",
                            suffixIcon: Icon(Icons.place))),
                    SizedBox(height: 10),
                    TextFormField(
                        controller: desk,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            border:
                                OutlineInputBorder(borderSide: BorderSide()),
                            labelText: "Deskripsi",
                            suffixIcon: Icon(Icons.description))),
                  ],
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget image() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Image(
        image:
            _image != null ? FileImage(_image) : NetworkImage(doc.data['foto']),
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Widget imagePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        RaisedButton(
          onPressed: () async {
            var image = await ImagePicker.pickImage(source: ImageSource.camera);

            setState(() {
              _image = image;
            });
          },
          child: Icon(Icons.camera_alt),
        ),
        RaisedButton(
          onPressed: () async {
            var image =
                await ImagePicker.pickImage(source: ImageSource.gallery);

            setState(() {
              _image = image;
            });
          },
          child: Icon(Icons.image),
        ),
      ],
    );
  }

  imageFile() async {}

  Future ubahLokasi(BuildContext context) async {
    StorageReference stoRef = _image != null
        ? FirebaseStorage.instance.ref().child(_image.path)
        : null;
    StorageUploadTask task = _image != null ? stoRef.putFile(_image) : null;

    String imageUrl = _image != null
        ? await (await task.onComplete).ref.getDownloadURL()
        : doc.data['foto'];

    setState(() {
      isLoading = true;
    });

    return await ref.document(doc.documentID).updateData({
      'judul': judul.text,
      'latitude': double.parse(lat.text),
      'longitude': double.parse(long.text),
      'deskripsi': desk.text,
      'foto': imageUrl.toString(),
    }).whenComplete(
      () => setState(() {
        isLoading = false;
        judul.text = '';
        lat.text = '';
        long.text = '';
        desk.text = '';
        _image = null;
      }),
    );
  }

  getLocation() async {
    if (lat.text == '' && long.text == '') {
      await _geo
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((Position getPosition) {
        setState(() {
          lat.text = getPosition.latitude.toString();
          long.text = getPosition.longitude.toString();
        });
      }).catchError((e) {
        print("$e");
      });
    }
  }
}

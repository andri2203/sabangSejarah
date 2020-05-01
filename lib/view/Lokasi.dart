import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class Lokasi extends StatefulWidget {
  @override
  _LokasiState createState() => _LokasiState();
}

class _LokasiState extends State<Lokasi> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Tambah Lokasi"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, size: 40),
        onPressed: () => tambahLokasi(context)
          ..whenComplete(() {
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Lokasi Berhasil Ditambahkan"),
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
                    if (_image != null) image(),
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
        image: FileImage(_image),
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

  Future tambahLokasi(BuildContext context) async {
    StorageReference stoRef = FirebaseStorage.instance.ref().child(_image.path);
    StorageUploadTask task = stoRef.putFile(_image);

    String imageUrl = await (await task.onComplete).ref.getDownloadURL();

    setState(() {
      isLoading = true;
    });

    return await ref.document().setData({
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

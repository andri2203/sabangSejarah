import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sabang/view/Peta.dart';
import 'package:sabang/view/login.dart';

class Beranda extends StatefulWidget {
  @override
  _BerandaState createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  CollectionReference ref = Firestore.instance.collection("lokasi");
  final Geolocator _geo = new Geolocator()..forceAndroidLocationManager;
  Position position;
  String _address = "";
  double distance = 0.0;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  getLocation() async {
    await _geo
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position getPosition) {
      setState(() {
        position = getPosition;
        print("$getPosition");
      });
      getAddress(getPosition);
    }).catchError((e) {
      print("$e");
    });
  }

  getAddress(Position _position) async {
    try {
      List<Placemark> p = await _geo.placemarkFromCoordinates(
          _position.latitude, _position.longitude);

      Placemark place = p[0];

      setState(() {
        _address =
            "${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}";
        print(_address);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.all(0.0),
              child: Image(
                image: AssetImage("img/header.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Login"),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => Login())),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              header(context), // Header Atas
              Expanded(child: body(context)), // Body / Data
            ],
          ),
        ),
      ),
    );
  }

  Widget header(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Sabang",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 5.0)),
          Text(
            "Jelajahi Sejarah Kota Sabang",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black38,
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 5.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.place, color: Colors.green, size: 12),
              Padding(padding: EdgeInsets.only(right: 5.0)),
              Text(_address,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12.0,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget body(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 10.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: ref.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Text("Loading..");
          return ListView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            children: snapshot.data.documents.map((DocumentSnapshot document) {
              return GestureDetector(
                onTap: () => Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Peta(documentSnapshot: document),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      var begin = Offset(0.0, 1.0);
                      var end = Offset.zero;
                      var curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    })),
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.33,
                  margin: EdgeInsets.only(bottom: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(document["foto"]),
                      )),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: Text(document["judul"],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            )),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

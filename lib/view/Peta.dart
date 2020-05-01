import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Peta extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const Peta({Key key, this.documentSnapshot}) : super(key: key);
  @override
  _PetaState createState() => _PetaState();
}

class _PetaState extends State<Peta> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  DocumentSnapshot get document => widget.documentSnapshot;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBar(context),
        body: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          mapType: MapType.satellite,
          initialCameraPosition: CameraPosition(
            target: LatLng(document['latitude'], document['longitude']),
            zoom: 14.3,
          ),
          markers: {
            Marker(
              markerId: MarkerId("${document.documentID}"),
              position: LatLng(document['latitude'], document['longitude']),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
          },
          mapToolbarEnabled: true,
        ),
      ),
    );
  }

  void _showDetail(context) {
    showModalBottomSheet(
        enableDrag: true,
        context: context,
        builder: (builder) {
          return Container(
            child: Column(
              children: <Widget>[
                Image(
                  height: 200,
                  image: NetworkImage(document['foto']),
                  fit: BoxFit.fitWidth,
                ),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    document['deskripsi'],
                    softWrap: true,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget appBar(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.green,
      title: Text(
        document['judul'],
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        softWrap: true,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {
            _showDetail(context);
          },
        )
      ],
    );
  }
}

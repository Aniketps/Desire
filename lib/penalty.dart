import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class penalty extends StatefulWidget {
  @override
  _penalty createState() => _penalty();
}

class _penalty extends State<penalty> {
  bool isLoading = true;
  LatLng? currentLocation;
  late StreamSubscription<Position> positionStream;
  

  @override
  void initState() {
    super.initState();
    startLocationUpdates();
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  List<LatLng> points = [];

  Future<void> startLocationUpdates() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("AccessPoint")
        .get();

    for (var doc in querySnapshot.docs) {
        String latitude = doc['lat']; // Access 'lat' field
        String longitude = doc['long']; // Access 'long' field
        points.add(LatLng(double.parse(latitude), double.parse(longitude))); // Add to points list
    }

    Geolocator.requestPermission().then((LocationPermission permission) {
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        positionStream = Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          setState(() {
            currentLocation = LatLng(position.latitude, position.longitude);
            isLoading = false;
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("Location permission denied");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/main.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0x66010018),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        child: Text(
                          "Penalty Set up",
                          style: GoogleFonts.itim(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      _buildInputFields(),
                      _buildAccessPointsMap(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInputFields() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.86,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          width: 2,
          color: Color(0x664300fb),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            _buildInputRow("Keeper", "50₹"),
            _buildTextField("UPI ID"),
            _buildTextField("Who is your desire"),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "The System Uses me, And I use the System",
                style: GoogleFonts.itim(
                  color: Colors.white,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.itim(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        Text(
          price,
          style: GoogleFonts.itim(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      style: GoogleFonts.itim(
        textStyle: TextStyle(color: Colors.white),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white54),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xff9D8AFF), width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xff9D8AFF), width: 2.0),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xff9D8AFF)),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xff9D8AFF)),
        ),
      ),
    );
  }

  Widget _buildAccessPointsMap() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            "Access Point",
            style: GoogleFonts.itim(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          width: MediaQuery.of(context).size.width * 0.86,
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              width: 2,
              color: Color(0x664300fb),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 2,
                  color: Color(0x664300fb),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FlutterMap(
                  options: MapOptions(
                    center: currentLocation ?? LatLng(0, 0),
                    zoom: 14.0,
                    onLongPress: (tapPosition, point) async {
                      double offset = 0.003;

                      // Update top-right corner (swapping lat and long)
                      await FirebaseFirestore.instance.collection("AccessPoint").doc("F6YfpROjlq7fXAzIgdzB").update({
                        "lat": (point.latitude + offset).toString(),
                        "long": (point.longitude + offset).toString(),
                      });

                      // Update top-left corner (swapping lat and long)
                      await FirebaseFirestore.instance.collection("AccessPoint").doc("HbZK7kBvtCVJDViEnntV").update({
                        "lat": (point.latitude + offset).toString(),
                        "long": (point.longitude - offset).toString(),
                      });

                      // Update bottom-right corner (swapping lat and long)
                      await FirebaseFirestore.instance.collection("AccessPoint").doc("WN2YXv0tN5NvT6eUIrbP").update({
                        "lat": (point.latitude - offset).toString(),
                        "long": (point.longitude - offset).toString(),
                      });

                      // Update bottom-left corner (swapping lat and long)
                      await FirebaseFirestore.instance.collection("AccessPoint").doc("ZQR0o4oX4I8INoczj2sZ").update({
                        "lat": (point.latitude - offset).toString(),
                        "long": (point.longitude + offset).toString(),
                      });

                      // Optional: Update the center point (no swap)
                      await FirebaseFirestore.instance.collection("AccessPoint").doc("fnYcdPSQKAtS4KyfoJ2m").update({
                        "lat": (point.latitude + offset).toString(),
                        "long": (point.longitude + offset).toString(),
                      });

                      await FirebaseFirestore.instance.collection("TempAccess").doc("iAsUQEMZs6vxaZuv6IN0").update({
                        "lat": (point.latitude).toString(),
                        "long": (point.longitude).toString(),
                      });

                      Fluttertoast.showToast(msg: "Updated");

                      // Refresh the page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => penalty()),
                      );
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          strokeWidth: 2.0,
                          color: Colors.blue,
                          borderColor: Colors.green,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentLocation ?? LatLng(0, 0),
                          child: Icon(Icons.location_history),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

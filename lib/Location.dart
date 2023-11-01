import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dashboard.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  String data = '';

  // @override
  // void initState() {
  //   super.initState();
  //   checkLocationStatus();
  // }

  void checkLocationStatus() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Turn On Location'),
          content:
              Text('Please turn on your location to continue using the app.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Ok'),
            ),
          ],
        ),
      );
    }
  }

  // getLocation() async {
  //   var status = await Permission.location.request();
  //   if (status == PermissionStatus.granted) {
  //     Position datas = await determinedPosition();
  //     GetAddressfromLatLong(datas);
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => Dashboard()),
  //     );
  //   }
  // }

  void GetAddressfromLatLong(Position datas) async {
    List<Placemark> placeMark =
        await placemarkFromCoordinates(datas.latitude, datas.longitude);
    Placemark places = placeMark[0];
    var address =
        "${places.locality},${places.street}, ${places.thoroughfare} ${places.country}";
    setState(() {
      data = address;
    });
    print(data); // Print the current location
    // Store the driver's location in Firestore
// QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collectionGroup("All_Orders")
//         .where("Driver_uid", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
//         .get();
//     if (querySnapshot.docs.isNotEmpty) {
//       for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
//         await docSnapshot.reference.update({
//           "Driver_latitude": datas.latitude,
//           "Driver_longitude": datas.longitude,
//         });
//       }
//     }
    await FirebaseFirestore.instance
        .collection("All_Drivers")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      "Driver_latitude": datas.latitude,
      "Driver_longitude": datas.longitude,
      "Driver_Address": data.toString(),
    });
  }

  // void updateDriverLocation(Position position) async {
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collectionGroup("All_Orders")
  //       .where("Driver_uid", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
  //       .get();

  //   for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
  //     await docSnapshot.reference.update({
  //       "Driver_latitude": position.latitude,
  //       "Driver_longitude": position.longitude,
  //     });
  //   }
  // }

  // Timer? locationUpdateTimer;

  // void startLocationUpdates() {
  //   locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
  //     Position position = await determinedPosition();
  //     updateDriverLocation(position);
  //   });
  // }

  // void stopLocationUpdates() {
  //   locationUpdateTimer?.cancel();
  // }

  determinedPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled == false) {
      return Future.error("Location service are disabled");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions denied forever");
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  Timer? locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    checkLocationStatus();
  }

  void startLocationUpdates() async {
    locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      Position position = await determinedPosition();
      await updateDriverLocation(position);
    });
  }

  void stopLocationUpdates() {
    locationUpdateTimer?.cancel();
  }

  getLocation() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      Position datas = await determinedPosition();
      GetAddressfromLatLong(datas);
      updateDriverLocation(datas);

      startLocationUpdates(); // Start location updates here
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    }
  }

  updateDriverLocation(Position position) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collectionGroup("All_Orders")
        .where("Driver_uid", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference.update({
        "Driver_latitude": position.latitude,
        "Driver_longitude": position.longitude,
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Location",
          style: TextStyle(
              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orange,
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
        ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
        child: ListView(
          children: [
            Text('Current Location',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              height: 25,
            ),
            Text(
                'Please enter your location or allow access to\nyour location to find restaurants near you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17.0, color: Color.fromRGBO(164, 164, 164, 1))),
            SizedBox(
              height: 30,
            ),
            Text('Do not Turn Off Your Location!!!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19.0,
                    color: Color.fromRGBO(164, 164, 164, 1))),
            SizedBox(
              height: 40,
            ),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                  side: const BorderSide(width: 2, color: Colors.orange),
                ),
                onPressed: () async {
                  await getLocation();

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Dashboard()));
                },
                icon: Icon(
                  Icons.ios_share,
                  color: Colors.orange,
                  size: 24.0,
                ),
                label: Text(
                  'Use current location',
                  style: TextStyle(color: Colors.orange, fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

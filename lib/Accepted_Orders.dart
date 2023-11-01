// ignore_for_file: unused_element

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/signUp.dart';
import 'package:driver_app/splashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loc;

class AcceptedOrders extends ConsumerStatefulWidget {
  const AcceptedOrders({Key? key});

  @override
  ConsumerState<AcceptedOrders> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<AcceptedOrders> {
  List fetchAllOrders = [];
  StreamController<List<DocumentSnapshot>> _streamController =
      StreamController<List<DocumentSnapshot>>();
  Stream<List<DocumentSnapshot>> get stream => _streamController.stream;
  String data = '';

  @override
  void initState() {
    super.initState();
    checkLocationStatus();
    getUserLatitude();
    getUserLongitude();
    getDriverUID();
    getDriverName();
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

  getLocation(orderId, storeUid) async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      Position datas = await determinedPosition();
      GetAddressfromLatLong(datas);
      // _listenLocation(orderId, storeUid);
      updateDriverLocation(datas);

      startLocationUpdates(); // Start location updates here
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => AcceptedOrders()),
      // );
    }
  }

  Timer? locationUpdateTimer;

  void startLocationUpdates() async {
    locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      Position position = await determinedPosition();
      await updateDriverLocation(position);
    });
  }

  final loc.Location location = loc.Location();

  StreamSubscription<loc.LocationData>? _locationSubscription;

  // Future<void> _listenLocation(orderId, storeUid) async {
  //   _locationSubscription = location.onLocationChanged.handleError((onError) {
  //     print(onError);
  //     _locationSubscription?.cancel();
  //     setState(() {
  //       _locationSubscription = null;
  //     });
  //   }).listen((loc.LocationData currentlocation) async {
  //     await FirebaseFirestore.instance
  //         .collection("All_Restraunts")
  //         .doc(storeUid)
  //         .collection('All_Orders')
  //         .doc(orderId.id)
  //         .update({
  //       "Driver_latitude": currentlocation.latitude,
  //       "Driver_longitude": currentlocation.longitude,
  //     });
  //   });
  // }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

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
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collectionGroup("All_Orders")
        .where("Driver_uid", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.update({
          "Driver_latitude": datas.latitude,
          "Driver_longitude": datas.longitude,
        });
      }
    }
  }

  void checkLocationStatus() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      await FirebaseFirestore.instance
          .collection("All_Drivers")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        "Location_Status": "false",
      });
    } else if (isLocationServiceEnabled) {
      await FirebaseFirestore.instance
          .collection("All_Drivers")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        "Location_Status": "true",
      });
    }
  }

  var driverLatitude;
  var driverLongitude;
  var driverUid;
  var driverName;
  LatLng restaurantLocation = LatLng(0, 0);
  Future getUserLatitude() async {
    await FirebaseFirestore.instance
        .collection('All_Drivers')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      setState(() {
        driverLatitude = value.data()?['Driver_latitude'];
        print(driverLatitude);
      });
    });
  }

  Future getDriverName() async {
    await FirebaseFirestore.instance
        .collection('All_Drivers')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      setState(() {
        driverName = value.data()?['Driver_name'];
        print(driverName);
      });
    });
  }

  Future getDriverUID() async {
    await FirebaseFirestore.instance
        .collection('All_Drivers')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      setState(() {
        driverUid = value.data()?['uid'];
        print(driverUid);
      });
    });
  }

  Future getUserLongitude() async {
    await FirebaseFirestore.instance
        .collection('All_Drivers')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      setState(() {
        driverLongitude = value.data()?['Driver_longitude'];
        print(driverLongitude);
      });
    });
  }

  sendNotToResForOrderAccept(
    token,
    productName,
  ) async {
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

      var body = {
        "to": token,
        "notification": {
          "title": "Order Accepted",
          "body": "${driverName} has accepted your order for ${productName}",
        },
      };

      var response = await post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              "key=AAAAbXwSTlU:APA91bEvCpFMnWOvco-UbHMGzWOsK8yTRqL1PxHwRBCjIKcRlsYKMb1mH-P9to-VkDcIsQUOhQPq0s1XoMdEZzbpFhrGGDfV1TRqQiWreVnUPPTnGfiK8Nrw4yX-bfxYTZuYrceTZ5SH",
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print("Sending Notification to ${token}");

      print("Send Notification successfully");
    } catch (e) {
      print("Notification-Error: $e");
    }
  }

  sendNotToResForArrival(token, restrauntName) async {
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

      var body = {
        "to": token,
        "notification": {
          "title": "Driver Arrived",
          "body": "${driverName} has arrived at ${restrauntName}",
        },
      };

      var response = await post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              "key=AAAAbXwSTlU:APA91bEvCpFMnWOvco-UbHMGzWOsK8yTRqL1PxHwRBCjIKcRlsYKMb1mH-P9to-VkDcIsQUOhQPq0s1XoMdEZzbpFhrGGDfV1TRqQiWreVnUPPTnGfiK8Nrw4yX-bfxYTZuYrceTZ5SH",
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print("Sending Notification to ${token}");

      print("Send Notification successfully");
    } catch (e) {
      print("Notification-Error: $e");
    }
  }

  sendOrderPlacedNotToUser(token, product, userName, userLocation) async {
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

      var body = {
        "to": token,
        "notification": {
          "title": "Order Placed",
          "body":
              "${userName}'s Order for ${product} has been placed at ${userLocation} ",
        },
      };

      var response = await post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              "key=AAAAbXwSTlU:APA91bEvCpFMnWOvco-UbHMGzWOsK8yTRqL1PxHwRBCjIKcRlsYKMb1mH-P9to-VkDcIsQUOhQPq0s1XoMdEZzbpFhrGGDfV1TRqQiWreVnUPPTnGfiK8Nrw4yX-bfxYTZuYrceTZ5SH",
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print("Sending Notification to ${token}");

      print("Send Notification successfully");
    } catch (e) {
      print("Notification-Error: $e");
    }
  }

  sendOrderPlaceNotiTorestraunt(token, product, userName, userLocation) async {
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

      var body = {
        "to": token,
        "notification": {
          "title": "Order Placed",
          "body":
              "${userName}'s Order for ${product} has been placed at ${userLocation} ",
        },
      };

      var response = await post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              "key=AAAAbXwSTlU:APA91bEvCpFMnWOvco-UbHMGzWOsK8yTRqL1PxHwRBCjIKcRlsYKMb1mH-P9to-VkDcIsQUOhQPq0s1XoMdEZzbpFhrGGDfV1TRqQiWreVnUPPTnGfiK8Nrw4yX-bfxYTZuYrceTZ5SH",
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print("Sending Notification to ${token}");

      print("Send Notification successfully");
    } catch (e) {
      print("Notification-Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.orange,
        title: const Text(
          "Accepted Orders",
          style: TextStyle(
              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("All_Drivers")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data?.data()?["Location_Status"] == "false") {
              return Center(
                child: Container(
                  height: 100,
                  width: 250,
                  color: Colors.orange,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Please turn on your location to continue using the app.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            } 
            // else if (snapshot.data?.data()?["Location_Status"] == "true") {}
            if (snapshot.data?.data()?["driverStatus"] == "Pending" ||
                snapshot.data?.data()?["driverStatus"] == "Disapproved") {
              return Center(
                child: Container(
                  height: 80,
                  width: 250,
                  color: Colors.orange,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Your account is not\nApproved yet!!!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            } else if (snapshot.data?.data()?["driverStatus"] == "Approved") {
              // return Center(child: Text("Approved"));
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collectionGroup("All_Orders")
                    .orderBy("OrderTime", descending: true)
                    .where("statusByDriver", isEqualTo: "Accepted")
                    .where("deliverStatus", isEqualTo: "false")
                    .where("Driver_uid",
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final allOrders = snapshot.data!.docs[index];
                        fetchAllOrders = allOrders["products"] ?? [];
                        DocumentSnapshot orderId = snapshot.data!.docs[index];
                        final time = allOrders["OrderTime"] as Timestamp;
                        // final docIdOfOrder = snapshot.data?.docs[index].id;
                        DateTime dateTime = time.toDate();
                        String formattedDate =
                            DateFormat('EEE, M/d/y').format(dateTime);
                        String formattedTime =
                            DateFormat('h:mm a').format(dateTime);

                        return Column(
                          children: [
                            for (var orderItem in fetchAllOrders)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 10, 15, 20),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: Colors.grey,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      orderItem["ProductImage"],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                orderItem["ProductName"],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 17,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              if (orderItem["statusByDriver"] ==
                                                  "Accepted")
                                                Icon(Icons.check_circle,
                                                    color: Colors.green),
                                              if (orderItem["statusByDriver"] ==
                                                  "Rejected")
                                                Icon(Icons.cancel,
                                                    color: Colors.red),
                                              if (allOrders["status"] ==
                                                  "Pending")
                                                Icon(Icons.pending,
                                                    color: Colors.orange),
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      DefaultTextStyle(
                                        style: const TextStyle(
                                            color: Colors.black54),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "Description: ${orderItem["ProductDescription"]}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 5,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 0),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "Special Instructions:  ${orderItem["ProductSpecialInstructions"] ?? "Not Added"}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 5,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Restraunt: ${orderItem["Store_Name"]}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Restraunt Location: ${orderItem["Store_Location"]}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                ),
                                                maxLines: 7,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Order Time: ${formattedTime}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Order Date: ${formattedDate}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Buyer Location: ${allOrders["UserLocation"]}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                ),
                                                maxLines: 7,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Buyer Name: ${allOrders["UserName"]} ",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            if (orderItem
                                                .containsKey("Side_Items"))
                                              Column(
                                                children: [
                                                  for (var sideItem
                                                      in orderItem[
                                                          "Side_Items"])
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Side Item:     ${sideItem["SideItemName"]}",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        Text(
                                                          "Price: ${sideItem["SideItemPrice"]}",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Restraunt Status: ${allOrders["status"]}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.orange,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Driver Status: ${allOrders["statusByDriver"] ?? ""}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.orange,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Quantity: ${orderItem["ProductQuantity"]}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5),
                                                  child: Text(
                                                    "Total:  ${orderItem["totalPrice"]}",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.orange),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Material(
                                                  color: Colors.orange,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(6.0),
                                                  ),
                                                  child: MaterialButton(
                                                    onPressed: () async {
                                                      final storeUid =
                                                          orderItem[
                                                              "Store_uid"];
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              "All_Restraunts")
                                                          .doc(storeUid)
                                                          .collection(
                                                              'All_Orders')
                                                          .doc(orderId.id)
                                                          .update({
                                                        'driverArrived': 'true',
                                                      });
                                                      await getLocation(
                                                          orderId, storeUid);
                                                      await sendNotToResForArrival(
                                                        allOrders[
                                                            "Store_token"],
                                                        orderItem["Store_Name"],
                                                      );
                                                    },
                                                    child: Text(
                                                      "Arrived",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Material(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(6.0),
                                                  ),
                                                  child: MaterialButton(
                                                    onPressed: () async {
                                                      final storeUid =
                                                          orderItem[
                                                              "Store_uid"];
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              "All_Restraunts")
                                                          .doc(storeUid)
                                                          .collection(
                                                              'All_Orders')
                                                          .doc(orderId.id)
                                                          .update({
                                                        'deliverStatus': 'true',
                                                      });
                                                      await getLocation(
                                                          orderId, storeUid);
                                                      await sendOrderPlacedNotToUser(
                                                        allOrders["UserToken"],
                                                        orderItem[
                                                            "ProductName"],
                                                        allOrders["UserName"],
                                                        allOrders[
                                                            "UserLocation"],
                                                      );
                                                      await sendOrderPlaceNotiTorestraunt(
                                                        allOrders[
                                                            "Store_token"],
                                                        orderItem[
                                                            "ProductName"],
                                                        allOrders["UserName"],
                                                        allOrders[
                                                            "UserLocation"],
                                                      );
                                                    },
                                                    child: Text(
                                                      "Order Placed",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // SizedBox(width: 7),
                                                // Material(
                                                //   color: Colors.green,
                                                //   borderRadius:
                                                //       BorderRadius.all(
                                                //     Radius.circular(6.0),
                                                //   ),
                                                //   child: MaterialButton(
                                                //     onPressed: () async {
                                                //       final storeUid =
                                                //           orderItem[
                                                //               "Store_uid"];
                                                //       await FirebaseFirestore
                                                //           .instance
                                                //           .collection(
                                                //               "All_Restraunts")
                                                //           .doc(storeUid)
                                                //           .collection(
                                                //               'All_Orders')
                                                //           .doc(orderId.id)
                                                //           .update({
                                                //         'statusByDriver':
                                                //             'Accepted',
                                                //         "Driver_uid":
                                                //             FirebaseAuth
                                                //                 .instance
                                                //                 .currentUser
                                                //                 ?.uid,
                                                //         "Driver_latitude":
                                                //             driverLatitude,
                                                //         "Driver_longitude":
                                                //             driverLongitude,
                                                //       });
                                                //       await getLocation(
                                                //           orderId, storeUid);
                                                //       await sendNotToResForOrderAccept(
                                                //         allOrders[
                                                //             "Store_token"],
                                                //         orderItem[
                                                //             "ProductName"],
                                                //       );
                                                //     },
                                                //     child: Text(
                                                //       "Accept",
                                                //       style: TextStyle(
                                                //         fontSize: 16,
                                                //         color: Colors.white,
                                                //       ),
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                        // } else {
                        //   return const SizedBox.shrink();
                        // }
                      },
                    );
                  } else {
                    return Center(
                      child: Container(
                        height: 100,
                        width: 250,
                        color: Colors.orange,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "No Orders yet!!!\nPlease wait for the orders.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            } else {
              return Center(child: Text("Nothing to show"));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

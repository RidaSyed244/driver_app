import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/Accepted_Orders.dart';
import 'package:driver_app/Delivered_Orders.dart';
import 'package:driver_app/Statemanagement/UserModel.dart';
import 'package:driver_app/dashboard.dart';
import 'package:driver_app/splashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// final logOut = StateNotifierProvider((ref) => AllNotifier());

class NavBar extends ConsumerWidget {
  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Drawer(
        child: ListView(
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(
            "${driverName}",
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          accountEmail: Text(
            "${driverEmail}",
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
          ),
          // currentAccountPicture: CircleAvatar(
          //   radius: 23,
          //   backgroundColor: Colors.black,
          //   child: NetworkImage(data.image.toString()) == true
          //       ? Container(
          //           decoration: BoxDecoration(
          //               color: Colors.black,
          //               borderRadius: BorderRadius.circular(55)),
          //           width: 100,
          //           height: 100,
          //         )
          //       : CircleAvatar(
          //           radius: 55,
          //           backgroundImage: NetworkImage(data.image.toString()),
          //         ),
          // ),
          decoration: BoxDecoration(
            color: Colors.orange,
          ),
        ),
        ListTile(
          title: Text("Delivered Orders"),
          leading: Icon(Icons.person),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DeliveredOrders()));
          },
        ),
        ListTile(
          title: Text("Accepted Orders"),
          leading: Icon(Icons.image),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AcceptedOrders()));
          },
        ),

        ListTile(
          title: Text("Log Out"),
          leading: Icon(Icons.pending),
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('email');
            FirebaseAuth.instance.signOut();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SplashScreen()));
          },
        ),
        // ListTile(
        //   title: Text("Ratings and Reviews"),
        //   leading: Icon(Icons.reviews),
        //   onTap: () {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => AddRatings(
        //                   orderDocId: '',
        //                 )));
        //   },
        // ),
        // ListTile(
        //   title: Text("Accepted Orders"),
        //   leading: Icon(Icons.image),
        //   onTap: () {
        //     Navigator.push(context,
        //         MaterialPageRoute(builder: (context) => AcceptedOrders()));
        //   },
        // ),

        // ListTile(
        //   title: Text("Logout"),
        //   leading: Icon(Icons.logout),
        //   onTap: () async {
        //     // await ref
        //     //     .read(logOut.notifier)
        //     //     .signout()
        //     //     .then((value) => Navigator.push(
        //     //           context,
        //     //           MaterialPageRoute(builder: (context) => LogIn()),
        //     //         ));
        //   },
        // ),
      ],
    ));
  }
}

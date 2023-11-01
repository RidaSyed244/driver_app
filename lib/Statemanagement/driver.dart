import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'UserModel.dart';

final validation = StateNotifierProvider((ref) => DriverData());
StreamController<List<DocumentSnapshot>> streamController =
    StreamController<List<DocumentSnapshot>>();
Stream get stream => streamController.stream;

final allDrivers = FirebaseFirestore.instance
            .collection("Drivers")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots()
                .map((event) => AllDriverss.fromMap(event.data() ?? {}));

final driversss = StreamProvider((ref) {
  return allDrivers;
});

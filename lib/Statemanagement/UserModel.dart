// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/logIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isNameValid = false;
bool isPasswordValid = false;
bool isEmailValid = false;
bool isValidEmail = false;
bool isPhoneValid = false;
final cnicController = TextEditingController();
bool isCnicValid = false;
File? IDCard;
File? DLImage;
final licenseImage = TextEditingController();
final idCardImage = TextEditingController();
final phoneController = TextEditingController();
final emailController = TextEditingController();
final passwordController = TextEditingController();
final nameController = TextEditingController();
final ImagePicker _picker = ImagePicker();
final logoutAuth = FirebaseAuth.instance;
final logInAuth = FirebaseAuth.instance;
final forgotPswrdAuth = FirebaseAuth.instance;

class DriverData extends StateNotifier {
  DriverData() : super('');

  emailValidation(String value) {
    final emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

    isValidEmail = RegExp(emailRegex).hasMatch(value);
  }

  validateEmail(String value) {
    final emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

    isEmailValid = RegExp(emailRegex).hasMatch(value);
  }

  cnicValidation(String value) {
    final cnicRegex =
        r'^\d{5}-\d{7}-\d{1}$'; // Assuming a XXXXX-XXXXXXX-X format

    isCnicValid = RegExp(cnicRegex).hasMatch(value);
  }

  phoneValidation(String value) {
    final phoneRegex =
        r'^[0-9]{10}$'; // Assuming a 10-digit phone number format

    isPhoneValid = RegExp(phoneRegex).hasMatch(value);
  }

  passwordValidation(String value) {
    if (passwordController.text.length < 6) {
      isPasswordValid = false;
      return "Password must be at least 6 characters";
    } else {
      isPasswordValid = true;
    }
  }

  nameValidation(String value) {
    if (nameController.text.length < 3) {
      isNameValid = false;
      return "Name must be at least 3 characters";
    } else {
      isNameValid = true;
    }
  }

  SignUp() async {
    UserCredential result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
    User? user = result.user;

    return user;
  }

  Future logInUser() async {
    return await logInAuth.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
  }
getToken(){
  FirebaseFirestore.instance.collection("All_Drivers").doc(
      FirebaseAuth.instance.currentUser?.uid).update({
        "Driver_token": token,
  }
  );
}
  Future forgotPassword() async {
    await forgotPswrdAuth.sendPasswordResetEmail(email: emailController.text);
  }

  Future signout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    return await logoutAuth.signOut();
  }

  Future<void> chooseIDCardImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      IDCard = File(pickedFile.path);
      idCardImage.text = IDCard!.path;
    } else {
      print('No image selected.');
    }
  }

  Future<void> chooseIDCardImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      IDCard = File(pickedFile.path);
      idCardImage.text = IDCard!.path;
    } else {
      print('No image selected.');
    }
  }

  Future<String?> uploadIDCardImage() async {
    if (IDCard == null) return null;

    final fileName = basename(IDCard!.path);
    final destination = 'IDCardImages/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('file');
      final task = await ref.putFile(IDCard!);
      final downloadURL = await task.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error occurred while uploading ID card image: $e');
      return null;
    }
  }

  Future<void> chooseDrivingLicenseImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      DLImage = File(pickedFile.path);
      licenseImage.text = DLImage!.path;
    } else {
      print('No image selected.');
    }
  }

  Future<void> chooseDrivingLicenseImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      DLImage = File(pickedFile.path);
      licenseImage.text = DLImage!.path;
    } else {
      print('No image selected.');
    }
  }

  Future<String?> uploadDrivingLicenseImage() async {
    if (DLImage == null) return null;

    final fileName = basename(DLImage!.path);
    final destination = 'DrivingLicenseImages/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('file');
      final task = await ref.putFile(DLImage!);
      final downloadURL = await task.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error occurred while uploading driving license image: $e');
      return null;
    }
  }

  Future<void> uploadImagesAndData() async {
    // Collect user data
    final email = emailController.text;
    final name = nameController.text;
    final password = passwordController.text;
    final phoneNumber = phoneController.text;
    final cnic = cnicController.text;

    // Upload images to Firebase Storage
    final String? idCardImageUrl = await uploadIDCardImage();
    final String? licenseImageUrl = await uploadDrivingLicenseImage();

    if (idCardImageUrl == null || licenseImageUrl == null) {
      print('Error occurred while uploading images');
      return;
    }

    // Save the user data to Firestore
    final userMap = {
      'Driver_email': email,
      'Driver_name': name,
      'password': password,
      'Driver_Phone': phoneNumber,
      'CNIC_No': cnic,
      'IDCardImageUrl': idCardImageUrl,
      'DrivingLicenseImageUrl': licenseImageUrl,
      "driverStatus": "Pending",
      "uid": FirebaseAuth.instance.currentUser?.uid
    };

    try {
      await FirebaseFirestore.instance
          .collection('All_Drivers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set(userMap);
      print('User data uploaded successfully!');
    } catch (e) {
      print('Error occurred while uploading user data: $e');
    }
  }
}

class AcceptedOrdersByRestraunts {
  final String? ProductImage;
  final String? ProductName;
  final String? ProductDescription;
  final String? Store_Name;
  final String? Store_Location;
  final String? Side_Items;
  final String? SideItemName;
  final String? SideItemPrice;
  final String? ProductQuantity;
  final String? status;
  final String? totalPrice;

  AcceptedOrdersByRestraunts({
    this.ProductImage,
    this.ProductName,
    this.ProductDescription,
    this.Store_Name,
    this.Store_Location,
    this.Side_Items,
    this.SideItemName,
    this.SideItemPrice,
    this.ProductQuantity,
    this.status,
    this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ProductImage': ProductImage,
      'ProductName': ProductName,
      'ProductDescription': ProductDescription,
      'Store_Name': Store_Name,
      'Store_Location': Store_Location,
      'Side_Items': Side_Items,
      'SideItemName': SideItemName,
      'SideItemPrice': SideItemPrice,
      'ProductQuantity': ProductQuantity,
      'status': status,
      'totalPrice': totalPrice,
    };
  }

  factory AcceptedOrdersByRestraunts.fromMap(Map<String, dynamic> map) {
    return AcceptedOrdersByRestraunts(
      ProductImage:
          map['ProductImage'] != null ? map['ProductImage'] as String : null,
      ProductName:
          map['ProductName'] != null ? map['ProductName'] as String : null,
      ProductDescription: map['ProductDescription'] != null
          ? map['ProductDescription'] as String
          : null,
      Store_Name:
          map['Store_Name'] != null ? map['Store_Name'] as String : null,
      Store_Location: map['Store_Location'] != null
          ? map['Store_Location'] as String
          : null,
      Side_Items:
          map['Side_Items'] != null ? map['Side_Items'] as String : null,
      SideItemName:
          map['SideItemName'] != null ? map['SideItemName'] as String : null,
      SideItemPrice:
          map['SideItemPrice'] != null ? map['SideItemPrice'] as String : null,
      ProductQuantity: map['ProductQuantity'] != null
          ? map['ProductQuantity'] as String
          : null,
      status: map['status'] != null ? map['status'] as String : null,
      totalPrice:
          map['totalPrice'] != null ? map['totalPrice'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AcceptedOrdersByRestraunts.fromJson(String source) =>
      AcceptedOrdersByRestraunts.fromMap(
          json.decode(source) as Map<String, dynamic>);
}

class AllDriverss {
  final String? CNIC_No;
  final String? Driver_Phone;
  final String? Driver_email;
  final String? Driver_name;
  final String? DrivingLicenseImageUrl;
  final String? IDCardImageUrl;
  final String? driverStatus;

  AllDriverss({
    this.CNIC_No,
    this.Driver_Phone,
    this.Driver_email,
    this.Driver_name,
    this.DrivingLicenseImageUrl,
    this.driverStatus,
    this.IDCardImageUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'CNIC_No': CNIC_No,
      'Driver_Phone': Driver_Phone,
      'Driver_email': Driver_email,
      'Driver_name': Driver_name,
      'DrivingLicenseImageUrl': DrivingLicenseImageUrl,
      'IDCardImageUrl': IDCardImageUrl,
      'driverStatus': driverStatus,
    };
  }

  factory AllDriverss.fromMap(Map<String, dynamic> map) {
    return AllDriverss(
      CNIC_No: map['CNIC_No'] != null ? map['CNIC_No'] as String : null,
      Driver_Phone:
          map['Driver_Phone'] != null ? map['Driver_Phone'] as String : null,
      Driver_email:
          map['Driver_email'] != null ? map['Driver_email'] as String : null,
      Driver_name:
          map['Driver_name'] != null ? map['Driver_name'] as String : null,
      DrivingLicenseImageUrl: map['DrivingLicenseImageUrl'] != null
          ? map['DrivingLicenseImageUrl'] as String
          : null,
      IDCardImageUrl: map['IDCardImageUrl'] != null
          ? map['IDCardImageUrl'] as String
          : null,
      driverStatus:
          map['driverStatus'] != null ? map['driverStatus'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AllDriverss.fromJson(String source) =>
      AllDriverss.fromMap(json.decode(source) as Map<String, dynamic>);
}

import 'package:driver_app/Location.dart';
import 'package:driver_app/Statemanagement/UserModel.dart';
import 'package:driver_app/Statemanagement/driver.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ForgotPassword.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;
String? token;

class LogIn extends ConsumerStatefulWidget {
  const LogIn({super.key});

  @override
  ConsumerState<LogIn> createState() => _LogInState();
}

class _LogInState extends ConsumerState<LogIn> {
  bool isPasswordHide = true;
  void generateAndSaveToken() async {
    // Request permission for notifications
    await messaging.requestPermission();

    // Get the FCM token
    token = await messaging.getToken();
    print('FCM Token: $token');
  }

  @override
  void initState() {
    super.initState();
    generateAndSaveToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.orange,
        title: Text(
          "LogIn",
          style: TextStyle(
              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Log In to your account!",
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "To perform tasks and check if the admin\nhas approved your account, you\ncan log in to your account.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17.0, color: Colors.grey)),
              ],
            ),
            SizedBox(
              height: 40.0,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromRGBO(73, 73, 73, 1),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Enter you email",
                labelStyle: TextStyle(
                  color: Colors.black,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          "PASSWORD",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(73, 73, 73, 1),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        isPasswordHide
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordHide = !isPasswordHide;
                        });
                        passwordController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: passwordController.text.length),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Enter your Password",
                labelStyle: TextStyle(
                  color: Colors.black,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ForgotPswrd()));
                  },
                  child: Text('Forgot Password?',
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.grey,
                        textBaseline: TextBaseline.ideographic,
                      )),
                )
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Material(
                color: Colors.orange,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                child: MaterialButton(
                  onPressed: () async {
                    try {
                      final logIn =
                          await ref.read(validation.notifier).logInUser();
                      if (logIn != false) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString("email", emailController.text);
                      }
                      await ref.read(validation.notifier).getToken();

                      await Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Location()));
                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.white,
                        duration: Duration(seconds: 5),
                        content: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(238, 167, 52, 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Column(
                            children: [
                              Text('Alert!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text('Your account is not Approved yet!!!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  minWidth: 230.0,
                  height: 13.0,
                  child: Text('LOG IN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      )),
                ),
              )
            ]),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'Statemanagement/UserModel.dart';
import 'Statemanagement/driver.dart';
import 'login.dart';

class ForgotPswrd extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LogIn()));
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'Reset Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(38, 150, 38, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('No Worries!',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 40.0),
            Text('Fill the email and send request to \nreset your password.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18.0,
                )),
            SizedBox(height: 40.0),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  "Email*",
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            TextField(
              controller: emailController,
              onChanged: (value) {},
              style: TextStyle(
                color: Colors.grey,
              ),
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.mail,
                    color: Colors.grey,
                  ),
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  )),
            ),
            SizedBox(height: 40.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Material(
                color: Colors.orange,
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                child: MaterialButton(
                  onPressed: () async {
                    try {
                      await ref.read(validation.notifier).forgotPassword().then(
                          (value) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LogIn())));
                    } catch (e) {
                      print(e);
                    }
                  },
                  minWidth: 240.0,
                  height: 10.0,
                  child: Text('Send Request',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
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

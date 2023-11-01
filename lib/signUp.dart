import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'Statemanagement/UserModel.dart';
import 'Statemanagement/driver.dart';
import 'logIn.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  final nameFormKey = GlobalKey<FormState>();

  emailValidate(String value) {
    ref.read(validation.notifier).emailValidation(value);
  }

  phoneValidate(String value) {
    ref.read(validation.notifier).phoneValidation(value);
  }

  passwordValidate(String value) {
    ref.read(validation.notifier).passwordValidation(value);
  }

  nameValidate(String value) {
    ref.read(validation.notifier).nameValidation(value);
  }

  CNICvalidation(String value) {
    ref.read(validation.notifier).cnicValidation(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.orange,
          leading: IconButton(
            color: Colors.white,
            onPressed: () {
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => SignIn()));
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text(
            "SignUp",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.w600),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: ListView(children: [
                Text(
                  "Register Yourself First!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromRGBO(17, 30, 23, 1), fontSize: 30),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "To complete the registration process,\nplease provide your Name, Email,\nPassword, CNIC, etc",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17, color: Color.fromRGBO(164, 164, 164, 1)),
                ),
                SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      "FULL NAME",
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
                Form(
                  key: nameFormKey,
                  child: TextFormField(
                    controller: nameController,
                    onChanged: (value) async {
                      setState(() {
                        nameValidate(value);
                      });
                    },
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.check,
                        color: isNameValid ? Colors.orange : null,
                        size: 20,
                      ),
                      hintText: "Enter your Name",
                      hintStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.grey,
                      )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      "EMAIL ADDRESS",
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
                Form(
                  key: emailFormKey,
                  child: TextFormField(
                    controller: emailController,
                    onChanged: (value) async {
                      setState(() {
                        emailValidate(value);
                      });
                    },
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                        suffixIcon: Icon(
                          Icons.check,
                          color: isValidEmail ? Colors.orange : null,
                          size: 20,
                        ),
                        hintText: "Enter your Email",
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.grey,
                        ))),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
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
                SizedBox(
                  height: 5,
                ),
                Form(
                  key: passwordFormKey,
                  child: TextFormField(
                    // obscureText: isPasswordHide,
                    controller: passwordController,
                    onChanged: (value) async {
                      setState(() {
                        passwordValidate(value);
                      });
                    },
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.check,
                        color: isPasswordValid ? Colors.orange : null,
                        size: 20,
                      ),
                      hintText: "Enter your Password",
                      hintStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.grey,
                      )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      "Phone No.",
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
                  // obscureText: isPasswordHide,
                  controller: phoneController,
                  onChanged: (value) async {
                    setState(() {
                      phoneValidate(value);
                    });
                  },
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    suffixIcon: Icon(
                      Icons.check,
                      color: isPhoneValid ? Colors.orange : null,
                      size: 20,
                    ),
                    hintText: "Enter your Phone",
                    hintStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.grey,
                    )),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      "CNIC",
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
                  // obscureText: isPasswordHide,
                  controller: cnicController,
                  onChanged: (value) async {
                    setState(() {
                      CNICvalidation(value);
                    });
                  },
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    suffixIcon: Icon(
                      Icons.check,
                      color: isCnicValid ? Colors.orange : null,
                      size: 20,
                    ),
                    hintText: "Enter your CNIC No.",
                    hintStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.grey,
                    )),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Material(
                        color: Colors.orange,
                        borderRadius: BorderRadius.all(
                          Radius.circular(6.0),
                        ),
                        child: MaterialButton(
                          onPressed: () async {
                            showIDCardPicker(context, ref);
                          },
                          minWidth: 20.0,
                          height: 8.0,
                          child: Text(
                            '+ ID-Card Image',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ),
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Material(
                        color: Colors.orange,
                        borderRadius: BorderRadius.all(
                          Radius.circular(6.0),
                        ),
                        child: MaterialButton(
                          onPressed: () async {
                            showDrivingLicensePicker(context, ref);
                          },
                          minWidth: 20.0,
                          height: 8.0,
                          child: Text(
                            '+ Driving Liscence Image',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Material(
                    color: Colors.orange,
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    child: MaterialButton(
                      onPressed: () async {
                        await ref.read(validation.notifier).SignUp();
                      await  ref.read(validation.notifier).uploadImagesAndData();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => LogIn()));
                      },
                      minWidth: 230.0,
                      height: 10.0,
                      child: Text('SIGN UP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          )),
                    ),
                  )
                ]),
              ])),
        ));
  }

  void showIDCardPicker(context, WidgetRef ref) {
    showModalBottomSheet(
        context: context,
        builder: ((builder) => IDCardBottomSheet(context, ref)));
  }

  void showDrivingLicensePicker(context, WidgetRef ref) {
    showModalBottomSheet(
        context: context,
        builder: ((builder) => DrivingLicenseBottomSheet(context, ref)));
  }

  Widget DrivingLicenseBottomSheet(context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Driving License Image",
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  icon: Icon(
                    Icons.camera_enhance,
                    color: Colors.black,
                    size: 34,
                  ),
                  onPressed: () =>{
                    ref
                        .read(validation.notifier)
                        .chooseDrivingLicenseImageFromCamera()
                  },
                  label: Text("Camera",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      )),
                ),
                SizedBox(
                  width: 40.0,
                ),
                TextButton.icon(
                  icon: Icon(
                    Icons.image,
                    color: Colors.black,
                    size: 34,
                  ),
                  onPressed: ()=>  {
                    ref
                        .read(validation.notifier)
                        .chooseDrivingLicenseImageFromGallery()
                  },
                  label: Text("Gallery",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      )),
                ),
              ],
            )
          ]),
    );
  }

  Widget IDCardBottomSheet(context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Choose ID-Card Image",
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  icon: Icon(
                    Icons.camera_enhance,
                    color: Colors.black,
                    size: 34,
                  ),
                  onPressed: ()=> {
                    ref.read(validation.notifier).chooseIDCardImageFromCamera()
                  },
                  label: Text("Camera",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      )),
                ),
                SizedBox(
                  width: 40.0,
                ),
                TextButton.icon(
                  icon: Icon(
                    Icons.image,
                    color: Colors.black,
                    size: 34,
                  ),
                  onPressed: () =>{
                    ref.read(validation.notifier).chooseIDCardImageFromGallery(),
                  },
                  label: Text("Gallery",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      )),
                ),
              ],
            )
          ]),
    );
  }
}

import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kou_servis/utils/consts.dart';
import 'package:kou_servis/views/admin/dash.dart';
import 'package:kou_servis/views/auth/signUp.dart';
import 'package:kou_servis/widgets/text_field_container.dart';
import 'package:kou_servis/widgets/already_have_an_account_acheck.dart';
import 'package:kou_servis/widgets/rounded_button.dart';
import 'package:kou_servis/services/firestore_base.dart';

import '../home/home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? email = "";
  String? pass = "";
  bool obscure = true;

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirestoreBase _firestoreBase = FirestoreBase();
  var controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: size.height,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "assets/images/main_top.png",
              width: size.width * 0.35,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              "assets/images/login_bottom.png",
              width: size.width * 0.4,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                AppBar(
                  title:
                      Text("Giriş Yap", style: TextStyle(color: Colors.black)),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.black),
                ),
                SizedBox(height: size.height * 0.03),
                Image.asset("assets/images/icon.png",
                    height: size.height * 0.3),
                SizedBox(height: size.height * 0.03),
                TextFieldContainer(
                  child: TextField(
                    controller: controller,
                    onChanged: (val) {
                      setState(() {
                        if (val == "")
                          email = null;
                        else
                          email = val;
                      });
                    },
                    onSubmitted: (val) {
                      setState(() {
                        if (val == "")
                          email = null;
                        else
                          email = val;
                      });
                    },
                    cursorColor: Constants.mainColor,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: Constants.primary,
                      ),
                      hintText: "Email Adresiniz",
                      errorText: email == null
                          ? "Email adresi zorunludur!"
                          : email != ""
                              ? (EmailValidator.validate(email!) == false
                                  ? "Geçersiz email biçimi"
                                  : null)
                              : null,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: TextField(
                    obscureText: obscure,
                    onChanged: (val) {
                      setState(() {
                        if (val == "")
                          pass = null;
                        else
                          pass = val;
                      });
                    },
                    onSubmitted: (val) {
                      setState(() {
                        if (val == "")
                          pass = null;
                        else
                          pass = val;
                      });
                    },
                    cursorColor: Constants.mainColor,
                    decoration: InputDecoration(
                      hintText: "Şifre",
                      errorText: pass == null
                          ? "Şifre zorunludur!"
                          : pass != "" && pass!.length < 6
                              ? "Şifre en az 6 karakter olmalıdır"
                              : null,
                      icon: Icon(
                        Icons.lock,
                        color: Constants.primary,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obscure == true ? obscure = false : obscure = true;
                          });
                        },
                        child: Icon(
                          Icons.visibility,
                          color: Constants.primary,
                        ),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                RoundedButton(
                  text: "Giriş Yap",
                  press: (email == "" ||
                          email == null ||
                          !EmailValidator.validate(email!) ||
                          pass == "" ||
                          pass == null ||
                          pass!.length < 6)
                      ? () {
                          setState(() {
                            email = null;
                            pass = null;
                          });
                        }
                      : () async {
                          dialog();
                          var sign;
                          _auth
                              .signInWithEmailAndPassword(
                                  email: email!, password: pass!)
                              .then((value) {
                            sign = value;
                            var newUser;
                            _firestoreBase.getUser(sign.user.uid).then((value) {
                              newUser = value;
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Dashboard()));
                            });
                          }).catchError((e) {
                            Navigator.pop(context);
                            if (Platform.isAndroid) {
                              switch (e.message) {
                                case 'There is no user record corresponding to this identifier. The user may have been deleted.':
                                  dialogMessage(
                                      "Kullanıcı bulunamadı! Lütfen kaydolun...");
                                  break;
                                case 'The password is invalid or the user does not have a password.':
                                  dialogMessage(
                                      "Geçersiz e-posta veya şifre! Lütfen tekrar deneyin...");
                                  break;
                                case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
                                  dialogMessage(
                                      "İnternet bağlantısı kesildi! Lütfen tekrar deneyin...");
                                  break;
                                default:
                                  print(
                                      'Case ${e.message} is not yet implemented');
                              }
                            } else if (Platform.isIOS) {
                              switch (e.code) {
                                case 'Error 17011':
                                  dialogMessage(
                                      "Kullanıcı bulunamadı! Lütfen kaydolun...");
                                  break;
                                case 'Error 17009':
                                  dialogMessage(
                                      "Geçersiz e-posta veya şifre! Lütfen tekrar deneyin...");
                                  break;
                                case 'Error 17020':
                                  dialogMessage(
                                      "İnternet bağlantısı kesildi! Lütfen tekrar deneyin...");
                                  break;
                                default:
                                  print(
                                      'Case ${e.message} is not yet implemented');
                              }
                            }
                          });
                        },
                ),
                SizedBox(height: size.height * 0.03),
                AlreadyHaveAnAccountCheck(
                  press: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpScreen()));
                  },
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  dialogMessage(String message) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              child: Text(message),
            ),
          );
        });
  }

  Future<bool?> dialog() async {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            content: Container(
                height: 50,
                alignment: Alignment.center,
                child: CircularProgressIndicator()),
            title: Text("Yükleniyor..."),
          );
        });
  }

  Expanded buildDivider() {
    return Expanded(
      child: Divider(
        color: Color(0xFFD9D9D9),
        height: 1.5,
      ),
    );
  }
}

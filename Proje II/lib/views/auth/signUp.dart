import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kou_servis/models/user.dart';
import 'package:kou_servis/utils/consts.dart';
import 'package:kou_servis/views/admin/dash.dart';
import 'package:kou_servis/views/home/home.dart';
import 'package:kou_servis/widgets/already_have_an_account_acheck.dart';
import 'package:kou_servis/widgets/rounded_button.dart';
import 'package:kou_servis/widgets/text_field_container.dart';
import 'login.dart';
import 'package:kou_servis/services/firestore_base.dart';
import 'package:random_string/random_string.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? email = "";
  String? pass = "";
  String? passControl = "";
  bool obscure = true;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirestoreBase _firestoreBase = FirestoreBase();
  var emailController = TextEditingController();
  var passController = TextEditingController();
  var passControlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
      height: size.height,
      width: double.infinity,
      child: Stack(children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          child: Image.asset(
            "assets/images/signup_top.png",
            width: size.width * 0.35,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Image.asset(
            "assets/images/main_bottom.png",
            width: size.width * 0.25,
          ),
        ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              AppBar(
                title: Text("Kayıt Ol", style: TextStyle(color: Colors.black)),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.black),
              ),
              SizedBox(height: size.height * 0.03),
              Image.asset("assets/images/icon.png",
                  height: size.height * 0.3),
              SizedBox(height: size.height * 0.02),
              TextFieldContainer(
                child: TextField(
                  controller: emailController,
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
                  cursorColor: Constants.primary,
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
                  controller: passController,
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
                  cursorColor: Constants.primary,
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
              TextFieldContainer(
                child: TextField(
                  controller: passControlController,
                  obscureText: obscure,
                  onChanged: (val) {
                    setState(() {
                      if (val == "")
                        passControl = null;
                      else
                        passControl = val;
                    });
                  },
                  onSubmitted: (val) {
                    setState(() {
                      if (val == "")
                        passControl = null;
                      else
                        passControl = val;
                    });
                  },
                  cursorColor: Constants.primary,
                  decoration: InputDecoration(
                    hintText: "Şifre Tekrar",
                    errorText: passControl == null
                        ? "Şifre zorunludur!"
                        : passControl != pass && passControl != ""
                            ? "Şifreler uyuşmuyor!"
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
                text: "Kayıt Ol",
                press: (email == "" ||
                        email == null ||
                        !EmailValidator.validate(email!) ||
                        pass == "" ||
                        pass == null ||
                        pass!.length < 6 ||
                        pass != passControl ||
                        passControl == "" ||
                        passControl == null)
                    ? () {
                        setState(() {
                          email = null;
                          pass = null;
                          passControl = null;
                        });
                      }
                    : () async {
                        dialog();
                        var sign;
                        _auth
                            .createUserWithEmailAndPassword(
                                email: email!, password: pass!)
                            .then((value) {
                          sign = value;
                          var newUser;
                          _firestoreBase
                              .saveUser(AppUser(
                              userID: sign.user.uid,
                              nick: "user" + randomString(5),
                            name: "deneme"
                              ))
                              .then((value) => print(value));
                          _firestoreBase.getUser(sign.user.uid).then((value) {
                            newUser = value;
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) {
                                      return Dashboard();
                                    }));
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
                login: false,
                press: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ]),
    ));
  }

  dialogMessage(String message) {
    return showDialog(
        context: context,
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
}

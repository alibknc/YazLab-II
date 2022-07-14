import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kou_servis/models/user.dart';
import 'package:kou_servis/utils/consts.dart';
import 'package:kou_servis/views/admin/parametreler.dart';
import 'package:kou_servis/views/admin/passengers.dart';
import 'package:kou_servis/views/auth/welcome.dart';
import 'package:kou_servis/views/home/homeChoices.dart';
import 'package:kou_servis/views/yolcu/rota.dart';
import 'package:kou_servis/views/yolcu/yeniKayit.dart';

class UserPanel extends StatefulWidget {
  final AppUser? user;
  const UserPanel({Key? key, this.user}) : super(key: key);

  @override
  State<UserPanel> createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppBar(
              title:
              Text("Kullanıcı Paneli", style: TextStyle(color: Colors.black)),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            SizedBox(height: size.height * 0.02),
            Image.asset("assets/images/icon.png", height: size.height * 0.3),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: TextButton(
                    style: TextButton.styleFrom(
                      padding:
                      EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      backgroundColor: Constants.primary,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => YeniKayit(user: widget.user)));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bus_alert,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                            child: Text(
                              "Başvuru Yap",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Araboto-Bold",
                                fontSize: 18,
                              ),
                            ))
                      ],
                    )),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: TextButton(
                    style: TextButton.styleFrom(
                      padding:
                      EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      backgroundColor: Constants.primary,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RotaPage(user: widget.user)));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.navigation,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                            child: Text(
                              "Rota Görüntüle",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Araboto-Bold",
                                fontSize: 18,
                              ),
                            ))
                      ],
                    )),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: TextButton(
                    style: TextButton.styleFrom(
                      padding:
                      EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () async => await _signOut(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.power_settings_new,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                            child: Text(
                              "Çıkış Yap",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Araboto-Bold",
                                fontSize: 18,
                              ),
                            ))
                      ],
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
  }
}

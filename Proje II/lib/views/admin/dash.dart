import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kou_servis/utils/consts.dart';
import 'package:kou_servis/views/admin/parametreler.dart';
import 'package:kou_servis/views/admin/passengers.dart';
import 'package:kou_servis/views/auth/welcome.dart';
import 'package:kou_servis/views/home/home.dart';
import 'package:kou_servis/views/home/homeChoices.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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
                  Text("Admin Paneli", style: TextStyle(color: Colors.black)),
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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Passengers()));
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
                          "Duraklar - Kayıtlı Yolcular",
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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Parametreler()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                            child: Text(
                              "Parametreler",
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
                      _rotaSec(context);
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
                          "Rota Görüntüle / Oluştur",
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

  _rotaSec(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => BottomSheet(
        builder: (_) => HomeChoices(),
        onClosing: () {},
      ),
    );
  }

  Future _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
  }
}

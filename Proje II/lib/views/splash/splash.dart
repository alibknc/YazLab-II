import 'package:flutter/material.dart';
import 'package:kou_servis/models/user.dart';
import 'package:kou_servis/services/firebase_auth.dart';
import 'package:kou_servis/services/firestore_base.dart';
import 'package:kou_servis/services/locator.dart';
import 'package:kou_servis/view_models/user_model.dart';
import 'package:kou_servis/views/admin/dash.dart';
import 'package:kou_servis/views/auth/welcome.dart';
import 'package:kou_servis/views/home/home.dart';
import 'package:kou_servis/views/yolcu/userPanel.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/icon.png",
              height: 130,
              width: 133,
            ),
          ],
        ),
      ),
    );
  }

  getData() async {
    FirebaseAuthService _firebaseAuthService = locator<FirebaseAuthService>();
    var cUser = await _firebaseAuthService.currentUser();
    final FirestoreBase _firestoreBase = FirestoreBase();
    await _firestoreBase.getParametre();
    if (cUser == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => WelcomeScreen()));
    } else {
      AppUser user = await _firestoreBase.getUser(cUser.userID);
      if(user.admin!){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
          return Dashboard();
        }));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
          return UserPanel(user: user);
        }));
      }

    }
  }
}

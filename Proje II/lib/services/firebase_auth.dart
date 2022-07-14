import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kou_servis/models/user.dart';
import 'package:kou_servis/services/auth_base.dart';

class FirebaseAuthService implements AuthBase{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<AppUser?> currentUser() async{
    try{
      User? user = _auth.currentUser;
      return _userFromFirebase(user!);
    }catch(e){
      debugPrint("$e");
      return null;
    }
  }

  AppUser? _userFromFirebase(User user){
    if(user == null)
      return null;
    else
      return AppUser(userID: user.uid);
  }

  @override
  Future<AppUser?> signInAnonymously() async{
    try{
      UserCredential result = await _auth.signInAnonymously();
      return _userFromFirebase(result.user!);
    }catch(e){
      debugPrint("$e");
      return null;
    }
  }
}
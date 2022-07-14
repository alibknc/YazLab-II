import 'package:kou_servis/models/user.dart';
import 'package:kou_servis/services/auth_base.dart';
import 'package:kou_servis/services/firebase_auth.dart';
import 'package:kou_servis/services/firestore_base.dart';
import 'package:kou_servis/services/locator.dart';

enum AppMode { DEBUG, RELEASE }

class UserRepository implements AuthBase {
  FirebaseAuthService _firebaseAuthService = locator<FirebaseAuthService>();
  FirestoreBase _firestoreBase = locator<FirestoreBase>();
  AppMode appMode = AppMode.RELEASE;
  Map<String, String> userTokens = Map<String, String>();

  @override
  Future<AppUser?> currentUser() async {
    return await _firebaseAuthService.currentUser();
  }
}

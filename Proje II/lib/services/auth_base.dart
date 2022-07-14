import 'package:kou_servis/models/user.dart';

abstract class AuthBase{
  Future<AppUser?> currentUser();
}

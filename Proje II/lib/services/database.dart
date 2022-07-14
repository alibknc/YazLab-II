import 'package:kou_servis/models/location.dart';
import 'package:kou_servis/models/parametre.dart';
import 'package:kou_servis/models/user.dart';

abstract class Database {
  Future<bool> saveUser(AppUser user);

  Future<bool> updateUser(AppUser user);

  Future<AppUser> getUser(String userID);

  Future<bool> updateParametre(Parametre parametre);

  Future<bool> deletePost(String id);

  Future<bool> changeLists(List<Location> list);

  Future<List> getLocations();

  Future<List> getAllLocations();
}

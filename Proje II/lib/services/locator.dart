import 'package:get_it/get_it.dart';
import 'package:kou_servis/repository/user_repository.dart';
import 'package:kou_servis/services/firebase_auth.dart';
import 'package:kou_servis/services/firestore_base.dart';

final GetIt locator = GetIt.instance;

void setupLocator(){
  locator.registerLazySingleton(() => FirebaseAuthService());
  locator.registerLazySingleton(() => UserRepository());
  locator.registerLazySingleton(() => FirestoreBase());
}

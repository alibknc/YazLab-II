import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kou_servis/models/location.dart';
import 'package:kou_servis/models/parametre.dart';
import 'package:kou_servis/models/rota.dart';
import 'package:kou_servis/models/user.dart';
import 'package:kou_servis/services/database.dart';

class FirestoreBase implements Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(AppUser user) async {
    await _firestore.collection("users").doc(user.userID).set(user.toMap());
    return true;
  }

  @override
  Future<bool> saveData(List data) async {
    String id = _firestore.collection("rotalar").id;
    await _firestore
        .collection("rotalar")
        .doc(id)
        .set({'polylines': data[0], 'rotalar': data[1]});
    return true;
  }

  @override
  Future<Parametre> getParametre() async {
    QuerySnapshot data = await _firestore.collection('parametreler').get();
    var parametreler = data.docs[0];
    Parametre parametre = Parametre.fromMap(parametreler);
    return parametre;
  }

  @override
  Future<Rota> getRota(int type) async {
    QuerySnapshot data = await _firestore
        .collection('rotalar')
        .where("rotaTipi", isEqualTo: type)
        .get();
    var doc = data.docs[0];
    Rota rota = Rota.fromMap(doc);
    List<List<int>> rotalar = [];
    rota.rota!.forEach((element) {
      element = element.substring(1, element.length - 1);
      List<String> l = element.split(",");
      List<int> t = [];
      l.forEach((element) {
        t.add(int.parse(element));
      });
      rotalar.add(t);
    });
    rota.rotalar = rotalar;

    if(rota.kisiler!.isNotEmpty && rota.kalanlar!.isNotEmpty){
      List<List<int>> kisiler = [];
      rota.kisiler!.forEach((element) {
        element = element.substring(1, element.length - 1);
        List<String> l = element.split(",");
        List<int> t = [];
        l.forEach((element) {
          t.add(int.parse(element));
        });
        kisiler.add(t);
      });
      rota.kisiler = kisiler;

      kisiler = [];
      rota.kalanlar!.forEach((element) {
        element = element.substring(1, element.length - 1);
        List<String> l = element.split(",");
        List<int> t = [];
        l.forEach((element) {
          t.add(int.parse(element));
        });
        kisiler.add(t);
      });
      rota.kalanlar = kisiler;
    }

    return rota;
  }

  @override
  Future<bool> updateRota(Rota rota) async {
    List<String> data = [];
    rota.rotalar!.forEach((element) {
      data.add(element.toString());
    });
    rota.rota = data;

    data = [];
    rota.kisiler!.forEach((element) {
      data.add(element.toString());
    });
    rota.kisiler = data;

    data = [];
    rota.kalanlar!.forEach((element) {
      data.add(element.toString());
    });
    rota.kalanlar = data;

    await _firestore.doc("rotalar/${rota.id}").update(rota.toMap());
    return true;
  }

  @override
  Future<List<Location>> getLocations() async {
    var result = await _firestore
        .collection("ilceler")
        .where('kisi', isGreaterThan: 0)
        .get();
    List<Location> list = [];
    result.docs.forEach((e) {
      var temp = Location.fromMap(e);
      list.add(temp);
    });
    return list;
  }

  @override
  Future<List<Location>> getAllLocations() async {
    var result = await _firestore.collection("ilceler").get();
    List<Location> list = [];
    result.docs.forEach((e) {
      var temp = Location.fromMap(e);
      list.add(temp);
    });
    return list;
  }

  @override
  Future<bool> deletePost(String id) async {
    await _firestore.doc("alinti/$id").delete();
    return true;
  }

  @override
  Future<bool> changeLists(List<Location> list) async {
    await Future.wait(list.map((element) async {
      await _firestore.doc("ilceler/${element.id}").update(element.toMap());
    }).toList());

    return true;
  }

  @override
  Future<bool> updateUser(AppUser user) async {
    await _firestore.doc("users/${user.userID}").update(user.toMap());
    return true;
  }

  @override
  Future<bool> updateParametre(Parametre parametre) async {
    await _firestore
        .doc("parametreler/${parametre.docID}")
        .update(parametre.toMap());
    return true;
  }

  @override
  Future<AppUser> getUser(String? userID) async {
    DocumentSnapshot userMap =
        await _firestore.collection('users').doc(userID).get();
    if (userMap.data() == null) {
      return AppUser(nick: null);
    } else {
      AppUser user = AppUser.fromMap(userMap.data());
      return user;
    }
  }
}

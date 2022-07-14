import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class Rota {
  String? id;
  int? rotaTipi;
  List? rota;
  List<List<int>>? rotalar;
  List? kisiler;
  List? kalanlar;

  Rota(String id, int rotaTipi, List rota, List<List<int>> rotalar, List<int> kisiler, List<int> kalanlar){
    this.id = id;
    this.rotaTipi = rotaTipi;
    this.rotalar = rotalar;
    this.kisiler = kisiler;
    this.kalanlar = kalanlar;
    this.rota = rota;
  }

  void toRota(DocumentSnapshot data){
    this.rota = data.get("rota");
    this.rotaTipi = data.get("rotaTipi");
    this.rotalar = data.get("rotalar");
    this.kisiler = data.get("kisiler");
    this.kalanlar = data.get("kalanlar");
    this.id = data.get("id");
  }

  Map<String, Object> toMap(){
    Map<String, Object> docData = Map<String, Object>();
    docData["rota"] = this.rota!;
    docData["rotaTipi"] = this.rotaTipi!;
    docData["id"] = this.id!;
    docData["kisiler"] = this.kisiler!;
    docData["kalanlar"] = this.kalanlar!;
    return docData;
  }

  Rota.fromMap(DocumentSnapshot data)
      : rota = data['rota'],
        rotaTipi = data['rotaTipi'],
        kisiler = data['kisiler'],
        kalanlar = data['kalanlar'],
        id = data['id'];

}
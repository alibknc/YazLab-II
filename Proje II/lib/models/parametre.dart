import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';

class Parametre {
  String? docID;
  int? ekServisKapasite;
  int? yolMaliyeti;
  List? servisKapasiteleri;
  List? mesafeler;
  bool? hesapla;
  List? yolcuEklendi;

  Parametre(int ekServisKapasite, int yolMaliyeti, List servisKapasiteleri, List<String> mesafeler, bool hesapla, List yolcuEklendi){
    this.ekServisKapasite = ekServisKapasite;
    this.yolMaliyeti = yolMaliyeti;
    this.yolcuEklendi = yolcuEklendi;
    this.servisKapasiteleri = servisKapasiteleri;
    this.hesapla = hesapla;
    this.mesafeler = mesafeler;
  }

  void toParametre(DocumentSnapshot data){
    this.yolMaliyeti = data.get("yolMaliyeti");
    this.docID = data.get("docID");
    this.mesafeler = data.get("mesafeler");
    this.yolcuEklendi = data.get("yolcuEklendi");
    this.hesapla = data.get("hesapla");
    this.ekServisKapasite = data.get("ekServisKapasite");
    this.servisKapasiteleri = data.get("servisKapasiteleri");
  }

  Map<String, Object> toMap(){
    Map<String, Object> docData = Map<String, Object>();
    docData["ekServisKapasite"] = this.ekServisKapasite!;
    docData["yolMaliyeti"] = this.yolMaliyeti!;
    docData["mesafeler"] = this.mesafeler!;
    docData["yolcuEklendi"] = this.yolcuEklendi!;
    docData["servisKapasiteleri"] = this.servisKapasiteleri!;
    docData["docID"] = this.docID!;
    docData["hesapla"] = this.hesapla!;
    return docData;
  }

  Parametre.fromMap(DocumentSnapshot data)
      : yolMaliyeti = data['yolMaliyeti'],
        docID = data['docID'],
        hesapla = data['hesapla'],
        mesafeler = data['mesafeler'],
        yolcuEklendi = data['yolcuEklendi'],
        servisKapasiteleri = data['servisKapasiteleri'],
        ekServisKapasite = data['ekServisKapasite'];

}
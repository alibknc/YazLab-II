import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
    String? id;
    String? konumAdi;
    String? koordinat;
    String? lat;
    String? lng;
    int? kisi;

    Location(String id, String konumAdi, String koordinat, int kisi){
        this.konumAdi = konumAdi;
        this.koordinat = koordinat;
        this.id = id;
        this.kisi = kisi;
        this.lat = koordinat.split(",")[0];
        this.lng = koordinat.split(",")[1];
    }

    void toLocation(DocumentSnapshot data){
        this.konumAdi = data.get("konumAdi");
        this.koordinat = data.get("koordinat");
        this.kisi = data.get("kisi");
        this.id = data.get("id");
    }

    Map<String, Object> toMap(){
        Map<String, Object> docData = Map<String, Object>();
        docData["konumAdi"] = this.konumAdi!;
        docData["koordinat"] = this.koordinat!;
        docData["kisi"] = this.kisi!;
        docData["id"] = this.id!;
        return docData;
    }

    Location.fromMap(DocumentSnapshot data)
        : konumAdi = data['konumAdi'],
            koordinat = data['koordinat'],
            lat = data['koordinat'].split(",")[0],
            lng = data['koordinat'].split(",")[1],
            kisi = data['kisi'],
            id = data['id'];
}
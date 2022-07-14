import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kou_servis/models/directions.dart';
import 'package:kou_servis/models/location.dart';
import 'package:kou_servis/models/parametre.dart';
import 'package:kou_servis/models/rota.dart';
import 'package:kou_servis/services/firestore_base.dart';
import 'package:kou_servis/services/googleMapsAPI.dart';
import 'package:random_string/random_string.dart';

class Algorithm {
  String kouLocation = "40.822318, 29.927032";
  GoogleMapsAPI api = GoogleMapsAPI();
  FirestoreBase _firestoreBase = FirestoreBase();

  List<List<int>> mesafeTablo = [];
  List<List<int>> tasarrufTablo = [];
  List<List> siraliTablo = [];
  List<List<int>> rotalar = [];
  List<List<int>> alinan = [];
  List<List<int>> kalanYolcular = [];
  List<int> kapasiteler = [];
  List<int> sinirliDuraklar = [];
  List<Location> duraklar = [];
  late Parametre degiskenler;

  List<int> mevcutServisKapasiteleri = [];
  List<int> sinirliServisKapasiteleri = [];
  int yolMaliyeti = 1;
  int ekServisKapasitesi = 25;
  List<List<List>> polyLines = [];
  List<int> kisiler = [];

  parametreAl(List<Location> konumlar, Parametre parametre, int type) async {
    degiskenler = parametre;
    duraklar = konumlar;
    yolMaliyeti = parametre.yolMaliyeti!;
    ekServisKapasitesi = parametre.ekServisKapasite!;
    mevcutServisKapasiteleri = (parametre.servisKapasiteleri!.cast<int>());
    sinirliServisKapasiteleri = List.from(mevcutServisKapasiteleri);

    duraklar.forEach((element) {
      kisiler.add(element.kisi!);
    });
    duraklar.insert(0, Location("0", "Kocaeli Üniversitesi", kouLocation, 0));

    int topKisi = 0;
    int topKapasite = 0;
    kisiler.forEach((element) {
      topKisi += element;
    });
    mevcutServisKapasiteleri.forEach((element) {
      topKapasite += element;
    });

    if (topKisi > topKapasite) {
      int extra = ((topKisi - topKapasite) ~/ ekServisKapasitesi) + 1;
      for (int i = 0; i < extra; i++) {
        mevcutServisKapasiteleri.add(ekServisKapasitesi);
      }
    }

    mevcutServisKapasiteleri.sort((b, a) => a.compareTo(b));

    if (parametre.mesafeler!.isNotEmpty && !parametre.hesapla!) {
      parametre.mesafeler!.forEach((element) {
        element = element.substring(1, element.length - 1);
        List<String> l = element.split(",");
        List<int> t = [];
        l.forEach((element) {
          t.add(int.parse(element));
        });
        mesafeTablo.add(t);
      });
    } else {
      await mesafeTabloOlustur(type);
    }

    if (type == 0) {
      List<List<int>> gecici = [];

      for (int i = 0; i < mesafeTablo.length; i++) {
        List<int> temp = [];
        var r = mesafeTablo[i][0];
        temp.add(i + 1);
        temp.add(r);
        gecici.add(temp);
      }

      gecici.sort((a, b) => a[1].compareTo(b[1]));
      print(gecici);

      List<int> yeniDurakList = [];
      int toplam = 0;
      int kapasite = 0;

      for (int i = 0; i < sinirliServisKapasiteleri.length; i++) {
        kapasite += sinirliServisKapasiteleri[i];
      }

      gecici.forEach((element) {
        if (toplam <= kapasite) {
          yeniDurakList.add(element[0]);
          toplam += kisiler[element[0] - 1];
        }
      });

      print("$toplam $kapasite $yeniDurakList");
      sinirliDuraklar = yeniDurakList;
    }

    await tasarrufTabloOlustur();
    await siraliTabloOlustur(type);
  }

  mesafeTabloOlustur(int type) async {
    for (int i = 1; i < duraklar.length; i++) {
      List<int> temp = [];
      for (int j = 0; j < i; j++) {
        var r = await api.getDistance("${duraklar[i].lat}%2C${duraklar[i].lng}",
            "${duraklar[j].lat}%2C${duraklar[j].lng}");
        temp.add(r);
      }
      mesafeTablo.add(temp);
    }

    for (int i = 0; i < mesafeTablo.length; i++) {
      String a = "";
      mesafeTablo[i].forEach((element) {
        a += " ";
        a += element.toString();
      });
      print(a);
    }

    degiskenler.hesapla = degiskenler.hesapla! ? false : degiskenler.hesapla;
    degiskenler.mesafeler = [];
    mesafeTablo.forEach((element) {
      degiskenler.mesafeler!.add(element.toString());
    });
    degiskenler.servisKapasiteleri = sinirliServisKapasiteleri;

    await _firestoreBase.updateParametre(degiskenler);
  }

  tasarrufTabloOlustur() async {
    for (int i = 0; i < mesafeTablo.length - 1; i++) {
      for (int j = i + 1; j < mesafeTablo.length; j++) {
        List<int> temp;
        if (i == 0) {
          temp = [];
        } else {
          temp = tasarrufTablo[j - 1];
        }

        int a = mesafeTablo[i][0];
        int b = mesafeTablo[j][0];
        int r = a + b;

        int x = mesafeTablo[j][i + 1];
        r = r - x;

        temp.add(r);

        if (i == 0) {
          tasarrufTablo.add(temp);
        }
      }
    }

    for (int i = 0; i < tasarrufTablo.length; i++) {
      String a = "";
      tasarrufTablo[i].forEach((element) {
        a += " ";
        a += element.toString();
      });
      print(a);
    }
  }

  siraliTabloOlustur(int type) {
    if (type == 0) {
      for (int i = 0; i < tasarrufTablo.length; i++) {
        for (int j = 0; j < tasarrufTablo[i].length; j++) {
          if (sinirliDuraklar.contains(j) && sinirliDuraklar.contains(i + 1)) {
            List temp = [];
            temp.add(tasarrufTablo[i][j]);
            temp.add(j);
            temp.add(i + 1);
            siraliTablo.add(temp);
          }
        }
      }
    } else {
      for (int i = 0; i < tasarrufTablo.length; i++) {
        for (int j = 0; j < tasarrufTablo[i].length; j++) {
          List temp = [];
          temp.add(tasarrufTablo[i][j]);
          temp.add(j + 1);
          temp.add(i + 2);
          siraliTablo.add(temp);
        }
      }
    }

    siraliTablo = quickSort(siraliTablo, 0, siraliTablo.length - 1);
    siraliTablo = List.from(siraliTablo.reversed);

    for (int i = 0; i < siraliTablo.length; i++) {
      String a = "";
      siraliTablo[i].forEach((element) {
        a += " ";
        a += element.toString();
      });
      print(a);
    }
  }

  rotalariOlustur() async {
    for (int i = 0; i < rotalar.length; i++) {
      List<int> rota = rotalar[i];
      List<List> single = [];

      for (int j = 0; j < rota.length - 1; j++) {
        List part = [];
        Marker start = Marker(
            markerId: MarkerId(randomString(5)),
            infoWindow: InfoWindow(
                title: rota[j] != 0
                    ? "${duraklar[rota[j]].konumAdi} (${kisiler[rota[j] - 1]})"
                    : "${duraklar[rota[j]].konumAdi}"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            position: LatLng(double.parse(duraklar[rota[j]].lat!),
                double.parse(duraklar[rota[j]].lng!)));
        Marker end = Marker(
            markerId: MarkerId(randomString(5)),
            infoWindow: InfoWindow(
                title: rota[j + 1] != 0
                    ? "${duraklar[rota[j + 1]].konumAdi} (${kisiler[rota[j + 1] - 1]})"
                    : "${duraklar[rota[j + 1]].konumAdi}"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            position: LatLng(double.parse(duraklar[rota[j + 1]].lat!),
                double.parse(duraklar[rota[j + 1]].lng!)));
        Directions direction = await api.getWay(start.position, end.position);
        part.add(start);
        part.add(end);
        part.add(direction);
        single.add(part);
      }
      polyLines.add(single);
    }
  }

  Future sinirliServis() async {
    print(kisiler);
    List<int> geciciKisiler = List.from(kisiler);
    Rota r = await _firestoreBase.getRota(0);

    if (degiskenler.yolcuEklendi![0]) {
      for (int i = 0; i < siraliTablo.length; i++) {
        List satir = siraliTablo[i];
        if (rotalar.isEmpty) {
          if (geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1] <
              mevcutServisKapasiteleri[0]) {
            List<int> rota = [];
            rota.add(satir[1]);
            rota.add(satir[2]);
            rotalar.add(rota);
            alinan.add(
                [geciciKisiler[satir[1] - 1], geciciKisiler[satir[2] - 1]]);
            kapasiteler
                .add(geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1]);
            geciciKisiler[satir[1] - 1] = 0;
            geciciKisiler[satir[2] - 1] = 0;
          } else {
            if (geciciKisiler[satir[1] - 1] < geciciKisiler[satir[2] - 1]) {
              List<int> rota = [];
              if (geciciKisiler[satir[1] - 1] == mevcutServisKapasiteleri[0]) {
                rota.add(satir[1]);
                alinan.add([geciciKisiler[satir[1] - 1]]);
                geciciKisiler[satir[1] - 1] = 0;
              } else {
                rota.add(satir[1]);
                rota.add(satir[2]);
                alinan.add([
                  geciciKisiler[satir[1] - 1],
                  (mevcutServisKapasiteleri[0] - geciciKisiler[satir[1] - 1])
                ]);
                print("291");
                geciciKisiler[satir[2] - 1] -=
                    (mevcutServisKapasiteleri[0] - geciciKisiler[satir[1] - 1]);
                geciciKisiler[satir[1] - 1] = 0;
              }
              rotalar.add(rota);
              kapasiteler.add(mevcutServisKapasiteleri[0]);
            }
          }
        } else {
          int? r1 = search(0, satir[1]);
          int? r2 = search(0, satir[2]);

          if (r1 == null && r2 == null) {
            if (geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1] <
                mevcutServisKapasiteleri[rotalar.length]) {
              List<int> rota = [];
              rota.add(satir[1]);
              rota.add(satir[2]);
              alinan.add(
                  [geciciKisiler[satir[1] - 1], geciciKisiler[satir[2] - 1]]);
              rotalar.add(rota);
              kapasiteler.add(
                  geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1]);
              geciciKisiler[satir[1] - 1] = 0;
              geciciKisiler[satir[2] - 1] = 0;
            } else {
              if (geciciKisiler[satir[1] - 1] < geciciKisiler[satir[2] - 1]) {
                List<int> rota = [];
                if (geciciKisiler[satir[1] - 1] ==
                    mevcutServisKapasiteleri[rotalar.length]) {
                  rota.add(satir[1]);
                  alinan.add([geciciKisiler[satir[1] - 1]]);
                  geciciKisiler[satir[1] - 1] = 0;
                } else {
                  rota.add(satir[1]);
                  rota.add(satir[2]);
                  alinan.add([
                    geciciKisiler[satir[1] - 1],
                    (mevcutServisKapasiteleri[rotalar.length] -
                        geciciKisiler[satir[1] - 1])
                  ]);
                  print("326");
                  geciciKisiler[satir[2] - 1] -=
                      (mevcutServisKapasiteleri[rotalar.length] -
                          geciciKisiler[satir[1] - 1]);
                  geciciKisiler[satir[1] - 1] = 0;
                }
                kapasiteler.add(mevcutServisKapasiteleri[rotalar.length]);
                rotalar.add(rota);
              }
            }
          } else if (r1 == null) {
            if (kapasiteler[r2!] + geciciKisiler[satir[1] - 1] <=
                mevcutServisKapasiteleri[r2]) {
              rotalar[r2].add(satir[1]);
              alinan[r2].add(geciciKisiler[satir[1] - 1]);
              kapasiteler[r2] += geciciKisiler[satir[1] - 1];
              geciciKisiler[satir[1] - 1] = 0;
            } else if (kapasiteler[r2] < mevcutServisKapasiteleri[r2]) {
              rotalar[r2].add(satir[1]);
              alinan[r2].add((mevcutServisKapasiteleri[r2] - kapasiteler[r2]));
              geciciKisiler[satir[1] - 1] -=
                  (mevcutServisKapasiteleri[r2] - kapasiteler[r2]);
              kapasiteler[r2] = mevcutServisKapasiteleri[r2];
            } else if (geciciKisiler[satir[2] - 1] != 0) {
              if (geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1] <=
                  mevcutServisKapasiteleri[rotalar.length]) {
                List<int> rota = [];
                rota.add(satir[1]);
                rota.add(satir[2]);
                alinan.add(
                    [geciciKisiler[satir[1] - 1], geciciKisiler[satir[2] - 1]]);
                rotalar.add(rota);
                kapasiteler.add(
                    geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1]);
                geciciKisiler[satir[1] - 1] = 0;
                geciciKisiler[satir[2] - 1] = 0;
              } else {
                List<int> rota = [];
                if (geciciKisiler[satir[1] - 1] ==
                    mevcutServisKapasiteleri[rotalar.length]) {
                  rota.add(satir[1]);
                  alinan.add([geciciKisiler[satir[1] - 1]]);
                  geciciKisiler[satir[1] - 1] = 0;
                } else if (geciciKisiler[satir[2] - 1] ==
                    mevcutServisKapasiteleri[rotalar.length]) {
                  rota.add(satir[2]);
                  alinan.add([geciciKisiler[satir[2] - 1]]);
                  geciciKisiler[satir[2] - 1] = 0;
                } else {
                  rota.add(satir[1]);
                  rota.add(satir[2]);
                  print("371");
                  if (geciciKisiler[satir[1] - 1] <=
                      geciciKisiler[satir[2] - 1]) {
                    if (geciciKisiler[satir[1] - 1] <
                        mevcutServisKapasiteleri[rotalar.length]) {
                      alinan.add([
                        geciciKisiler[satir[1] - 1],
                        (mevcutServisKapasiteleri[rotalar.length] -
                            geciciKisiler[satir[1] - 1])
                      ]);
                      geciciKisiler[satir[2] - 1] -=
                          (mevcutServisKapasiteleri[rotalar.length] -
                              geciciKisiler[satir[1] - 1]);
                      geciciKisiler[satir[1] - 1] = 0;
                    } else {
                      alinan.add([mevcutServisKapasiteleri[rotalar.length]]);
                      geciciKisiler[satir[1] - 1] -=
                          mevcutServisKapasiteleri[rotalar.length];
                    }
                  } else if (geciciKisiler[satir[1] - 1] >
                      geciciKisiler[satir[2] - 1]) {
                    if (geciciKisiler[satir[2] - 1] <
                        mevcutServisKapasiteleri[rotalar.length]) {
                      alinan.add([
                        (mevcutServisKapasiteleri[rotalar.length] -
                            geciciKisiler[satir[2] - 1]),
                        geciciKisiler[satir[2] - 1]
                      ]);
                      geciciKisiler[satir[1] - 1] -=
                          (mevcutServisKapasiteleri[rotalar.length] -
                              geciciKisiler[satir[2] - 1]);
                      geciciKisiler[satir[2] - 1] = 0;
                    } else {
                      alinan.add([mevcutServisKapasiteleri[rotalar.length]]);
                      geciciKisiler[satir[2] - 1] -=
                          mevcutServisKapasiteleri[rotalar.length];
                    }
                  }
                }
                kapasiteler.add(mevcutServisKapasiteleri[rotalar.length]);
                rotalar.add(rota);
              }
            }
          } else if (r2 == null) {
            if (kapasiteler[r1] + geciciKisiler[satir[2] - 1] <=
                mevcutServisKapasiteleri[r1]) {
              rotalar[r1].add(satir[2]);
              alinan[r1].add(geciciKisiler[satir[2] - 1]);
              kapasiteler[r1] += geciciKisiler[satir[2] - 1];
              geciciKisiler[satir[2] - 1] = 0;
            } else if (kapasiteler[r1] < mevcutServisKapasiteleri[r1]) {
              rotalar[r1].add(satir[2]);
              alinan[r1].add((mevcutServisKapasiteleri[r1] - kapasiteler[r1]));
              geciciKisiler[satir[2] - 1] -=
                  (mevcutServisKapasiteleri[r1] - kapasiteler[r1]);
              kapasiteler[r1] = mevcutServisKapasiteleri[r1];
            } else if (geciciKisiler[satir[1] - 1] != 0) {
              if (geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1] <=
                  mevcutServisKapasiteleri[rotalar.length]) {
                List<int> rota = [];
                rota.add(satir[1]);
                rota.add(satir[2]);
                alinan.add(
                    [geciciKisiler[satir[1] - 1], geciciKisiler[satir[2] - 1]]);
                rotalar.add(rota);
                kapasiteler.add(
                    geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1]);
                geciciKisiler[satir[1] - 1] = 0;
                geciciKisiler[satir[2] - 1] = 0;
              } else if (geciciKisiler[satir[1] - 1] <
                  geciciKisiler[satir[2] - 1]) {
                List<int> rota = [];
                if (geciciKisiler[satir[1] - 1] ==
                    mevcutServisKapasiteleri[rotalar.length]) {
                  rota.add(satir[1]);
                  alinan.add([geciciKisiler[satir[1] - 1]]);
                  geciciKisiler[satir[1] - 1] = 0;
                } else if (geciciKisiler[satir[2] - 1] ==
                    mevcutServisKapasiteleri[rotalar.length]) {
                  rota.add(satir[2]);
                  alinan.add([geciciKisiler[satir[2] - 1]]);
                  geciciKisiler[satir[2] - 1] = 0;
                } else {
                  rota.add(satir[1]);
                  rota.add(satir[2]);
                  print("404");
                  if (geciciKisiler[satir[1] - 1] <=
                      geciciKisiler[satir[2] - 1]) {
                    if (geciciKisiler[satir[1] - 1] <
                        mevcutServisKapasiteleri[rotalar.length]) {
                      alinan.add([
                        geciciKisiler[satir[1] - 1],
                        (mevcutServisKapasiteleri[rotalar.length] -
                            geciciKisiler[satir[1] - 1])
                      ]);
                      geciciKisiler[satir[2] - 1] -=
                          (mevcutServisKapasiteleri[rotalar.length] -
                              geciciKisiler[satir[1] - 1]);
                      geciciKisiler[satir[1] - 1] = 0;
                    } else {
                      alinan.add([mevcutServisKapasiteleri[rotalar.length]]);
                      geciciKisiler[satir[1] - 1] -=
                          mevcutServisKapasiteleri[rotalar.length];
                    }
                  } else if (geciciKisiler[satir[1] - 1] >
                      geciciKisiler[satir[2] - 1]) {
                    if (geciciKisiler[satir[2] - 1] <
                        mevcutServisKapasiteleri[rotalar.length]) {
                      alinan.add([
                        (mevcutServisKapasiteleri[rotalar.length] -
                            geciciKisiler[satir[2] - 1]),
                        geciciKisiler[satir[2] - 1]
                      ]);
                      geciciKisiler[satir[1] - 1] -=
                          (mevcutServisKapasiteleri[rotalar.length] -
                              geciciKisiler[satir[2] - 1]);
                      geciciKisiler[satir[2] - 1] = 0;
                    } else {
                      alinan.add([mevcutServisKapasiteleri[rotalar.length]]);
                      geciciKisiler[satir[2] - 1] -=
                          mevcutServisKapasiteleri[rotalar.length];
                    }
                  }
                }
                kapasiteler.add(mevcutServisKapasiteleri[rotalar.length]);
                rotalar.add(rota);
              }
            }
          } else {
            if (r1 != r2) {
              if (kapasiteler[r1] + kapasiteler[r2] <=
                  mevcutServisKapasiteleri[r1]) {
                rotalar[r1].addAll(rotalar[r2]);
                alinan[r1].addAll(alinan[r2]);
                rotalar.remove(rotalar[r2]);
                kapasiteler[r1] += kapasiteler[r2];
                kapasiteler.remove(kapasiteler[r2]);
              } else if (kapasiteler[r1] + kapasiteler[r2] <=
                  mevcutServisKapasiteleri[r2]) {
                rotalar[r2].addAll(rotalar[r1]);
                alinan[r2].addAll(alinan[r1]);
                rotalar.remove(rotalar[r1]);
                kapasiteler[r2] += kapasiteler[r1];
                kapasiteler.remove(kapasiteler[r1]);
              } else if (geciciKisiler[satir[1] - 1] != 0) {
                if (kapasiteler[r2] < mevcutServisKapasiteleri[r2]) {
                  rotalar[r2].add(satir[1]);
                  alinan[r2]
                      .add((mevcutServisKapasiteleri[r2] - kapasiteler[r2]));
                  geciciKisiler[satir[1] - 1] -=
                      (mevcutServisKapasiteleri[r2] - kapasiteler[r2]);
                  kapasiteler[r2] = mevcutServisKapasiteleri[r2];
                }
              } else if (geciciKisiler[satir[2] - 1] != 0) {
                if (kapasiteler[r1] < mevcutServisKapasiteleri[r1]) {
                  rotalar[r1].add(satir[2]);
                  alinan[r1]
                      .add((mevcutServisKapasiteleri[r1] - kapasiteler[r1]));
                  geciciKisiler[satir[2] - 1] -=
                      (mevcutServisKapasiteleri[r1] - kapasiteler[r1]);
                  kapasiteler[r1] = mevcutServisKapasiteleri[r1];
                }
              }
            }
          }
        }
      }

      for (int i = 0; i < sinirliDuraklar.length; i++) {
        if (geciciKisiler[sinirliDuraklar[i]] != 0) {
          while (geciciKisiler[sinirliDuraklar[i]] > 0 &&
              rotalar.length <= sinirliDuraklar.length) {
            if (geciciKisiler[sinirliDuraklar[i]] + kapasiteler.last <=
                mevcutServisKapasiteleri[rotalar.length - 1]) {
              alinan.last.add(geciciKisiler[sinirliDuraklar[i]]);
              rotalar.last.add(i + 1);
              geciciKisiler[sinirliDuraklar[i]] = 0;
            } else {
              if (geciciKisiler[sinirliDuraklar[i]] >
                  mevcutServisKapasiteleri[rotalar.length]) {
                alinan.add([mevcutServisKapasiteleri[rotalar.length]]);
                kapasiteler.add(mevcutServisKapasiteleri[rotalar.length]);
                geciciKisiler[sinirliDuraklar[i]] -=
                    mevcutServisKapasiteleri[rotalar.length];
              } else {
                alinan.add([geciciKisiler[sinirliDuraklar[i]]]);
                kapasiteler.add(geciciKisiler[sinirliDuraklar[i]]);
                geciciKisiler[sinirliDuraklar[i]] = 0;
              }
              List<int> rota = [];
              rota.add(sinirliDuraklar[i] + 1);
              rotalar.add(rota);
            }
          }
        }
      }
      print(geciciKisiler);

      List<int> kisilerCpy = List.from(kisiler);
      rotalar = List.from(rotalar.take(sinirliServisKapasiteleri.length));
      alinan = List.from(alinan.take(sinirliServisKapasiteleri.length));
      for (int i = 0; i < rotalar.length; i++) {
        List<int> element = rotalar[i];
        List<int> elementCpy = List.from(rotalar[i]);
        List<int> yolcu = alinan[i];
        element.sort(
            (a, b) => mesafeTablo[a - 1][0].compareTo(mesafeTablo[b - 1][0]));

        List<int> newYolcu = List.filled(yolcu.length, -1);
        newYolcu = List.from(newYolcu);

        for (int j = 0; j < yolcu.length; j++) {
          int x = element[j];
          int y = elementCpy.indexOf(x);
          newYolcu[j] = yolcu[y];
        }
        yolcu = newYolcu;

        if (mesafeTablo[element[0] - 1][0] <=
            mesafeTablo[element[element.length - 1] - 1][0]) {
          element.insert(0, 0);
          yolcu.insert(0, -1);
          element = List.of(element.reversed);
          yolcu = List.of(yolcu.reversed);
        } else {
          element.add(0);
          yolcu.add(-1);
        }
        print(element);
        print("-$yolcu");

        List<int> kalanlar = [];
        for (int k = 0; k < element.length - 1; k++) {
          kalanlar.add(kisilerCpy[element[k] - 1]);
          kisilerCpy[element[k] - 1] -= yolcu[k];
        }
        kalanYolcular.add(kalanlar);

        rotalar[i] = element;
        alinan[i] = yolcu;
      }
      print(kisiler);
      print(kalanYolcular);

      degiskenler.yolcuEklendi![0] = false;
      degiskenler.servisKapasiteleri = sinirliServisKapasiteleri;
      r.rotalar = rotalar;
      r.kisiler = List.from(alinan);
      r.kalanlar = List.from(kalanYolcular);
      await _firestoreBase.updateRota(r);
      await _firestoreBase.updateParametre(degiskenler);

      await rotalariOlustur();

      return [polyLines, rotalar, alinan, kalanYolcular];
    } else {
      rotalar = r.rotalar!;
      await rotalariOlustur();

      return [polyLines, rotalar, r.kisiler, r.kalanlar];
    }
  }

  Future sinirsizServis() async {
    print(kisiler);
    List<int> geciciKisiler = List.from(kisiler);
    Rota r = await _firestoreBase.getRota(1);

    if (degiskenler.yolcuEklendi![1]) {
      for (int i = 0; i < siraliTablo.length; i++) {
        List satir = siraliTablo[i];
        if (rotalar.isEmpty) {
          if (geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1] <
              mevcutServisKapasiteleri[0]) {
            List<int> rota = [];
            rota.add(satir[1]);
            rota.add(satir[2]);
            rotalar.add(rota);
            kapasiteler
                .add(geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1]);
            geciciKisiler[satir[1] - 1] = 0;
            geciciKisiler[satir[2] - 1] = 0;
          } else {
            if (geciciKisiler[satir[1] - 1] < geciciKisiler[satir[2] - 1]) {
              List<int> rota = [];
              if (geciciKisiler[satir[1] - 1] == mevcutServisKapasiteleri[0]) {
                rota.add(satir[1]);
                geciciKisiler[satir[1] - 1] = 0;
              } else {
                rota.add(satir[1]);
                rota.add(satir[2]);
                print("291");
                geciciKisiler[satir[2] - 1] -=
                    (mevcutServisKapasiteleri[0] - geciciKisiler[satir[1] - 1]);
                geciciKisiler[satir[1] - 1] = 0;
              }
              rotalar.add(rota);
              kapasiteler.add(mevcutServisKapasiteleri[0]);
            }
          }
        } else {
          int? r1 = search(0, satir[1]);
          int? r2 = search(0, satir[2]);

          if (r1 == null && r2 == null) {
            if (geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1] <
                mevcutServisKapasiteleri[rotalar.length]) {
              List<int> rota = [];
              rota.add(satir[1]);
              rota.add(satir[2]);
              rotalar.add(rota);
              kapasiteler.add(
                  geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1]);
              geciciKisiler[satir[1] - 1] = 0;
              geciciKisiler[satir[2] - 1] = 0;
            } else {
              if (geciciKisiler[satir[1] - 1] < geciciKisiler[satir[2] - 1]) {
                List<int> rota = [];
                if (geciciKisiler[satir[1] - 1] ==
                    mevcutServisKapasiteleri[rotalar.length]) {
                  rota.add(satir[1]);
                  geciciKisiler[satir[1] - 1] = 0;
                } else {
                  rota.add(satir[1]);
                  rota.add(satir[2]);
                  print("326");
                  geciciKisiler[satir[2] - 1] -=
                      (mevcutServisKapasiteleri[rotalar.length] -
                          geciciKisiler[satir[1] - 1]);
                  geciciKisiler[satir[1] - 1] = 0;
                }
                kapasiteler.add(mevcutServisKapasiteleri[rotalar.length]);
                rotalar.add(rota);
              }
            }
          } else if (r1 == null) {
            if (kapasiteler[r2!] + geciciKisiler[satir[1] - 1] <=
                mevcutServisKapasiteleri[r2]) {
              rotalar[r2].add(satir[1]);
              kapasiteler[r2] += geciciKisiler[satir[1] - 1];
              geciciKisiler[satir[1] - 1] = 0;
            } else if (kapasiteler[r2] < mevcutServisKapasiteleri[r2]) {
              rotalar[r2].add(satir[1]);
              geciciKisiler[satir[1] - 1] -=
                  (mevcutServisKapasiteleri[r2] - kapasiteler[r2]);
              kapasiteler[r2] = mevcutServisKapasiteleri[r2];
            } else if (geciciKisiler[satir[2] - 1] != 0) {
              if (geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1] <=
                  mevcutServisKapasiteleri[rotalar.length]) {
                List<int> rota = [];
                rota.add(satir[1]);
                rota.add(satir[2]);
                rotalar.add(rota);
                kapasiteler.add(
                    geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1]);
                geciciKisiler[satir[1] - 1] = 0;
                geciciKisiler[satir[2] - 1] = 0;
              } else {
                List<int> rota = [];
                if (geciciKisiler[satir[1] - 1] ==
                    mevcutServisKapasiteleri[rotalar.length]) {
                  rota.add(satir[1]);
                  geciciKisiler[satir[1] - 1] = 0;
                } else if (geciciKisiler[satir[2] - 1] ==
                    mevcutServisKapasiteleri[rotalar.length]) {
                  rota.add(satir[2]);
                  geciciKisiler[satir[2] - 1] = 0;
                } else {
                  rota.add(satir[1]);
                  rota.add(satir[2]);
                  print("371");
                  if (geciciKisiler[satir[1] - 1] <=
                      geciciKisiler[satir[2] - 1]) {
                    if (geciciKisiler[satir[1] - 1] <
                        mevcutServisKapasiteleri[rotalar.length]) {
                      geciciKisiler[satir[2] - 1] -=
                          (mevcutServisKapasiteleri[rotalar.length] -
                              geciciKisiler[satir[1] - 1]);
                      geciciKisiler[satir[1] - 1] = 0;
                    } else {
                      geciciKisiler[satir[1] - 1] -=
                          mevcutServisKapasiteleri[rotalar.length];
                    }
                  } else if (geciciKisiler[satir[1] - 1] >
                      geciciKisiler[satir[2] - 1]) {
                    if (geciciKisiler[satir[2] - 1] <
                        mevcutServisKapasiteleri[rotalar.length]) {
                      geciciKisiler[satir[1] - 1] -=
                          (mevcutServisKapasiteleri[rotalar.length] -
                              geciciKisiler[satir[2] - 1]);
                      geciciKisiler[satir[2] - 1] = 0;
                    } else {
                      geciciKisiler[satir[2] - 1] -=
                          mevcutServisKapasiteleri[rotalar.length];
                    }
                  }
                }
                kapasiteler.add(mevcutServisKapasiteleri[rotalar.length]);
                rotalar.add(rota);
              }
            }
          } else if (r2 == null) {
            if (kapasiteler[r1] + geciciKisiler[satir[2] - 1] <=
                mevcutServisKapasiteleri[r1]) {
              rotalar[r1].add(satir[2]);
              kapasiteler[r1] += geciciKisiler[satir[2] - 1];
              geciciKisiler[satir[2] - 1] = 0;
            } else if (kapasiteler[r1] < mevcutServisKapasiteleri[r1]) {
              rotalar[r1].add(satir[2]);
              geciciKisiler[satir[2] - 1] -=
                  (mevcutServisKapasiteleri[r1] - kapasiteler[r1]);
              kapasiteler[r1] = mevcutServisKapasiteleri[r1];
            } else if (geciciKisiler[satir[1] - 1] != 0) {
              if (geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1] <=
                  mevcutServisKapasiteleri[rotalar.length]) {
                List<int> rota = [];
                rota.add(satir[1]);
                rota.add(satir[2]);
                rotalar.add(rota);
                kapasiteler.add(
                    geciciKisiler[satir[1] - 1] + geciciKisiler[satir[2] - 1]);
                geciciKisiler[satir[1] - 1] = 0;
                geciciKisiler[satir[2] - 1] = 0;
              } else if (geciciKisiler[satir[1] - 1] <
                  geciciKisiler[satir[2] - 1]) {
                List<int> rota = [];
                if (geciciKisiler[satir[1] - 1] ==
                    mevcutServisKapasiteleri[rotalar.length]) {
                  rota.add(satir[1]);
                  geciciKisiler[satir[1] - 1] = 0;
                } else if (geciciKisiler[satir[2] - 1] ==
                    mevcutServisKapasiteleri[rotalar.length]) {
                  rota.add(satir[2]);
                  geciciKisiler[satir[2] - 1] = 0;
                } else {
                  rota.add(satir[1]);
                  rota.add(satir[2]);
                  print("404");
                  if (geciciKisiler[satir[1] - 1] <=
                      geciciKisiler[satir[2] - 1]) {
                    if (geciciKisiler[satir[1] - 1] <
                        mevcutServisKapasiteleri[rotalar.length]) {
                      geciciKisiler[satir[2] - 1] -=
                          (mevcutServisKapasiteleri[rotalar.length] -
                              geciciKisiler[satir[1] - 1]);
                      geciciKisiler[satir[1] - 1] = 0;
                    } else {
                      geciciKisiler[satir[1] - 1] -=
                          mevcutServisKapasiteleri[rotalar.length];
                    }
                  } else if (geciciKisiler[satir[1] - 1] >
                      geciciKisiler[satir[2] - 1]) {
                    if (geciciKisiler[satir[2] - 1] <
                        mevcutServisKapasiteleri[rotalar.length]) {
                      geciciKisiler[satir[1] - 1] -=
                          (mevcutServisKapasiteleri[rotalar.length] -
                              geciciKisiler[satir[2] - 1]);
                      geciciKisiler[satir[2] - 1] = 0;
                    } else {
                      geciciKisiler[satir[2] - 1] -=
                          mevcutServisKapasiteleri[rotalar.length];
                    }
                  }
                }
                kapasiteler.add(mevcutServisKapasiteleri[rotalar.length]);
                rotalar.add(rota);
              }
            }
          } else {
            if (r1 != r2) {
              if (kapasiteler[r1] + kapasiteler[r2] <=
                  mevcutServisKapasiteleri[r1]) {
                rotalar[r1].addAll(rotalar[r2]);
                rotalar.remove(rotalar[r2]);
                kapasiteler[r1] += kapasiteler[r2];
                kapasiteler.remove(kapasiteler[r2]);
              } else if (kapasiteler[r1] + kapasiteler[r2] <=
                  mevcutServisKapasiteleri[r2]) {
                rotalar[r2].addAll(rotalar[r1]);
                rotalar.remove(rotalar[r1]);
                kapasiteler[r2] += kapasiteler[r1];
                kapasiteler.remove(kapasiteler[r1]);
              } else if (geciciKisiler[satir[1] - 1] != 0) {
                if (kapasiteler[r2] < mevcutServisKapasiteleri[r2]) {
                  print(
                      "satir1 if ${rotalar[r2]} , ${kapasiteler[r2]}, ${satir[1]}");
                  rotalar[r2].add(satir[1]);
                  geciciKisiler[satir[1] - 1] -=
                      (mevcutServisKapasiteleri[r2] - kapasiteler[r2]);
                  kapasiteler[r2] = mevcutServisKapasiteleri[r2];
                }
              } else if (geciciKisiler[satir[2] - 1] != 0) {
                if (kapasiteler[r1] < mevcutServisKapasiteleri[r1]) {
                  print(
                      "satir2 if ${rotalar[r1]} , ${kapasiteler[r1]}, ${satir[2]}");
                  rotalar[r1].add(satir[2]);
                  geciciKisiler[satir[2] - 1] -=
                      (mevcutServisKapasiteleri[r1] - kapasiteler[r1]);
                  kapasiteler[r1] = mevcutServisKapasiteleri[r1];
                }
              }
            }
          }
        }
      }

      for (int i = 0; i < kisiler.length; i++) {
        if (geciciKisiler[i] != 0) {
          while (geciciKisiler[i] > 0) {
            print("girdim");
            if (geciciKisiler[i] + kapasiteler.last <=
                mevcutServisKapasiteleri[rotalar.length - 1]) {
              print("1)geciciKisiler:${geciciKisiler[i]}");
              rotalar.last.add(i + 1);
              geciciKisiler[i] = 0;
            } else {
              if (geciciKisiler[i] > mevcutServisKapasiteleri[rotalar.length]) {
                print("2)geciciKisiler:${geciciKisiler[i]}");
                kapasiteler.add(mevcutServisKapasiteleri[rotalar.length]);
                geciciKisiler[i] -= mevcutServisKapasiteleri[rotalar.length];
              } else {
                print("sıfırlamadan önce else");
                kapasiteler.add(geciciKisiler[i]);
                geciciKisiler[i] = 0;
              }
              List<int> rota = [];
              rota.add(i + 1);
              rotalar.add(rota);
            }
          }
        }
      }
      print(geciciKisiler);

      for (int i = 0; i < rotalar.length; i++) {
        List<int> element = rotalar[i];
        element.sort(
            (a, b) => mesafeTablo[a - 1][0].compareTo(mesafeTablo[b - 1][0]));
        if (mesafeTablo[element[0] - 1][0] <=
            mesafeTablo[element[element.length - 1] - 1][0]) {
          element.insert(0, 0);
          element = List.of(element.reversed);
        } else {
          element.add(0);
        }
        print(element);
        rotalar[i] = element;
      }
      print(kisiler);

      degiskenler.yolcuEklendi![1] = false;
      degiskenler.servisKapasiteleri = sinirliServisKapasiteleri;
      r.rotalar = rotalar;
      r.kisiler = [];
      r.kalanlar = [];
      await _firestoreBase.updateRota(r);
      await _firestoreBase.updateParametre(degiskenler);
    } else {
      rotalar = r.rotalar!;
    }

    await rotalariOlustur();

    return [polyLines, rotalar, r.kisiler, r.kalanlar];
  }

  search(int start, int word) {
    for (int i = start; i < rotalar.length; i++) {
      List<int> rota = rotalar[i];

      if (rota.contains(word)) {
        return i;
      }
    }
  }

  List<List> quickSort(List<List> list, int low, int high) {
    if (low < high) {
      int pi = partition(list, low, high);
      quickSort(list, low, pi - 1);
      quickSort(list, pi + 1, high);
    }
    return list;
  }

  int partition(List<List> list, low, high) {
    if (list.isEmpty) {
      return 0;
    }
    int pivot = list[high][0];
    int i = low - 1;
    for (int j = low; j < high; j++) {
      if (list[j][0] < pivot) {
        i++;
        swap(list, i, j);
      }
    }
    swap(list, i + 1, high);
    return i + 1;
  }

  void swap(List list, int i, int j) {
    List temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }
}

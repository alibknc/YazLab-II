import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kou_servis/models/location.dart';
import 'package:kou_servis/models/parametre.dart';
import 'package:kou_servis/services/GoogleMapsAPI.dart';
import 'package:kou_servis/services/firestore_base.dart';
import 'package:kou_servis/utils/algorithm.dart';
import 'package:random_string/random_string.dart';
import 'package:timelines/timelines.dart';

class Home extends StatefulWidget {
  final int choice;

  const Home({Key? key, required this.choice}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late GoogleMapController gmController;
  GoogleMapsAPI api = GoogleMapsAPI();
  FirestoreBase _firestoreBase = FirestoreBase();
  late Parametre parametre;
  Widget text = Container();
  List<Location> list = [];
  List<List<int>> rotalar = [];
  List kisiler = [];
  List kalanlar = [];

  Marker? start;
  Marker? end;
  Set<Polyline>? info = {};
  Set<Marker>? markers = {};

  @override
  void dispose() {
    gmController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Servis Rota", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 2,
            child: GoogleMap(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                new Factory<OneSequenceGestureRecognizer>(
                  () => new EagerGestureRecognizer(),
                ),
              ].toSet(),
              markers: markers!,
              polylines: info!,
              initialCameraPosition: CameraPosition(
                  target: LatLng(40.85479817561078, 29.856240525841717),
                  zoom: 9),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              onMapCreated: (controller) => gmController = controller,
            ),
          ),
          info!.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: rotalar.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            EdgeInsets.only(right: 10.0, left: 10.0, top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Güzergah ${index + 1}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "(Kapasite: ${parametre.servisKapasiteleri![index]})",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.grey.shade700,
                            ),
                            SizedBox(height: 10),
                            kalanlar.isNotEmpty && kisiler.isNotEmpty
                                ? timeline(rotalar[index], kisiler[index],
                                    kalanlar[index])
                                : timeline(rotalar[index], [], [])
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  timeline(var rota, var alinan, var kalan) {
    return FixedTimeline.tileBuilder(
      builder: TimelineTileBuilder.connected(
        itemCount: 2,
        connectionDirection: ConnectionDirection.before,
        contentsBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        Text(
                          index == 0
                              ? "${list[rota[0]].konumAdi}"
                              : "${list[rota[rota.length - 1]].konumAdi}",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        SizedBox(width: 5),
                        Text(
                          kalan.isNotEmpty && alinan.isNotEmpty
                              ? (index == 0
                                  ? "(Bekleyen: ${kalan[0]}) (Alınan: ${alinan[0]})"
                                  : "")
                              : "",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    )),
                index > 0
                    ? Container()
                    : FixedTimeline.tileBuilder(
                        builder: TimelineTileBuilder.connected(
                          itemCount: rota.length - 2,
                          connectionDirection: ConnectionDirection.before,
                          contentsBuilder: (_, index) {
                            return Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 5.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          "${list[rota[index + 1]].konumAdi}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          kalan.isNotEmpty && alinan.isNotEmpty
                                              ? ("(Yolcu: ${kalan[index + 1]}) (Alınan: ${alinan[index + 1]})")
                                              : "",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          indicatorBuilder: (_, index) {
                            return DotIndicator(
                              color: Color(0xff66c97f),
                              child: Center(
                                child: Text(
                                  "${index + 2}",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                          connectorBuilder: (_, index, ___) {
                            return SolidLineConnector(
                              color: Color(0xff66c97f),
                            );
                          },
                        ),
                        theme: TimelineThemeData(
                          nodePosition: 0,
                          color: Color(0xff989898),
                          indicatorTheme: IndicatorThemeData(
                            position: 0,
                            size: 20.0,
                          ),
                          connectorTheme: ConnectorThemeData(
                            thickness: 2.5,
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
        indicatorBuilder: (_, index) {
          return DotIndicator(
            color: Color(0xff66c97f),
            child: Center(
              child: Text(
                index == 0 ? "${index + 1}" : "${rota.length}",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        connectorBuilder: (_, index, ___) {
          return SolidLineConnector(
            color: Color(0xff66c97f),
          );
        },
      ),
      theme: TimelineThemeData(
        nodePosition: 0,
        color: Color(0xff989898),
        indicatorTheme: IndicatorThemeData(
          position: 0,
          size: 20.0,
        ),
        connectorTheme: ConnectorThemeData(
          thickness: 2.5,
        ),
      ),
    );
  }

  getData() async {
    Algorithm algorithm = Algorithm();
    list = await _firestoreBase.getLocations();
    parametre = await _firestoreBase.getParametre();

    List? veri;
    switch (widget.choice) {
      case 0:
        await algorithm.parametreAl(list, parametre, 1);
        veri = await algorithm.sinirsizServis();
        break;
      case 1:
        await algorithm.parametreAl(list, parametre, 0);
        veri = await algorithm.sinirliServis();
        break;
    }

    List<List<List>> polyLines = veri![0];
    rotalar = veri[1];
    kisiler = veri[2];
    kalanlar = veri[3];

    for (int i = 0; i < polyLines.length; i++) {
      List<List> parts = polyLines[i];
      Color color = Colors.primaries[Random().nextInt(Colors.primaries.length)];

      for (int j = 0; j < parts.length; j++) {
        List part = parts[j];
        Polyline pl = Polyline(
            polylineId: PolylineId(randomString(5)),
            color: color,
            width: 3,
            points: part[2]!
                .polyLinePoints!
                .map<LatLng>((e) => LatLng(e.latitude, e.longitude))
                .toList());
        setState(() {
          info!.add(pl);
        });

        Marker s = part[0];
        Marker e = part[1];
        setState(() {
          markers!.add(s);
          markers!.add(e);
        });
      }
    }
  }
}

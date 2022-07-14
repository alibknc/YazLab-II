import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kou_servis/models/location.dart';
import 'package:kou_servis/models/parametre.dart';
import 'package:kou_servis/models/user.dart';
import 'package:kou_servis/services/firestore_base.dart';
import 'package:kou_servis/utils/consts.dart';

class YeniKayit extends StatefulWidget {
  final AppUser? user;
  const YeniKayit({Key? key, this.user}) : super(key: key);

  @override
  _YeniKayitState createState() => _YeniKayitState();
}

class _YeniKayitState extends State<YeniKayit> {
  FirestoreBase _firestoreBase = FirestoreBase();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  Location? parametre;
  List<Location>? data;

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: Theme
            .of(context)
            .iconTheme,
        title: Text(
          "Parametreler",
          style: TextStyle(color: Theme
              .of(context)
              .iconTheme
              .color),
        ),
      ),
      body: Container(
          color: Colors.white,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(top: 5, left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: parametre == null
                        ? [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    ]
                        : [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.only(
                            right: 15, left: 15, top: 8, bottom: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade700,
                                width: 0.6)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Durak Seçiniz",
                                style: TextStyle(
                                    fontFamily: "Araboto-Medium", fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 2,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Location>(
                                  value: parametre,
                                  items: data!
                                      .map((Location value) {
                                    return DropdownMenuItem<Location>(
                                      value: value,
                                      child: Text("${value.konumAdi}"),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      parametre = newValue;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(29),
                          child: FlatButton(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 40),
                            color: Colors.redAccent,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Vazgeç",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(29),
                          child: FlatButton(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 40),
                            color: Constants.primary,
                            onPressed: parametre == null ? null : () async {
                              unfocus();
                              dialog();
                              widget.user!.konumID = parametre!.id;
                              widget.user!.basvuruDurumu = false;
                              await _firestoreBase.updateUser(widget.user!);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Kaydet",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }

  getData() async {
    data = await _firestoreBase.getAllLocations();
    setState(() {
      parametre = data!.firstWhere((element) => element.id == widget.user!.konumID);
    });
  }

  Future<Future<bool?>> dialog() async {
    return showDialog<bool?>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            content: Container(
                height: 50,
                alignment: Alignment.center,
                child: CircularProgressIndicator(color: Constants.primary)),
            title: Text("Güncelleniyor..."),
          );
        });
  }

  void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

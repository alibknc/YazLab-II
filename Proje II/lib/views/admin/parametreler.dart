import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kou_servis/models/parametre.dart';
import 'package:kou_servis/services/firestore_base.dart';
import 'package:kou_servis/utils/consts.dart';

class Parametreler extends StatefulWidget {
  const Parametreler({Key? key}) : super(key: key);

  @override
  _ParametrelerState createState() => _ParametrelerState();
}

class _ParametrelerState extends State<Parametreler> {
  FirestoreBase _firestoreBase = FirestoreBase();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  TextEditingController ekSK = TextEditingController();
  TextEditingController yM = TextEditingController();
  Parametre? parametre;

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
                            Text(
                              "Yol Maliyeti",
                              style: TextStyle(
                                  fontFamily: "Araboto-Medium", fontSize: 16),
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 2,
                              child: TextField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.number,
                                minLines: 1,
                                maxLines: 1,
                                controller: yM,
                                onSubmitted: (val) {
                                  if (yM.text.isEmpty) {
                                    yM.text = "0";
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "Yol Maliyeti",
                                  errorText: ekSK.text.isEmpty
                                      ? "Bu alan boş bırakılamaz!"
                                      : null,
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                "Ek Servis Kapasitesi",
                                style: TextStyle(
                                    fontFamily: "Araboto-Medium", fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 2,
                              child: TextField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.number,
                                minLines: 1,
                                maxLines: 1,
                                controller: ekSK,
                                onSubmitted: (val) {
                                  if (ekSK.text.isEmpty) {
                                    ekSK.text = "0";
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "Ek Servis Kapasitesi",
                                  errorText: yM.text.isEmpty
                                      ? "Bu alan boş bırakılamaz!"
                                      : null,
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                              parametre!.ekServisKapasite = int.parse(ekSK.text);
                              parametre!.yolMaliyeti = int.parse(yM.text);
                              parametre!.yolcuEklendi = parametre!.yolcuEklendi!.map((element) {
                                return element = true;
                              }).toList();
                              await _firestoreBase.updateParametre(parametre!);
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
    var data = await _firestoreBase.getParametre();
    setState(() {
      parametre = data;
      yM.text = parametre!.yolMaliyeti.toString();
      ekSK.text = parametre!.ekServisKapasite.toString();
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

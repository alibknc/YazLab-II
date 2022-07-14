import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kou_servis/models/location.dart';
import 'package:kou_servis/models/parametre.dart';
import 'package:kou_servis/services/firestore_base.dart';
import 'package:kou_servis/utils/consts.dart';

class Passengers extends StatefulWidget {
  const Passengers({Key? key}) : super(key: key);

  @override
  _PassengersState createState() => _PassengersState();
}

class _PassengersState extends State<Passengers> {
  FirestoreBase _firestoreBase = FirestoreBase();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  List<Widget> items = [];
  List<Location> locations = [];
  List<TextEditingController> controllers = [];
  late Parametre parametre;

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
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          "Yolcu Verileri",
          style: TextStyle(color: Theme.of(context).iconTheme.color),
        ),
        actions: [
          items.isNotEmpty ? TextButton(
            child: Text(
              "Sıfırla",
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              controllers.forEach((element) {
                element.text = "";
              });
            },
          ) : Container()
        ],
      ),
      body: Container(
          color: Colors.white,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(top: 5, left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: items.isEmpty
                        ? [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          ]
                        : items,
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
                            onPressed: items.isEmpty
                                ? null
                                : () async {
                                    unfocus();
                                    dialog();
                                    for (int i = 0; i < locations.length; i++) {
                                      if (controllers[i].text.isEmpty) {
                                        controllers[i].text = "0";
                                      }
                                      locations[i].kisi =
                                          int.parse(controllers[i].text);
                                    }
                                    parametre.yolcuEklendi = parametre.yolcuEklendi!.map((element) {
                                      return element = true;
                                    }).toList();
                                    await _firestoreBase.changeLists(locations);
                                    await _firestoreBase.updateParametre(parametre);
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
    locations = await _firestoreBase.getAllLocations();
    parametre = await _firestoreBase.getParametre();
    locations.sort((a, b) => a.konumAdi!.compareTo(b.konumAdi!));
    createItem();
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

  void createItem() {
    locations.forEach((element) {
      TextEditingController controller = TextEditingController();
      controllers.add(controller);
      controller.text = element.kisi.toString();

      Widget item = Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.only(right: 15, left: 15, top: 8, bottom: 5),
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade700, width: 0.6)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              element.konumAdi!,
              style: TextStyle(fontFamily: "Araboto-Medium", fontSize: 16),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                minLines: 1,
                maxLines: 1,
                controller: controller,
                onSubmitted: (val) {
                  if (controller.text.isEmpty) {
                    controller.text = "0";
                  }
                },
                decoration: InputDecoration(
                  hintText: "Yolcu Sayısı",
                  errorText: controller.text.isEmpty
                      ? "Bu alan boş bırakılamaz!"
                      : null,
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );
      setState(() {
        items.add(item);
      });
    });
  }
}

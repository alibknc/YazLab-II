import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kou_servis/utils/consts.dart';
import 'package:kou_servis/views/home/home.dart';

class HomeChoices extends StatefulWidget {
  const HomeChoices({Key? key}) : super(key: key);

  @override
  _HomeChoicesState createState() => _HomeChoicesState();
}

class _HomeChoicesState extends State<HomeChoices> {
  late bool processing;

  @override
  void initState() {
    super.initState();
    processing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(20)),
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 5,
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Sınırlı Servis",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Home(choice: 1)));
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Constants.primary,
                            borderRadius: BorderRadius.circular(20)),
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 5,
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Sınırsız Servis",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Home(choice: 0)));
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 10),
            ],
          )),
    );
  }
}

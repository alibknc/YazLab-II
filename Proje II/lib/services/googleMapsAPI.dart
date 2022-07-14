import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kou_servis/models/directions.dart';

class GoogleMapsAPI{
  final String key = "AIzaSyAvk83btnuO5jVr0zUrMd2nLQY-RtSKl6I";

  Future getDistance(String origin, String destinations) async{
    String uri = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origin&destinations=$destinations&key=$key";
    var result = await http.get(Uri.parse(uri));
    var json = jsonDecode(result.body);
    return json['rows'][0]['elements'][0]['distance']['value'];
  }

  Future<Directions> getWay(LatLng origin, LatLng destinations) async{
    String o = "${origin.latitude}%2C${origin.longitude}";
    String d = "${destinations.latitude}%2C${destinations.longitude}";
    String uri = "https://maps.googleapis.com/maps/api/directions/json?origin=$o&destination=$d&key=$key";
    var result = await http.get(Uri.parse(uri));
    var json = jsonDecode(result.body);
    return Directions.fromMap(json);
  }


}
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions{
  LatLngBounds? bounds;
  int? totalDistance;
  List<PointLatLng>? polyLinePoints;

  Directions(LatLngBounds bounds, int totalDistance, List<PointLatLng> polyLinePoints){
    this.bounds = bounds;
    this.totalDistance = totalDistance;
    this.polyLinePoints = polyLinePoints;
  }

  factory Directions.fromMap(dynamic data){
    data = data['routes'][0];
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(southwest: LatLng(southwest['lat'], southwest['lng']), northeast: LatLng(northeast['lat'], northeast['lng']));
    final leg = data['legs'][0];
    final totalDistance = leg['distance']['value'];
    
    return Directions(bounds, totalDistance, PolylinePoints().decodePolyline(data['overview_polyline']['points']));
   }
}
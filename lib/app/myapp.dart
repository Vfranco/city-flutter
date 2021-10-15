import 'dart:async';
import 'dart:convert';
//import 'dart:developer';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import './model/data.dart';

final List<String> imgList = ['assets/images/step_1.png', 'assets/images/step_2.png', 'assets/images/step_3.png'];

class BodyJson {
  final String id;
  final double latitud;
  final double longitud;
  final String name;

  BodyJson({this.id, this.latitud, this.longitud, this.name});

  factory BodyJson.fromJson(Map<String, dynamic> json) {
    return new BodyJson(
      id: json['id'].toString(),
      latitud: json['latitud'],
      longitud: json['longitud'],
      name: json['name'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': this.id, 'avatar': this.latitud, 'image': this.longitud, 'name': this.name};
}

class Response {
  bool status;
  int code;
  String message;
  List<MarkerDetailsResponse> response;
}

class MarkerDetailsResponse {
  int dispCelBicicletas;
  int maxCelBicicletas;
  int dispCelMoto;
  int maxCelMoto;
  int avlCellCar;
  int maxCelCar;
  String nameZone;
  int lnt;
  int lng;
  String horaApertura;
  String horaCierre;
  String dirCmsZonas;
  String tariffCar;
  String tariffMot;
}

final themeMode = ValueNotifier(2);

class CityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Navigtion',
      routes: <String, WidgetBuilder>{},
      home: new CarouselDemo(),
    );
  }
}

class CarouselDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      builder: (context, value, g) {
        return MaterialApp(
          initialRoute: '/',
          routes: {'/': (ctx) => FullscreenSliderDemo()},
        );
      },
      valueListenable: themeMode,
    );
  }
}

class FullscreenSliderDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return CarouselSlider(
            options: CarouselOptions(height: height, viewportFraction: 1, enlargeCenterPage: false),
            items: imgList
                .map((item) => Container(
                      child: Center(
                          child: Image.asset(
                        item,
                        fit: BoxFit.fill,
                        height: height,
                      )),
                    ))
                .toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToNextScreen(context);
        },
        child: Icon(Icons.gps_fixed_sharp),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => GoogleMapView()));
  }
}

class GoogleMapView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('City Cparking')),
      body: MapSample(),
    );
  }
}

// MAPA MARKET

int _currentCount = 0;

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(6.1663109, -75.616949),
    zoom: 10,
  );

  List<Marker> _markers = <Marker>[];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
        markers: Set<Marker>.of(_markers),
        mapToolbarEnabled: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToTheLake,
        child: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(await getCurrentPosition()));
  }

  Future<CameraPosition> getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    CameraPosition cameraPosition = CameraPosition(target: LatLng(6.1713677, -75.5875945), zoom: 15);

    List<BodyJson> httpResponse = [
      BodyJson(
        id: "1",
        name: "Office Code",
        latitud: 36.43296265331120,
        longitud: -122.08832357078790,
      ),
      BodyJson(
        id: "2",
        name: "new Baga",
        latitud: 37.43296265331119,
        longitud: -122.08832357078782,
      )
    ];

    List<dynamic> response = await getAllMarkers(position);

    response.forEach((element) {
      _currentCount++;
      print(element['lnt']);
      _markers.add(Marker(markerId: MarkerId('id-$_currentCount'), position: LatLng(element['lnt'], element['lng']), infoWindow: InfoWindow(title: element['nameZone'])));
    });

    httpResponse.forEach((element) {
      print('Howdy, ${element.name}! ----------------------------');
      //_markers.add(Marker(markerId: MarkerId(element.id), position: LatLng(element.latitud, element.longitud), infoWindow: InfoWindow(title: element.name)));
    });

    //_markers.add(Marker(markerId: MarkerId('markerCity'), position: LatLng(position.latitude, position.longitude), infoWindow: InfoWindow(title: 'Marker')));
    //_markers.add(Marker(markerId: MarkerId('markerCity2'), position: LatLng(37.43296265331129, -122.08832357078792), infoWindow: InfoWindow(title: 'Marker2')));
    setState(() {});
    return cameraPosition;
  }

  Future<List<dynamic>> getAllMarkers(Position position) async {
    print(position.latitude.toString());
    print(position.longitude.toString());

    var makeRequest = await http.post(Uri.parse('https://api.cparking.co/city/getmarkers'),
        headers: {"Content-type": "application/json"}, body: jsonEncode({"lnt_1": 6.1500, "lng_1": -75.6000, "lnt_2": 6.1500, "lng_2": -75.6000}));

    var jsonBody = json.decode(makeRequest.body);

    List<dynamic> data = jsonBody['response'];

    return data;
  }
}

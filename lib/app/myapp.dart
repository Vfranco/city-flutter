import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

final List<String> imgList = [
  'assets/images/step_1.png',
  'assets/images/step_2.png',
  'assets/images/step_3.png'
];

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
            options: CarouselOptions(
                height: height, viewportFraction: 1, enlargeCenterPage: false),
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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => GoogleMapView()));
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

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 13,
  );

  List<Marker> _markers = <Marker>[];
  List<Marker> _markersResponse = <Marker>[];

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
        onCameraIdle: () async {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);

          var markers = await getAllMarkers(position);

          markers.forEach((element) {
            Marker mark = Marker(
                markerId: MarkerId(element['nameZone'] ?? ''),
                position: LatLng(element['lat'] ?? 0, element['lng'] ?? 0),
                infoWindow: InfoWindow(title: element['nameZone'] ?? ''));

            _markers.add(mark);
          });

          setState(() async {});
        },
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
    controller.animateCamera(
        CameraUpdate.newCameraPosition(await getCurrentPosition()));
  }

  Future<CameraPosition> getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 17);

    getMarkerCurrentPosition();
    return cameraPosition;
  }

  Future<void> getMarkerCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('markerCity'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Marker')));
    });
  }

  Future<List<dynamic>> getAllMarkers(Position position) async {
    var makeRequest =
        await http.post(Uri.parse('https://api.cparking.co/city/getmarkers'),
            headers: {"Content-type": "application/json"},
            body: jsonEncode({
              "lnt_1": position.latitude.toString(),
              "lng_1": position.longitude.toString(),
              "lnt_2": position.latitude.toString(),
              "lng_2": position.longitude.toString()
            }));

    Map<String, dynamic> jsonBody = json.decode(makeRequest.body);
    List<dynamic> markers = jsonBody['response'];

    return markers;
  }
}

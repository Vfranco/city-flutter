// To parse this JSON data, do
//
//     final dataRequest = dataRequestFromJson(jsonString);

import 'dart:convert';

DataRequest dataRequestFromJson(String str) => DataRequest.fromJson(json.decode(str));

String dataRequestToJson(DataRequest data) => json.encode(data.toJson());

class DataRequest {
  DataRequest({
    this.dispCelBicicletas,
    this.maxCelBicicletas,
    this.dispCelMoto,
    this.maxCelMoto,
    this.avlCellCar,
    this.maxCelCar,
    this.nameZone,
    this.lnt,
    this.lng,
    this.horaApertura,
    this.horaCierre,
    this.dirCmsZonas,
    this.tariffCar,
    this.tariffMot,
  });

  int dispCelBicicletas;
  int maxCelBicicletas;
  int dispCelMoto;
  int maxCelMoto;
  int avlCellCar;
  int maxCelCar;
  String nameZone;
  double lnt;
  double lng;
  String horaApertura;
  String horaCierre;
  String dirCmsZonas;
  String tariffCar;
  String tariffMot;

  factory DataRequest.fromJson(Map<String, dynamic> json) => DataRequest(
        dispCelBicicletas: json["dispCelBicicletas"],
        maxCelBicicletas: json["maxCelBicicletas"],
        dispCelMoto: json["dispCelMoto"],
        maxCelMoto: json["maxCelMoto"],
        avlCellCar: json["avlCellCar"],
        maxCelCar: json["maxCelCar"],
        nameZone: json["nameZone"],
        lnt: json["lnt"].toDouble(),
        lng: json["lng"].toDouble(),
        horaApertura: json["horaApertura"],
        horaCierre: json["horaCierre"],
        dirCmsZonas: json["dirCmsZonas"],
        tariffCar: json["tariffCar"],
        tariffMot: json["tariffMot"],
      );

  Map<String, dynamic> toJson() => {
        "dispCelBicicletas": dispCelBicicletas,
        "maxCelBicicletas": maxCelBicicletas,
        "dispCelMoto": dispCelMoto,
        "maxCelMoto": maxCelMoto,
        "avlCellCar": avlCellCar,
        "maxCelCar": maxCelCar,
        "nameZone": nameZone,
        "lnt": lnt,
        "lng": lng,
        "horaApertura": horaApertura,
        "horaCierre": horaCierre,
        "dirCmsZonas": dirCmsZonas,
        "tariffCar": tariffCar,
        "tariffMot": tariffMot,
      };
}

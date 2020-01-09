import 'package:caza_mayor/clases.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class Mapa extends StatefulWidget{
  final Usuario detailsUser;

  const Mapa({Key key, @required this.detailsUser}) : super(key: key);

  @override
  State<Mapa> createState(){
    return new MapaState();
  }

}

class MapaState extends State<Mapa>{

  List<Marker> cazas = new List<Marker>();

  @override
  void initState() {
    super.initState();

    for(int i = 0; i < widget.detailsUser.ubiCazas.length; i++){
      cazas.add(new Marker(
        width: 80.0,
        height: 80.0,
        point: new LatLng(widget.detailsUser.ubiCazas.elementAt(i).latitud, widget.detailsUser.ubiCazas.elementAt(i).longitud),
        builder: (ctx) =>
        new Container(
          child: Icon(Icons.location_on, color: Colors.red,),
        ),
      ));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa de cazas"),),
      body: Center(
        child: new FlutterMap(
          options: new MapOptions(
            center:
            (widget.detailsUser.ubiCazas.length != 0
            ?new LatLng(
                widget.detailsUser.ubiCazas.elementAt(0).latitud,
                widget.detailsUser.ubiCazas.elementAt(0).longitud)
            :new LatLng(0.0, 0.0)
            ),
            zoom: 16.0
          ),
          layers: [
            new TileLayerOptions(
              urlTemplate: "https://api.mapbox.com/v4/{id}/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1IjoiZ3VpbGxlY29ycCIsImEiOiJjazU1czR4ZW8wdWVkM2pvZnkweHl3bDF3In0.Qtz5Hpz0JIIu9zYCFXMr_Q",
              additionalOptions: {
                'accessToken': 'pk.eyJ1IjoiZ3VpbGxlY29ycCIsImEiOiJjazU1czR4ZW8wdWVkM2pvZnkweHl3bDF3In0.Qtz5Hpz0JIIu9zYCFXMr_Q',
                'id': 'mapbox.streets',
              }
            ),
            new MarkerLayerOptions(
              markers: cazas
            )
          ],
        ),
      ),
    );
  }

}
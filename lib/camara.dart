import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:caza_mayor/caza.dart';
import 'package:caza_mayor/clases.dart';
import 'package:caza_mayor/perfil.dart';
import 'package:caza_mayor/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

// Pantalla que permite hacer una foto con la camara dada.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final Usuario detailsUser;

  const TakePictureScreen({
    Key key,
    @required this.camera,
    @required this.detailsUser
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Crear un CameraController para mostrar la camara.
    _controller = CameraController(
      // Obtiene la camara especificada de la lista de camaras disponibles.
      widget.camera,
      // Define la resolucion que se va a usar.
      ResolutionPreset.medium,
    );

    // Inicializa el controlador. Devuelve un objeto Future
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Borra el controlador cuando el widget se deje de usarse.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cámara"),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 15.0, top: 5.0, bottom: 5.0),
              child: InkWell(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                        child: Image(
                            fit: BoxFit.cover,
                            image: new NetworkImage(widget.detailsUser.foto)
                        )
                    ),
                  ),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Perfil(detailsUser: widget.detailsUser,),
                      ),
                    );
                  }

              )
          )
        ],
      ),
      // Espera hasta que el controlador este iniciado antes de mostrar
      // la camara. Se usa un FutureBuilder para mostrar un icono de
      // carga hasta que se muestre la camara.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Cuando el controlador este iniciado, muestra la camara
            final size = MediaQuery.of(context).size;
            final deviceRatio = size.width / size.height;
            return Stack(
              children: <Widget>[
                Container(
                  child: Transform.scale(
                    scale: _controller.value.aspectRatio / deviceRatio,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: CameraPreview(_controller),
                      ),
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      child: Container(
                        height: 75,
                        width: size.width,
                        color: Colors.black,
                        child: Center(child: Icon(Icons.camera_alt)),
                      ),
                      onTap: () async {
                        try {
                          // Asegurarse de que la camara este iniciada.
                          await _initializeControllerFuture;

                          // Elimina todas las fotos que puedan estar guardadas
                          while(pathsImages.isNotEmpty){
                            pathsImages.removeLast();
                          }

                          for(var i = 0; i < 5; i++) {
                            // Construye la ruta donde se guardara la imagen
                            final path = join(
                              // Guarda la imagen en el directorio temporal.
                              (await getTemporaryDirectory()).path,
                              '${DateTime.now()}.png',
                            );

                            // Hace la foto y logea cuando este guardada.
                            await _controller.takePicture(path);

                            // Añade la imagen a la lista de imagenes.
                            pathsImages.add({"ruta": path, "seleccionada": false});
                            print("foto");
                            sleep(const Duration(seconds: 3));
                          }
                          // Coordenadas de la captura
                          Geolocator geolocator = Geolocator();
                          Position currentLocation = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);

                          // Cuando la foto se haga, la muestra en otra pantalla.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DisplayPictureScreen(location: currentLocation, detailsUser: widget.detailsUser,),
                            ),
                          );
                        } catch (e) {
                          // Si ocurre algun error, lo muestra.
                          print(e);
                        }
                      },
                    )
                ),
              ],
            );

          } else {
            // Mientras tanto, muestra el icono de carga
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

// Pantalla que muestra las fotos hechas por el usuario
class DisplayPictureScreen extends StatelessWidget {
  final Position location;
  final Usuario detailsUser;

  const DisplayPictureScreen({Key key, @required this.location, @required this.detailsUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Imagenes')),
      body: Galeria(location: location, detailsUser: detailsUser,),
    );
  }
}

class ImagenGaleria extends StatefulWidget{
  ImagenGaleria({Key key, @required this.imagen, @required this.onChanged}): super(key: key);

  var imagen;
  final ValueChanged<bool> onChanged;

  @override
  State<ImagenGaleria> createState(){
    print("Imagen creada");
    return new ImagenGaleriaState(imgst: imagen, onChanged: onChanged);
  }
}

class ImagenGaleriaState extends State<ImagenGaleria>{

  ImagenGaleriaState({this.imgst, this.onChanged});

  var imgst;
  final ValueChanged<bool> onChanged;

  void _click(){
    setState(() {
      for(var i in pathsImages){
        i["seleccionada"] = false;
      }
      imgst["seleccionada"] = true;
    });
    onChanged(true);
  }

  @override
  Widget build(BuildContext context){
    return FlatButton(
        onPressed: (){_click();},
        child: Image.file(File(imgst["ruta"]))
    );
  }
}

class Galeria extends StatefulWidget{
  final Position location;
  final Usuario detailsUser;

  const Galeria({Key key, @required this.location, @required this.detailsUser}): super(key: key);

  @override
  State<Galeria> createState(){
    return new GaleriaState();
  }
}

class GaleriaState extends State<Galeria>{

  void _cambiarImagen(p){
    setState(() {
      print("Cambia imagen");
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: <Widget>[
        Expanded(
            child: Image.file(imgSeleccionada())
        ),
        Container(
          height: 150,
          width: MediaQuery.of(context).size.width,
          child: FittedBox(
              child: Row(
                children: <Widget>[
                  for(var i in pathsImages) ImagenGaleria(imagen: i, onChanged: _cambiarImagen,)
                ],
              )
          ),
        ),
        InkWell(
          child: Container(
              height: 75,
              width: MediaQuery.of(context).size.width,
              color: Colors.red,
              child: Center(child: Icon(Icons.share))
          ),
          onTap: () async {
            List<Placemark> placemark = await Geolocator().placemarkFromPosition(widget.location);
            final ciudad = placemark[0].locality;
            final calle = placemark[0].thoroughfare;
            final texto = "He cazado a un perro peligroso en " + calle + " #" + ciudad + " #CazaMayor";
            print(texto);
            File imagen = imgSeleccionada();
            await Share.file("Caza Mayor", "cazamayor.png", imagen.readAsBytesSync(), "image/png", text: texto);

            widget.detailsUser.ubiCazas.add(new Ubicacion(latitud: widget.location.latitude, longitud: widget.location.longitude));

            try {
              final databaseReference = Firestore.instance;
              databaseReference.collection('usuarios').document(
                  widget.detailsUser.uid)
                  .updateData(
                  {'ubiCazas': widget.detailsUser.ubiCazas.map((ubicacion) => ubicacion.toJson()).toList() });
            }catch(e){
              print(e.toString());
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Caza(imagen: imagen, numCazas: widget.detailsUser.ubiCazas.length),
              )
            );
          },
        ),
      ],
    );

  }

}

File imgSeleccionada(){
  for(var img in pathsImages){
    if(img["seleccionada"]){
      return File(img["ruta"]);
    }
  }
  pathsImages.elementAt(2)["seleccionada"] = true;
  return File(pathsImages.elementAt(2)["ruta"]);
}
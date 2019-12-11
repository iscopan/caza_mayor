import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  // Asegura que se ha iniciado toda la aplicacion.
  WidgetsFlutterBinding.ensureInitialized();

  // Devuelve una lista con las camaras del dispositivo.
  final cameras = await availableCameras();
  // Guarda la primera camara de la lista.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pasa la camara al widget TakePictureScreen.
        camera: firstCamera,
      ),
    ),
  );
}

// Pantalla que permite hacer una foto con la camara dada.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
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
      appBar: AppBar(title: Text('Caza Mayor')),
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

                        // Crea la lista de imagenes.
                        final pathsImages = List<String>();

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
                          pathsImages.add(path);
                          print("foto");
                          // sleep(const Duration(seconds: 1));
                        }
                        // Cuando la foto se haga, la muestra en otra pantalla.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DisplayPictureScreen(imagesPaths: pathsImages),
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
  final List<String> imagesPaths;

  const DisplayPictureScreen({Key key, this.imagesPaths}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Imagenes')),
      body: Column(
          children: [
            Expanded(
              child: Image.file(File(imagesPaths.elementAt(2)))
            ),
            Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                child: Row(
                  children: <Widget>[
                    Image.file(File(imagesPaths.elementAt(0))),
                    Image.file(File(imagesPaths.elementAt(1))),
                    Image.file(File(imagesPaths.elementAt(2))),
                    Image.file(File(imagesPaths.elementAt(3))),
                    Image.file(File(imagesPaths.elementAt(4))),
                  ],
                ),
              ),
            ),
            InkWell(
              child: Container(
                  height: 75,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.blue,
                  child: Center(child: Icon(Icons.share))
              ),
              onTap: () {
                print("Hola");
              },
            ),
          ]
      )
    );
  }
}
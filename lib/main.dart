import 'dart:async';
import 'package:camera/camera.dart';
import 'package:caza_mayor/clases.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:caza_mayor/camara.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

// Crea la lista de imagenes.
var pathsImages = [];

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
      home: MyApp(camera: firstCamera,)
    ),
  );
}

class MyApp extends StatefulWidget{

  final CameraDescription camera;

  const MyApp({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp>{
  final FirebaseAuth auth = FirebaseAuth.instance;
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  bool isFacebookLoginIn = false;

  Future<FirebaseUser> _login() async{
    FirebaseUser user;
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    switch(result.status){
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        print("Token " + accessToken.token);
        final AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: accessToken.token);
        AuthResult authResult = await auth.signInWithCredential(credential);
        user = authResult.user;
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("Login cancelado por el usuario");
        break;
      case FacebookLoginStatus.error:
        print(result.errorMessage);
        break;
    }

    return user;

  }

  Future<Usuario> _getData(FirebaseUser user) async{

    Usuario detailsUser = new Usuario(
      foto: user.photoUrl,
      nombre: user.displayName,
      uid: user.uid,
    );

    // BASE DE DATOS

    final databaseReference = Firestore.instance;

    QuerySnapshot resultado = await databaseReference.collection('usuarios').where('uid', isEqualTo: detailsUser.uid).getDocuments();
    List<DocumentSnapshot> documentos = resultado.documents;

    if(documentos.length == 0){
      // no existe el usuario en la base de datos, por lo que lo creamos
      await databaseReference.collection('usuarios').document(detailsUser.uid)
        .setData({
          'uid': detailsUser.uid,
          'foto': detailsUser.foto,
          'nombre': detailsUser.nombre,
          'ubiCazas': []
        });
    }else{
      // el usuario existe, por lo que recuperamos sus cazas
      for(int i = 0; i < documentos[0]['ubiCazas'].length; i++){
        detailsUser.ubiCazas.add(new Ubicacion(latitud: documentos[0]['ubiCazas'][i]['latitud'], longitud: documentos[0]['ubiCazas'][i]['longitud']));
      }
      
    }

    return detailsUser;

  }

  Future<bool> _logout() async{
    await auth.signOut();
    await facebookSignIn.logOut();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Caza Mayor"),
      ),
      body: Center(
        child:
        (!isFacebookLoginIn
          ? Padding(
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          child: InkWell(
              child: Container(
                height: 75,
                alignment: Alignment.center,
                child: Text(
                  "Entrar con Facebook",
                  style: TextStyle(
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: Colors.red,
              ),
              onTap: () => _login().then((user){

                if(user != null){

                  _getData(user).then((detailsUser){

                    print("Ha entrado correctamente");
                    setState(() {
                      isFacebookLoginIn = true;
                    });

                    Navigator.push(
                        context,
                        new MaterialPageRoute(builder: (context) => new TakePictureScreen(
                            camera: widget.camera,
                            detailsUser: detailsUser))
                    );

                  });

                }else{
                  print("Ha ocurrido un error");
                }
              })
          ),
        )
        : Padding(
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          child: InkWell(
              child: Container(
                height: 75,
                alignment: Alignment.center,
                child: Text(
                  "Cerrar sesión",
                  style: TextStyle(
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: Colors.red,
              ),
              onTap: () => _logout().then((response){
                if(response){
                  print("Ha salido correctamente");
                  setState(() {
                    isFacebookLoginIn = false;
                  });
                }
              })
          ),
        )
        )
      ),
    );
  }

}

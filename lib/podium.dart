import 'dart:async';

import 'package:caza_mayor/clases.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Podium extends StatefulWidget{
  final Usuario detailsUser;

  const Podium({Key key, @required this.detailsUser}) : super(key: key);

  @override
  State<Podium> createState(){
    return new PodiumState();
  }

}

class PodiumState extends State<Podium>{
  Future<void> _cargarBaseDatos;
  List<Usuario> podium = new List<Usuario>();
  int pos;

  @override
  void initState() {
    super.initState();
    _cargarBaseDatos = obtenerPodium();
  }

  Future<void> obtenerPodium() async{

    Completer<void> _creatingCompleter;

    try{

      _creatingCompleter = Completer<void>();

      List<Usuario> usuarios = new List<Usuario>();

      // conectar a la base de datos y recuperar todos los usuarios
      final databaseReference = Firestore.instance;
      QuerySnapshot resultado = await databaseReference.collection('usuarios').getDocuments();
      List<DocumentSnapshot> documentos = resultado.documents;

      for(int i = 0; i < documentos.length; i++){
        Usuario usuarioAux = new Usuario(
          uid: documentos[i]['uid'],
          foto: documentos[i]['foto'],
          nombre: documentos[i]['nombre']
        );

        for(int j = 0; j < documentos[i]['ubiCazas'].length; j++){
          usuarioAux.ubiCazas.add(new Ubicacion(latitud: documentos[i]['ubiCazas'][j]['latitud'], longitud: documentos[i]['ubiCazas'][j]['longitud']));
        }

        usuarios.add(usuarioAux);
      }

      // mock users
      usuarios.add(new Usuario(uid:"algo1", foto:"https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png", nombre:"Elettra"));
      usuarios.add(new Usuario(uid:"algo2", foto:"https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png", nombre:"Peblo"));
      usuarios.add(new Usuario(uid:"algo3", foto:"https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png", nombre:"Alberto"));

      // ordenar los usuarios segun el numero de cazas
      usuarios.sort((a, b) => b.ubiCazas.length.compareTo(a.ubiCazas.length));

      // completar el podium
      for(int i = 0; i < 3; i++){
        podium.add(usuarios.elementAt(i));
      }

      // ubicar al usuario
      pos = usuarios.indexOf(usuarios.firstWhere((user) => user.uid == widget.detailsUser.uid)) + 1;

    }catch(e){
      print("Error: " + e.toString());
    }

    _creatingCompleter.complete();
    return _creatingCompleter.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Podium"),),
      body: FutureBuilder<void>(
        future: _cargarBaseDatos,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(200),
                                  child: Container(
                                    width: 50,
                                      height: 50,
                                      child: Image(
                                          fit: BoxFit.cover,
                                          image: new NetworkImage(podium.elementAt(1).foto)
                                      )
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                ),
                                Text(podium.elementAt(1).ubiCazas.length.toString() + " cazas",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.25,
                                  height: MediaQuery.of(context).size.height * 0.4,
                                  color: Colors.redAccent,
                                  child: Text(
                                    "\n2",
                                    style: TextStyle(
                                      fontSize: 42.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(200),
                                  child: Container(
                                      width: 50,
                                      height: 50,
                                      child: Image(
                                          fit: BoxFit.cover,
                                          image: new NetworkImage(podium.elementAt(0).foto)
                                      )
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                ),
                                Text(podium.elementAt(0).ubiCazas.length.toString() + " cazas",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  height: MediaQuery.of(context).size.height * 0.6,
                                  color: Colors.red,
                                  child: Text(
                                    "\n1",
                                    style: TextStyle(
                                      fontSize: 42.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(200),
                                  child: Container(
                                      width: 50,
                                      height: 50,
                                      child: Image(
                                          fit: BoxFit.cover,
                                          image: new NetworkImage(podium.elementAt(2).foto)
                                      )
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                ),
                                Text(podium.elementAt(2).ubiCazas.length.toString() + " cazas",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  height: MediaQuery.of(context).size.height * 0.2,
                                  color: Colors.redAccent,
                                  child: Text(
                                    "\n3",
                                    style: TextStyle(
                                      fontSize: 42.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                ),
                Container(
                  color: Colors.black,
                  height: 75,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(pos.toString() + ".",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: Container(
                            width: 50,
                            height: 50,
                            child: Image(
                                fit: BoxFit.cover,
                                image: new NetworkImage(widget.detailsUser.foto)
                            )
                        ),
                      ),
                      Text(widget.detailsUser.nombre),
                      Padding(
                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        child: Container(
                          color: Colors.red,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text(widget.detailsUser.ubiCazas.length.toString() + " cazas"),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          }else{
            return Center(child: CircularProgressIndicator());
          }
        },
      )
    );
  }

}
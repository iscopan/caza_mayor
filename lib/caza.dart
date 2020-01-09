import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Caza extends StatelessWidget{

  final File imagen;
  final int numCazas;

  const Caza({Key key, @required this.imagen, @required this.numCazas}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Caza compartida"),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Text("¡Has compartido una caza!",
            style: TextStyle(
              fontSize: 23.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Expanded(
              child: Image.file(imagen)
          ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Text("¡Muchas gracias! Ya llevas ${numCazas} cazas",
            style: TextStyle(
              fontSize: 15.0,
            ),),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          InkWell(
            child: Container(
              height: 75,
              color: Colors.red,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Text("Volver",
                  style: TextStyle(
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          )
        ],
      )
    );
  }

}
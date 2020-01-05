import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Perfil extends StatelessWidget{
  final FirebaseUser detailsUser;

  const Perfil({Key key, @required this.detailsUser}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Perfil"),),
      body: ListView(
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20.0, left: 75.0, right: 75.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: Container(
                    child: Image(
                        fit: BoxFit.cover,
                        image: new NetworkImage(detailsUser.photoUrl)
                    )
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Column(
                children: <Widget>[
                  Text(
                    detailsUser.displayName.toString(),
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    "XX cazas",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top:20.0, left: 20.0, right: 20.0),
              child: InkWell(
                child: Container(
                  height: 75,
                  alignment: Alignment.center,
                  child: Text(
                    "Podium",
                    style: TextStyle(
                      fontSize: 23.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  color: Colors.blue,
                ),
                onTap: (){
                  print("Podium");
                },
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top:20.0, left: 20.0, right: 20.0),
              child: InkWell(
                child: Container(
                  height: 75,
                  alignment: Alignment.center,
                  child: Text(
                    "Mapa de cazas",
                    style: TextStyle(
                      fontSize: 23.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  color: Colors.blue,
                ),
                onTap: (){
                  print("Mapa de cazas");
                },
              ),
            ),
          ),
        ],
      )
    );
  }

}
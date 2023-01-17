import 'package:flutter/material.dart';
import 'package:photomanager/authentification.dart';
import 'package:photomanager/Home.dart';
import 'package:photomanager/login_register.dart';

class WidgetTree extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WidgetTreeState();
  }
}

class WidgetTreeState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Authentication().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Home();
          else
            return LoginPage();
        });
  }
}

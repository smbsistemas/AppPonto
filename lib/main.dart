import 'package:flutter/material.dart';
import 'package:rgti_ponto/screens/main_menu.dart';

void main() => runApp(StartApp());

class StartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "RGTI",
      home: MainMenu(),
    );
  }
}

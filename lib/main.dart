import 'package:flutter/material.dart';
import 'package:uber/rotas.dart';
import 'package:uber/telas/home.dart';

final ThemeData temaPadrao =
    ThemeData(primaryColor: Colors.blue, accentColor: Colors.blueAccent);

void main() {
  runApp(
    MaterialApp(
      title: 'Uber',
      theme: temaPadrao,
      home: Home(),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      onGenerateRoute: Rotas.gerarRotas,
    ),
  );
}

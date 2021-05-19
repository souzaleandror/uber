import 'package:flutter/material.dart';
import 'package:uber/telas/cadastro.dart';
import 'package:uber/telas/home.dart';

class Rotas {
  static Route<dynamic> gerarRotas(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Home());
        break;
      case '/cadastro':
        return MaterialPageRoute(builder: (_) => Cadastro());
        break;
      default:
        _erroRota();
        break;
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text('Tela nao encontrada'),
        ),
        body: Center(
          child: Text('Tela nao encontrada'),
        ),
      ),
    );
  }
}

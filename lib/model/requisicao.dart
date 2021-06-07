import 'package:flutter/material.dart';
import 'package:uber/model/usuario.dart';

import 'destino.dart';

class Requisicao {
  String _id;
  String _status;
  Usuario _passageiro;
  Usuario _motorista;
  Destino _destino;
  double _latitude;
  double _logintude;

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  Requisicao({
    @required String id,
    @required String status,
    @required Usuario passageiro,
    @required Usuario motorista,
    @required Destino destino,
  })  : _id = id,
        _status = status,
        _passageiro = passageiro,
        _motorista = motorista,
        _destino = destino;

  Destino get destino => _destino;

  set destino(Destino value) {
    _destino = value;
  }

  Usuario get motorista => _motorista;

  set motorista(Usuario value) {
    _motorista = value;
  }

  Usuario get passageiro => _passageiro;

  set passageiro(Usuario value) {
    _passageiro = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  factory Requisicao.fromMap(Map<String, dynamic> map) {
    return Requisicao(
      id: map['id'] as String,
      status: map['status'] as String,
      passageiro: map['passageiro'] as Usuario,
      motorista: map['motorista'] as Usuario,
      destino: map['destino'] as Destino,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> dadosPassageiros = {
      'idUsuario': this.passageiro.idUsuario,
      'nome': this.passageiro.nome,
      'email': this.passageiro.email,
      'tipoUsuario': this.passageiro.tipoUsuario,
      'latitude': this.passageiro.latitude,
      'longitude': this.passageiro.longitude,
    };

    Map<String, dynamic> dadosDestinos = {
      'rua': this.destino.rua,
      'numero': this.destino.numero,
      'bairro': this.destino.bairro,
      'cep': this.destino.cep,
      'latitude': this.destino.latitude,
      'longitude': this.destino.longitude,
    };

    // ignore: unnecessary_cast
    return {
      'id': this._id,
      'status': this._status,
      'passageiro': dadosPassageiros,
      'motorista': null,
      'destino': dadosDestinos,
    } as Map<String, dynamic>;
  }

  double get logintude => _logintude;

  set logintude(double value) {
    _logintude = value;
  }
}

class Destino {
  String _rua;
  String _bairro;
  String _cidade;
  String _numero;
  String _cep;

  double _latitude;
  double _longitude;

  String get rua => _rua;

  set rua(String value) {
    _rua = value;
  }

  String get bairro => _bairro;

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  String get cep => _cep;

  set cep(String value) {
    _cep = value;
  }

  String get numero => _numero;

  set numero(String value) {
    _numero = value;
  }

  String get cidade => _cidade;

  set cidade(String value) {
    _cidade = value;
  }

  set bairro(String value) {
    _bairro = value;
  }
}

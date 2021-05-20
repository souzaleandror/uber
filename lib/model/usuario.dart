class Usuario {
  String _idUsuario;
  String _nome;
  String _email;
  String _senha;
  String _tipoUsuario;

  Usuario({String idUsuario, String nome, String email, String tipoUsuario})
      : _idUsuario = idUsuario,
        _nome = nome,
        _email = email,
        _tipoUsuario = tipoUsuario;

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['idUsuario'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      tipoUsuario: map['tipoUsuario'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'idUsuario': this.idUsuario,
      'nome': this.nome,
      'email': this.email,
      'tipoUsuario': this.tipoUsuario,
    };

    return map;
  }

  // false = passageiro - true = motorista
  String verificaTipoUsuario(bool tipoUsuario) {
    return tipoUsuario ? "motorista" : "passageiro";
  }

  String get tipoUsuario => _tipoUsuario;

  set tipoUsuario(String value) {
    _tipoUsuario = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }
}

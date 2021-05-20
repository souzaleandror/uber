import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber/model/usuario.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerSenha = TextEditingController();
  bool loading = false;

  String _mesagemErro = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verificaUsuarioLogo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "imagens/fundo.png",
            ),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "imagens/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controllerEmail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controllerSenha,
                    obscureText: true,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: 'Senha',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: 10,
                  ),
                  child: RaisedButton(
                    child: Text(
                      'Entrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    color: Colors.blue,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: () {
                      _validarCampos();
                    },
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/cadastro');
                    },
                    child: Text(
                      'Nao tem conta? Cadastra-se',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                loading
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                  ),
                  child: Center(
                    child: Text(
                      _mesagemErro,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validarCampos() {
    String email = controllerEmail.text;
    String senha = controllerSenha.text;

    if (email.isNotEmpty && email.contains('@')) {
      if (senha.isNotEmpty && senha.length > 6) {
        Usuario usuario = Usuario();

        usuario.email = email;
        usuario.senha = senha;

        _logarUsuario(usuario);
      } else {
        setState(() {
          _mesagemErro = "Preencha a senha com mais de 6 caracteres";
        });
      }
    } else {
      setState(() {
        _mesagemErro = "Preenche o email ou email invaliado";
      });
    }
  }

  void _logarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    setState(() {
      loading = true;
    });

    auth
        .signInWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      // Navigator.pushNamedAndRemoveUntil(
      //     context, '/painel-passageiro', (_) => false);
      redirecionarPorTipoDeUsuario(firebaseUser);
    }).catchError((error) {
      setState(() {
        _mesagemErro = 'Erro ao autenticar, corrigia o email e senha';
      });
    });
  }

  void redirecionarPorTipoDeUsuario(AuthResult firebaseUser) async {
    Firestore db = Firestore.instance;

    DocumentSnapshot snapshot =
        await db.collection('usuarios').document(firebaseUser.user.uid).get();

    Usuario usuario = Usuario.fromMap(snapshot.data);

    setState(() {
      loading = false;
    });

    switch (usuario.tipoUsuario) {
      case 'passageiro':
        Navigator.pushNamedAndRemoveUntil(
            context, '/painel-passageiro', (_) => false);
        break;
      case 'motorista':
        Navigator.pushNamedAndRemoveUntil(
            context, '/painel-motorista', (_) => false);
        break;
    }
  }

  void redirecionarPorTipoDeUsuarioLogado(FirebaseUser firebaseUser) async {
    Firestore db = Firestore.instance;

    DocumentSnapshot snapshot =
        await db.collection('usuarios').document(firebaseUser.uid).get();

    Usuario usuario = Usuario.fromMap(snapshot.data);

    setState(() {
      loading = false;
    });

    switch (usuario.tipoUsuario) {
      case 'passageiro':
        Navigator.pushNamedAndRemoveUntil(
            context, '/painel-passageiro', (_) => false);
        break;
      case 'motorista':
        Navigator.pushNamedAndRemoveUntil(
            context, '/painel-motorista', (_) => false);
        break;
    }
  }

  void _verificaUsuarioLogo() async {
    setState(() {
      loading = true;
    });

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    if (usuarioLogado != null) {
      redirecionarPorTipoDeUsuarioLogado(usuarioLogado);
    }

    setState(() {
      loading = false;
    });
  }
}

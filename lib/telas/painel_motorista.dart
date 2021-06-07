import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber/util/status_requisicao.dart';
import 'package:uber/util/usuario_firebase.dart';

class PainelMotorista extends StatefulWidget {
  @override
  _PainelMotoristaState createState() => _PainelMotoristaState();
}

class _PainelMotoristaState extends State<PainelMotorista> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;
  List<String> itensMenu = ["Configuracoes", "Deslogar"];

  _escolhaMenuItem(String escolha) {
    switch (escolha) {
      case 'Deslogar':
        _deslogarUsuario();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    //_adicionarListenerRequisicoes();
    _recuperarRequisicaoAtivaMotorista();
  }

  @override
  Widget build(BuildContext context) {
    var mensagemCarregando = Center(
      child: Column(
        children: [
          Text('Carregando Requisicoes'),
          CircularProgressIndicator(),
        ],
      ),
    );

    var mensagemNaoTemDados = Center(
      child: Text(
        'Nao tem requisicao no momento',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Painel Motorista'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return mensagemCarregando;
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text('Erro ao carregar os dados');
              } else {
                QuerySnapshot querySnapshot = snapshot.data;
                if (querySnapshot.documents.length == 0) {
                  return mensagemNaoTemDados;
                } else {
                  return ListView.separated(
                    separatorBuilder: (context, indice) {
                      return Divider(
                        height: 2,
                        color: Colors.grey,
                      );
                    },
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      List<DocumentSnapshot> requisicoes =
                          querySnapshot.documents.toList();
                      DocumentSnapshot doc = requisicoes[indice];
                      String idRequisicao = doc.data['id'];
                      String nomePassageiro = doc.data['passageiro']['nome'];
                      String rua = doc.data['destino']['rua'];
                      String numero = doc.data['destino']['numero'];

                      return ListTile(
                        onTap: () async {
                          Navigator.pushNamed(
                            context,
                            '/corrida',
                            arguments: idRequisicao,
                          );
                        },
                        title: Text(
                          nomePassageiro,
                        ),
                        subtitle: Text('Destino: $rua, $numero'),
                      );
                    },
                  );
                }
              }
              break;
          }
          return mensagemCarregando;
        },
      ),
    );
  }

  void _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushNamed(context, '/');
  }

  Stream<QuerySnapshot> _adicionarListenerRequisicoes() {
    final stream = db
        .collection('requisicoes')
        .where('status', isEqualTo: StatusRequisicao.AGUARDANDO)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  void _recuperarRequisicaoAtivaMotorista() async {
    // recuperar dados do usuario logado
    FirebaseUser firebaseUser = await UsuarioFirebase.getUsuarioAtual();
    //Recupera requisicao ativa

    DocumentSnapshot doc = await db
        .collection('requisicao_ativa_motorista')
        .document(firebaseUser.uid)
        .get();

    var dadosRequisicao = doc.data;

    if (dadosRequisicao == null) {
      _adicionarListenerRequisicoes();
    } else {
      String idRequisicao = dadosRequisicao['id_requisicao'];

      Navigator.pushReplacementNamed(
        context,
        '/corrida',
        arguments: idRequisicao,
      );
    }
  }
}

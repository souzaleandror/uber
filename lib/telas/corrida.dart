import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber/model/usuario.dart';
import 'package:uber/util/status_requisicao.dart';
import 'package:uber/util/usuario_firebase.dart';

class Corrida extends StatefulWidget {
  String idRequisicao;

  Corrida(this.idRequisicao);
  @override
  _CorridaState createState() => _CorridaState();
}

class _CorridaState extends State<Corrida> {
  Map<String, dynamic> _dadosRequisicao;
  Completer<GoogleMapController> _controller = Completer();
  List<String> itensMenu = ["Configuracoes", "Deslogar"];
  CameraPosition _posicaoCamera =
      CameraPosition(target: LatLng(-23.563999, -46.653256), zoom: 16);
  Set<Marker> _marcadores = {};
  String textoBotao = 'Aceitar Corrida';
  Color corBotao = Color(0xff1ebbd8);
  Function funcaoButao;

  String _mensagemStatus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _adicionarListenerRequisicao();

    _recuperarUltimaLocalizacaoConhecida();
    _adicionarListenerLocalizacao();

    // adicionar listener para mundancas na requisicao;
    //_recuperarRequisicao();
  }

  _alterarBotaoPrincipal(String texto, Color cor, Function function) {
    setState(() {
      textoBotao = texto;
      corBotao = cor;
      funcaoButao = function;
    });
  }

  _adicionarListenerLocalizacao() {
    var geolocator = Geolocator()..forceAndroidLocationManager = true;

    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 5);

    geolocator.getPositionStream(locationOptions).listen((posicao) {
      if (posicao != null) {}
    });
  }

  _onMapCreated(GoogleMapController controller) async {
    await _controller.complete(controller);
  }

  _recuperarUltimaLocalizacaoConhecida() async {
    Position posicao = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    if (posicao != null) {
      //atualizar em tempo real
    }
  }

  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _movimentarCameraBounds(LatLngBounds latLngBounds) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 100));
  }

  _exibirMarcador(Position local, String icone, String infoWindow) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: pixelRatio), icone)
        .then((BitmapDescriptor bitmapDescriptor) {
      Marker marcador = Marker(
        markerId: MarkerId(icone),
        position: LatLng(local.latitude, local.longitude),
        infoWindow: InfoWindow(
          title: infoWindow,
        ),
        icon: bitmapDescriptor,
      );

      setState(() {
        _marcadores.add(marcador);
      });
    });
  }

  _escolhaMenuItem(String escolha) {
    switch (escolha) {
      case 'Deslogar':
        _deslogarUsuario();
        break;
    }
  }

  void _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Painel corrida - ${_mensagemStatus ?? ''}',
        ),
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
      body: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _posicaoCamera,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _marcadores,
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Padding(
                padding: Platform.isIOS
                    ? EdgeInsets.fromLTRB(20, 10, 20, 25)
                    : EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  child: RaisedButton(
                    child: Text(
                      textoBotao,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    color: corBotao,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: funcaoButao,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _recuperarRequisicao() async {
    String idRequisicao = widget.idRequisicao;
    Firestore db = Firestore.instance;
    DocumentSnapshot documentSnapshot =
        await db.collection('requisicoes').document(idRequisicao).get();
  }

  void _adicionarListenerRequisicao() async {
    Firestore db = Firestore.instance;
    String idRequisicao = _dadosRequisicao['id'];
    await db
        .collection('requisicoes')
        .document(idRequisicao)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.data != null) {
        _dadosRequisicao = snapshot.data;

        Map<String, dynamic> dados = snapshot.data;
        String status = dados['status'];

        switch (status) {
          case StatusRequisicao.AGUARDANDO:
            _statusAguardando();
            break;
          case StatusRequisicao.A_CAMINHO:
            _statusAcaminho();
            break;
          case StatusRequisicao.VIAGEM:
            break;
          case StatusRequisicao.FINALIZADA:
            break;
          case StatusRequisicao.CANCELADA:
            break;
          default:
            print('error');
            break;
        }
      }
    });
  }

  _statusAguardando() {
    _alterarBotaoPrincipal('Aceitar Corrida', Colors.blue, () {
      _aceitarCorrida();
    });

    double motoristaLatitude = _dadosRequisicao['motorista']['latitude'];
    double motoristaLongitude = _dadosRequisicao['motorista']['longitude'];

    Position position =
        Position(latitude: motoristaLatitude, longitude: motoristaLongitude);

    _exibirMarcador(position, 'imagens/motorista.png', 'Motorista');
    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(
          position.latitude,
          position.longitude,
        ),
        zoom: 16);

    _movimentarCamera(cameraPosition);
  }

  void _aceitarCorrida() async {
    Firestore db = Firestore.instance;
    String idRequisicao = _dadosRequisicao['id'];

    Usuario motorista = await UsuarioFirebase.getDadosUsuarioLogado();
    motorista.latitude = _dadosRequisicao['motorista']['latitude'];
    motorista.longitude = _dadosRequisicao['motorista']['longitude'];

    db.collection('requisicoes').document(idRequisicao).updateData({
      'motorista': motorista.toMap(),
      'status': StatusRequisicao.A_CAMINHO
    }).then((_) {
      //atualuzar requiscao ativa
      String idPassageiro = _dadosRequisicao['passageiro']['idUsuario'];
      db
          .collection('requisicao_ativa')
          .document(idPassageiro)
          .updateData({'status': StatusRequisicao.A_CAMINHO});

      //Salvar requisicao ativa para o motorista;
      String idMotorista = motorista.idUsuario;
      db
          .collection('requisicao_ativa_motorista')
          .document(idMotorista)
          .setData({
        'id_requisicao': idRequisicao,
        'id_usuario': idMotorista,
        'status': StatusRequisicao.A_CAMINHO,
      });
    });
  }

  void _statusAcaminho() {
    _mensagemStatus = "A caminho do passageiro";
    _alterarBotaoPrincipal('Iniciar Corrida', Colors.blueAccent, () {
      iniciarCorrida();
    });

    double latitudePassageiro = _dadosRequisicao['passageiro']['latitude'];
    double longitudePassageiro = _dadosRequisicao['passageiro']['longitude'];

    double latitudeMotorista = _dadosRequisicao['motorista']['latitude'];
    double longitudeMotorista = _dadosRequisicao['motorista']['longitude'];

    _exibirDoisMarcadores(LatLng(latitudePassageiro, longitudePassageiro),
        LatLng(latitudeMotorista, longitudeMotorista));

    //southwest.latiyude <= northheast.latitude: is not true

    var nLat, nLon, sLat, sLon;
    if (latitudeMotorista <= latitudePassageiro) {
      sLat = latitudeMotorista;
      nLat = latitudePassageiro;
    } else {
      sLat = latitudePassageiro;
      nLat = latitudeMotorista;
    }

    if (longitudeMotorista <= longitudePassageiro) {
      sLon = longitudeMotorista;
      nLon = longitudePassageiro;
    } else {
      sLon = longitudePassageiro;
      nLon = longitudeMotorista;
    }

    _movimentarCameraBounds(LatLngBounds(
      northeast: LatLng(nLat, nLon), // norte
      southwest: LatLng(sLat, sLon), //Sudoeste
    ));
  }

  _exibirDoisMarcadores(LatLng passageiroLatLong, LatLng motoristaLatLong) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    Set<Marker> _listaMarcadores = {};
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: pixelRatio),
            'imagens/motorista.png')
        .then((BitmapDescriptor icone) {
      Marker marcadorMotosita = Marker(
        markerId: MarkerId('Marcador-Motorista'),
        position: LatLng(motoristaLatLong.latitude, motoristaLatLong.longitude),
        infoWindow: InfoWindow(title: "Local Motorista"),
        icon: icone,
      );
      _listaMarcadores.add(marcadorMotosita);
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: pixelRatio),
            'imagens/passageiro.png')
        .then((BitmapDescriptor icone) {
      Marker marcadorPassageiro = Marker(
        markerId: MarkerId('Marcador-passageiro'),
        position:
            LatLng(passageiroLatLong.latitude, passageiroLatLong.longitude),
        infoWindow: InfoWindow(title: "Local passageiro"),
        icon: icone,
      );
      _listaMarcadores.add(marcadorPassageiro);
    });

    setState(() {
      _marcadores = _listaMarcadores;
      // _movimentarCamera(CameraPosition(
      //     target: LatLng(motoristaLatLong.latitude, motoristaLatLong.longitude),
      //     zoom: 16));
    });
  }

  void iniciarCorrida() {}
}

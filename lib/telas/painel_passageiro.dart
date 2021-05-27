import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber/model/destino.dart';

class PainelPassageiro extends StatefulWidget {
  @override
  _PainelPassageiroState createState() => _PainelPassageiroState();
}

class _PainelPassageiroState extends State<PainelPassageiro> {
  TextEditingController _controllerDestino =
      TextEditingController(text: 'Av. Paulista, 907');
  Completer<GoogleMapController> _controller = Completer();
  List<String> itensMenu = ["Configuracoes", "Deslogar"];
  CameraPosition _posicaoCamera =
      CameraPosition(target: LatLng(-23.563999, -46.653256), zoom: 16);
  Set<Marker> _marcadores = {};

  @override
  void initState() {
    super.initState();
    _recuperarUltimaLocalizacaoConhecida();
    _adicionarListenerLocalizacao();
  }

  _escolhaMenuItem(String escolha) {
    switch (escolha) {
      case 'Deslogar':
        _deslogarUsuario();
        break;
    }
  }

  _onMapCreated(GoogleMapController controller) async {
    await _controller.complete(controller);
  }

  _adicionarListenerLocalizacao() {
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 5);
    geolocator.getPositionStream(locationOptions).listen((posicao) {
      setState(() {
        _exibirMarcadorPassageiro(posicao);
        _posicaoCamera = CameraPosition(
            target: LatLng(
              posicao.latitude,
              posicao.longitude,
            ),
            zoom: 16);
        _movimentarCamera(_posicaoCamera);
      });
    });
  }

  _recuperarUltimaLocalizacaoConhecida() async {
    Position posicao = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      if (posicao != null) {
        _exibirMarcadorPassageiro(posicao);
        _posicaoCamera = CameraPosition(
            target: LatLng(
              posicao.latitude,
              posicao.longitude,
            ),
            zoom: 16);
        _movimentarCamera(_posicaoCamera);
      }
    });
  }

  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushNamed(context, '/');
  }

  _exibirMarcadorPassageiro(Position local) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: pixelRatio),
            'imagens/passageiro.png')
        .then((BitmapDescriptor icone) {
      Marker marcadorPassageiro = Marker(
        markerId: MarkerId('Marcador-passageiro'),
        position: LatLng(local.latitude, local.longitude),
        infoWindow: InfoWindow(title: "Meu local"),
        icon: icone,
      );

      setState(() {
        _marcadores.add(marcadorPassageiro);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Painel Passageiro',
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
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(
                      3,
                    ),
                    color: Colors.white,
                  ),
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        margin: EdgeInsets.only(
                          left: 10,
                        ),
                        width: 10,
                        height: 10,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.green,
                        ),
                      ),
                      hintText: "Meu Local",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        left: 10,
                        top: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 55,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: _controllerDestino,
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        margin: EdgeInsets.only(
                          left: 10,
                        ),
                        width: 10,
                        height: 10,
                        child: Icon(
                          Icons.local_taxi,
                          color: Colors.black,
                        ),
                      ),
                      hintText: "Digite o destino",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        left: 20,
                        top: 16,
                      ),
                    ),
                  ),
                ),
              ),
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
                      'Chamar Uber',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    color: Colors.blue,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: () => _chamarUber(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _chamarUber() async {
    String enderecoDestino = _controllerDestino.text;
    if (enderecoDestino.isNotEmpty) {
      List<Placemark> listaEndereco =
          await Geolocator().placemarkFromAddress(enderecoDestino);

      if (listaEndereco != null && listaEndereco.length > 0) {
        Placemark endereco = listaEndereco[0];
        Destino destino = Destino();
        destino.cidade = endereco.administrativeArea;
        destino.cep = endereco.postalCode;
        destino.bairro = endereco.subLocality;
        destino.rua = endereco.thoroughfare;
        destino.numero = endereco.subThoroughfare;

        destino.latitude = endereco.position.latitude;
        destino.longitude = endereco.position.longitude;

        String enderecoConfirmacao;
        enderecoConfirmacao = "\n Cidade: " + destino.cidade;
        enderecoConfirmacao += "\n Rua: " + destino.rua + ", " + destino.numero;
        enderecoConfirmacao += "\n Bairro: " + destino.bairro;
        enderecoConfirmacao += "\n Cep: " + destino.cep;

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirmacao do endereco'),
              content: Text(enderecoConfirmacao),
              contentPadding: EdgeInsets.all(16),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.red),
                    )),
                FlatButton(
                    onPressed: () {
                      //Salvar requisicao
                      //_salvarRequisicao()

                      Navigator.pop(context);
                    },
                    child: Text(
                      "Confirmar",
                      style: TextStyle(color: Colors.green),
                    )),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Favor Preencher endereco certo'),
            content: Text('Preencher endereco certo'),
            contentPadding: EdgeInsets.all(16),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Fechar",
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        },
      );
    }
  }
}

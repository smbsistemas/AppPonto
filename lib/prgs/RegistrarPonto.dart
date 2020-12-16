import 'dart:math' as math;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rgti_ponto/models/infra/marcacoes.dart';
import 'package:geolocation/geolocation.dart';

class RegistrarPonto extends StatefulWidget {
  @override
  _RegistrarPonto createState() => new _RegistrarPonto();
}

class _RegistrarPonto extends State<RegistrarPonto> {
  GlobalKey<FormState> _key = new GlobalKey();
  List<LocationData> _locations = [];
  List<StreamSubscription<dynamic>> _subscriptions = [];
  GeolocationResult _locationOperationalResult;
  GeolocationResult _requestPermissionResult;

  Marcacoes regPontoOff = Marcacoes();

  // Acesso - informações conexão e usuario
  List _acessoUserList = [];
  String _host = '';
  String _porta = '';
  String _nome;
  String _coligada;
  String _nomeFantasia;
  String _matricula;
  String _funcao;
  String _secao;
  String _local;

  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _acessoUserList = json.decode(data);
        _coligada = _acessoUserList[0]['coligada'];
        _nomeFantasia = _acessoUserList[0]['nomeFantasia'];
        _matricula = _acessoUserList[0]['codigo'];
        _nome = _acessoUserList[0]['nome'];
        _funcao = _acessoUserList[0]['funcao'];
        _secao = _acessoUserList[0]['secao'];
        _host = _acessoUserList[0]['host'];
        _porta = _acessoUserList[0]['porta'];
      });
    });
    // Insert dos registros off-line
    regPontoOff.getNumMarcacoes().then((_noMarcacoes) {
      if (_noMarcacoes > 0) {
        print('Numero de Registros: $_noMarcacoes');
        regPontoOff.getAllPonto().then((_listPonto) {
          for (var i = 0; i < _noMarcacoes; i++) {
            _insertRegisroPontoOffLine(
                _listPonto[i].id, _listPonto[i].dataHora);
          }
        });
      }
    });

    // Buscar Latitude e Longitude
    _onCurrentLocation();
    print('local - apos - $_local');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new SingleChildScrollView(
        child: new Container(
          margin: new EdgeInsets.all(15.0),
          child: new Form(key: _key, child: _formUI()),
        ),
      ),
    );
  }

  Widget _formUI() {
    // DateTime _dataHora = DateTime.now(); //DateFormat.yMMMd().format(_dataHora);
    DateFormat dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss");
    String _dataHora = dateFormat.format(DateTime.now());

    return new Column(
      children: <Widget>[
        // Espacamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        // Nome Fantasia
        Row(
          children: <Widget>[
            Text(
              '$_nomeFantasia',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Espacamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 10),
            ),
          ],
        ),
        // Matricula
        Row(
          children: <Widget>[
            Text(
              'Matricula:  $_matricula',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Espacamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 10),
            ),
          ],
        ),
        // Nome
        Row(
          children: <Widget>[
            Text(
              'Nome:  $_nome',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Espacamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 10),
            ),
          ],
        ),
        // Função
        Row(
          children: <Widget>[
            Text(
              'Seção:  $_secao',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Espacamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 10),
            ),
          ],
        ),
        // Seção
        Row(
          children: <Widget>[
            Text(
              'Funcao:  $_funcao',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Espacamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 10),
            ),
          ],
        ),

        // Data Inicio do serviço
        Row(
          children: <Widget>[
            Text(
              'Data / Hora:  $_dataHora',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        new RaisedButton(
          onPressed: _sendForm,
          child: new Text('Registrar o Ponto'),
        )
      ],
    );
  }

  void _sendForm() {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      _insertRegisroPonto();
      _key.currentState.save();
    } else {
      // erro de validação
      setState(() {
        //      _validate = true;
      });
    }
  }

  void _insertRegisroPonto() async {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    String _dataHora = dateFormat.format(DateTime.now());

    // Apresentar o valor para o usurio
    DateFormat dateFormat1 = DateFormat("dd-MM-yyyy HH:mm:ss");
    String _dataHora1 = dateFormat1.format(DateTime.now());

    try {
      // Registrar o Ponto
      String _pTipo = 'On';
      var dataFichaServicos = await http.get(
          'http://$_host:$_porta/PTPostRegistrarPonto/$_coligada/$_matricula/$_dataHora/$_local/$_pTipo');
      var jsonData = json.decode(dataFichaServicos.body)['RegistrarPonto'];

      List<RegistraPonto> _registraPonto = [];
      int x = 0;

      for (var u in jsonData) {
        RegistraPonto documento = RegistraPonto(x, u['CODIGO'], u['MENSAGEM']);
        _registraPonto.add(documento);
        x = x + 1;
      }
      _showAlertDialog(context, _dataHora1);
    } catch (e) {
      // Registro off line
      RegPonto p = RegPonto();
      p.coligada = _coligada;
      p.matricula = _matricula;
      p.dataHora = _dataHora;
      p.local = _local;
      regPontoOff.saveMarcacoes(p);
      _showAlertDialog(context, 'Off-line : ' + _dataHora1);
    }
  }

  void _insertRegisroPontoOffLine(int pId, String pdataHora) async {
    try {
      // Registrar o Ponto
      String wRetorno = '';
      String _pTipo = 'Off';
      var dataPonto = await http.get(
          'http://$_host:$_porta/PTPostRegistrarPonto/$_coligada/$_matricula/$pdataHora/$_local/$_pTipo');
      var jsonData = json.decode(dataPonto.body)['RegistrarPonto'];

      List<RegistraPonto> _registraPonto = [];
      int x = 0;

      for (var u in jsonData) {
        RegistraPonto documento = RegistraPonto(x, u['CODIGO'], u['MENSAGEM']);
        _registraPonto.add(documento);
        x = x + 1;
      }
      wRetorno = _registraPonto[0].rpCodigo;
      if (wRetorno == 'OK') {
        regPontoOff.deletePonto(pId);
      }
    } catch (e) {
      return null;
    }
  }

  Future<File> _getFile() async {
    try {
      print('leitura do arquivo json');
      final directory = await getApplicationDocumentsDirectory();
      return File("${directory.path}/dtPontoUser.json");
    } catch (e) {
      print('arquivo nao encontrado!');
    }
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      print('não consegui ler o arquivo - dtPontoUser');
      return null;
    }
  }

  Future _showAlertDialog(BuildContext context, _message) async {
    Alert(
      context: context,
      // type: AlertType.warning,
      title: "Ponto Registrado em: ",
      desc: "$_message",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pushReplacementNamed(context, "/"),
          width: 120,
        )
      ],
    ).show();
  }

  int _createLocation(String origin, Color color) {
    final int lastId = _locations.isNotEmpty
        ? _locations.map((location) => location.id).reduce(math.max)
        : 0;
    final int newId = lastId + 1;

    setState(() {
      _locations.insert(
        0,
        new LocationData(
          id: newId,
          result: null,
          origin: origin,
          color: color,
          createdAtTimestamp: new DateTime.now().millisecondsSinceEpoch,
          elapsedTimeSeconds: null,
        ),
      );
    });

    return newId;
    
  }

  _onCurrentLocation() {
    final int id = _createLocation('current', Colors.lightGreen);
    print('_onCurrentLocation - cheguei!');
    //final int id = 1;
    _listenToLocation(
        id, Geolocation.currentLocation(accuracy: LocationAccuracy.best));
  }

  _listenToLocation(int id, Stream<LocationResult> stream) {
    final subscription = stream.listen((result) {
      print('_listenToLocation  - cheguei! ');
      _updateLocation(id, result);
      print('_listenToLocation - location-Result: $result');
      setState(() {
        _local = result.toString();
      });
      print('peter - local : $_local');
      // leitura localização

      // fim leitura
    });
    subscription.onDone(() {
      _subscriptions.remove(subscription);
    });

    _subscriptions.add(subscription);
  }

  _updateLocation(int id, LocationResult result) {
    print('_updateLocation - cheguei!');
    final int index = _locations.indexWhere((location) => location.id == id);
    assert(index != -1);

    final LocationData location = _locations[index];

//    _localJson = _locations[index].toString();
//    print('_updateLocation - _localJson - $_localJson');

    setState(() {
      _locations[index] = new LocationData(
        id: location.id,
        result: result,
        origin: location.origin,
        color: location.color,
        createdAtTimestamp: location.createdAtTimestamp,
        elapsedTimeSeconds: (new DateTime.now().millisecondsSinceEpoch -
                location.createdAtTimestamp) ~/
            1000,
      );
    });
  }

  _checkLocationOperational() async {
    final GeolocationResult result = await Geolocation.isLocationOperational();

    if (mounted) {
      setState(() {
        _locationOperationalResult = result;
      });
    }
  }

  _requestPermission() async {
    final GeolocationResult result =
        await Geolocation.requestLocationPermission(
      permission: const LocationPermission(
        android: LocationPermissionAndroid.fine,
        ios: LocationPermissionIOS.always,
      ),
      openSettingsIfDenied: true,
    );

    if (mounted) {
      setState(() {
        _requestPermissionResult = result;
      });
    }
  }
}

class RegistraPonto {
  final int index;
  final String rpCodigo;
  final String rpMensagem;

  RegistraPonto(this.index, this.rpCodigo, this.rpMensagem);
}

class LocationData {
  LocationData({
    @required this.id,
    this.result,
    @required this.origin,
    @required this.color,
    @required this.createdAtTimestamp,
    this.elapsedTimeSeconds,
  });

  final int id;
  final LocationResult result;
  final String origin;
  final Color color;
  final int createdAtTimestamp;
  final int elapsedTimeSeconds;
}

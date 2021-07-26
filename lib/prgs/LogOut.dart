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

class LogOut extends StatefulWidget {
  @override
  _LogOut createState() => new _LogOut();
}

class _LogOut extends State<LogOut> {
  GlobalKey<FormState> _key = new GlobalKey();
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
    regPontoOff.getNumMarcacoes().then((_noMarcacoes) async {
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
          child: new Text('logout'),
        )
      ],
    );
  }

  void _sendForm() {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      _deleteFile();
      Navigator.pushReplacementNamed(context, "/");
    } else {
      // erro de validação
      setState(() {
        //      _validate = true;
      });
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

  Future<File> _deleteFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/dtPontoUser.json");
      print('apaga arquivo : $file');
      file.delete();
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
      title: "Logout: ",
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
}

class RegistraPonto {
  final int index;
  final String rpCodigo;
  final String rpMensagem;

  RegistraPonto(this.index, this.rpCodigo, this.rpMensagem);
}

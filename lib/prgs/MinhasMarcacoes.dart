import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:rgti_ponto/models/infra/marcacoes.dart';

class MinhasMarcacoes extends StatefulWidget {
  @override
  _MinhasMarcacoes createState() {
    return new _MinhasMarcacoes();
  }
}

class _MinhasMarcacoes extends State<MinhasMarcacoes> {
  List _acessoUserList = [];
  String _coligada;
  String _matricula;
  String _host = '';
  String _porta = '';
  String _local = '';
  Marcacoes regPontoOff = Marcacoes();

  @override
  void initState() {
    super.initState();
    print('minhas marcações - inicio');

    // Minha Configuração
    _readData().then((data) {
      setState(() {
        _acessoUserList = json.decode(data);
        _matricula = _acessoUserList[0]['codigo'];
        _coligada = _acessoUserList[0]['coligada'];
        _host = _acessoUserList[0]['host'];
        _porta = _acessoUserList[0]['porta'];
      });
    });
    // Insert dos registros off-line
    regPontoOff.getNumMarcacoes().then((_noMarcacoes) {
      print('peter - getNumMarcacoes: $_noMarcacoes');
      if (_noMarcacoes > 0) {
        print('Numero de Registros: $_noMarcacoes');
        regPontoOff.getAllPonto().then((_listPonto) {
          print('getAllPonto - Antes do for');
          for (var i = 0; i < _noMarcacoes; i++) {
            print('peter - _insertRegisroPonto: $i - _listPonto[i].dataHora');
            _insertRegisroPonto(
                _listPonto[i].id, _listPonto[i].dataHora, _listPonto[i].local);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder(
              future: _getMinhasMarcacoes(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Container(child: Center(child: Text("Loading...")));
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(snapshot.data[index].registro +
                              ' ' +
                              snapshot.data[index].tipo),
                          //subtitle: Text(snapshot.data[index].descricao),
                        );
                      });
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Future<List<Ponto>> _getMinhasMarcacoes() async {
    List<Ponto> _listPt = [];
    try {
      // Primeiro - Leitura das marcacoes off-line
      regPontoOff.getNumMarcacoes().then((_noMarcacoes) {
        if (_noMarcacoes > 0) {
          print('Leitura - off line : Numero de Registros: $_noMarcacoes');
          regPontoOff.getAllPonto().then((_listPontoOff) {
            for (var i = 0; i < _noMarcacoes; i++) {
              print('i: $i');
              String wdataHora = _listPontoOff[i].dataHora;
              print('registro : dataHora: $wdataHora');
              Ponto documento = Ponto(i, _listPontoOff[i].dataHora, 'Off');
              _listPt.add(documento);
            }
            // print('registro abaixo listado off-line:');
            // print(_listPt[0].registro);
            // return _listPt;
          });
        }
      });
      // fim Leitura Marcacoes Off-Line
      // Inicio - Insert Off-line
      /*  regPontoOff.getNumMarcacoes().then((_noMarcacoes) {
        print('getNumMarcacoes: $_noMarcacoes');
        if (_noMarcacoes > 0) {
          print('Insert - Numero de Registros: $_noMarcacoes');
          regPontoOff.getAllPonto().then((_listPonto) {
            print('Insert - getAllPonto - Antes do for');
            for (var i = 0; i < _noMarcacoes; i++) {
              print('peter - _insertRegisroPonto: $i - _listPonto[i].dataHora');
              try {
                _insertRegisroPonto(_listPonto[i].id, _listPonto[i].dataHora,
                    _listPonto[i].local);
              } catch (e) {}
            }
          });
        }
      }); */
      // Fim - Insert Off-line
      // Leitura Marcações
      print('Leitura - OnLine ');
      var data = await http.get(
          'http://$_host:$_porta/PTGetMinhasMarcacoes/$_coligada/$_matricula');
      var jsonData = json.decode(data.body)['MinhasMarcacoes'];

      int x = 0;
      for (var u in jsonData) {
        Ponto documento = Ponto(x, u['REGISTRO'], '');
        _listPt.add(documento);
        x = x + 1;
      }
    } catch (e) {
      print('off-line - leitura');
      // Marcacoes off-line - Show (apresentar apenas)
      // Insert dos registros off-line
      /*
      regPontoOff.getNumMarcacoes().then((_noMarcacoes) {
        if (_noMarcacoes > 0) {
          print('Numero de Registros: $_noMarcacoes');
          regPontoOff.getAllPonto().then((_listPontoOff) {
            for (var i = 0; i < _noMarcacoes; i++) {
              print('i: $i');
              String wdataHora = _listPontoOff[i].dataHora;
              print('dataHora: $wdataHora');
              Ponto documento = Ponto(i, _listPontoOff[i].dataHora, 'Off');
              _listPt.add(documento);
            }
            print('registro abaixo listado off-line:');
            print(_listPt[0].registro);
            return _listPt;
          });
        }
        
      });
      */
      // fim - show - marcacoes off-line
    }
    return _listPt;
  }

  Future<File> _getFile() async {
    try {
      print('_getfile - leitura');
      final directory = await getApplicationDocumentsDirectory();
      if (File("${directory.path}/dtPontoUser.json").existsSync()) {
        return File("${directory.path}/dtPontoUser.json");
      }
    } catch (e) {
      // print('_getfile - exception');
      return null;
    }
  }

  // Registro do Ponto Off-line
  void _insertRegisroPonto(int pId, String pdataHora, String pLocal) async {
    try {
      // Registrar o Ponto
      print('MinasMarcacoes - _insertRegisroPonto - Off-line: $pdataHora');
      String wRetorno = '';
      String _pTipo = 'Off';
      var dataPonto = await http.get(
          'http://$_host:$_porta/PTPostRegistrarPonto/$_coligada/$_matricula/$pdataHora/$pLocal/$_pTipo');
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
        print('deletou registro off-line');
        try {
          regPontoOff.deletePonto(pId);
        } catch (e) {}
      }
    } catch (e) {
      return null;
    }
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}

class Ponto {
  final int index;
  final String registro;
  final String tipo;

  Ponto(this.index, this.registro, this.tipo);
}

class RegistraPonto {
  final int index;
  final String rpCodigo;
  final String rpMensagem;

  RegistraPonto(this.index, this.rpCodigo, this.rpMensagem);
}

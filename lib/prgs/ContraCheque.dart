import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:rgti_ponto/models/infra/ContraChequePeriodo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'dart:async';

class API {
  static Future getCCP(
      String phost, String pporta, String pColigada, String pMatricula) async {
    var url = "http://$phost:$pporta/PTGetContraChequePeriodo/$pColigada";
    var dataCCP = await http.get(url);
    return dataCCP;
  }
}

class ContraCheque extends StatefulWidget {
  @override
  _ContraCheque createState() {
    return new _ContraCheque();
  }
}

class _ContraCheque extends State<ContraCheque> {
  List _acessoUserList = [];
  String _coligada;
  String _matricula;
  String _host = '';
  String _porta = '';
  String _nomeFantasia;
  String _nome;
  String _funcao;
  String _secao;
  String _itemCCPeriodo;
  bool _unico = true;

  var _ccPeriodo = new List<ContraChequePeriodo>();

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _acessoUserList = json.decode(data);
        _matricula = _acessoUserList[0]['codigo'];
        _coligada = _acessoUserList[0]['coligada'];
        _nomeFantasia = _acessoUserList[0]['nomeFantasia'];
        _matricula = _acessoUserList[0]['codigo'];
        _nome = _acessoUserList[0]['nome'];
        _funcao = _acessoUserList[0]['funcao'];
        _secao = _acessoUserList[0]['secao'];
        _host = _acessoUserList[0]['host'];
        _porta = _acessoUserList[0]['porta'];

        _getCCP();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('tamanho: $_ccPeriodo.length');
    if (_ccPeriodo.length > 0 && _unico) {
      _itemCCPeriodo = _ccPeriodo[0].ccpPeriodo;
      _unico = false;
    }

    return Scaffold(
        body: Column(children: <Widget>[
      // Espacamento
      Container(
        padding: const EdgeInsets.only(left: 10.0, top: 20.0),
      ),
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
          Container(padding: const EdgeInsets.only(left: 10.0, top: 0.0)),
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
          Container(padding: const EdgeInsets.only(left: 10.0, top: 0.0)),
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
          Container(padding: const EdgeInsets.only(left: 10.0, top: 0.0)),
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
          Container(padding: const EdgeInsets.only(left: 10.0, top: 0.0)),
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
          Container(padding: const EdgeInsets.only(left: 10.0, top: 0.0)),
          Text(
            'Funcao:  $_funcao',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),

      Container(
        padding: EdgeInsets.only(left: 10.0, top: 20.0),
      ),
      Row(
        children: <Widget>[
          Container(padding: const EdgeInsets.only(left: 10.0, top: 0.0)),
          Text(
            'Periodo :  ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DropdownButtonHideUnderline(
            child: new DropdownButton<String>(
              hint: new Text("Selecione um Periodo: "),
              isDense: true,
              items: _ccPeriodo.map((ContraChequePeriodo map) {
                return new DropdownMenuItem<String>(
                  value: map.ccpPeriodo,
                  child: new Text(map.ccpPeriodo,
                      style: new TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      )),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  _itemCCPeriodo = newValue;
                });
              },
              value: _itemCCPeriodo,
            ),
          ),
        ],
      ),
      Container(
        padding: EdgeInsets.only(left: 10.0, top: 5.0),
      ),
      Row(
        children: <Widget>[
          Container(padding: const EdgeInsets.only(left: 10.0, top: 0.0)),
          Container(
            width: 200.0,
            alignment: Alignment.topCenter,
            child: Text('Descrição',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
          ),
          Container(
            width: 70.0,
            alignment: Alignment.bottomLeft,
            child: Text('Provento',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
          ),
          Container(
            width: 70.0,
            alignment: Alignment.bottomLeft,
            child: Text('Desconto',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
          ),
        ],
      ),
      Container(
        padding: EdgeInsets.only(left: 10.0, top: 5.0),
      ),
      Expanded(
        child: FutureBuilder(
          future: _getContraCheque(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(child: Center(child: Text("Loading...")));
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 200.0,
                            alignment: Alignment.bottomLeft,
                            child: Column(children: <Widget>[
                              Text(
                                  snapshot.data[index].codEvento +
                                      ' - ' +
                                      snapshot.data[index].evento,
                                  style: new TextStyle(fontSize: 14.0))
                            ]),
                          ),
                          Container(
                              width: 70.0,
                              alignment: Alignment.bottomRight,
                              child: Text(snapshot.data[index].provento,
                                  style: new TextStyle(fontSize: 14.0))),
                          Container(
                              width: 70.0,
                              alignment: Alignment.bottomRight,
                              child: Text(snapshot.data[index].desconto,
                                  style: new TextStyle(fontSize: 14.0))),
                        ],
                      ),
                      Container(
                        child: Divider(),
                      ),
                    ]);
                  });
            }
          },
        ),
      )
/*      Expanded(
        child: FutureBuilder(
          future: _getContraCheque(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(child: Center(child: Text("Loading...")));
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                          snapshot.data[index].codEvento +
                              ' - ' +
                              snapshot.data[index].evento,
                          style: new TextStyle(fontSize: 14.0)),
                      subtitle: snapshot.data[index].evento !=
                                  'LIQUIDO A RECEBER' &&
                              snapshot.data[index].evento != 'FGTS'
                          ? Text(
                              'Provento: ' +
                                  snapshot.data[index].provento +
                                  ' - ' +
                                  'Desconto: ' +
                                  snapshot.data[index].desconto,
                              style: new TextStyle(fontSize: 12.0))
                          : snapshot.data[index].evento != 'FGTS'
                              ? Text(
                                  'Provento: ' + snapshot.data[index].provento,
                                  style: new TextStyle(fontSize: 12.0))
                              : Text(
                                  'FGTS do mês: ' +
                                      snapshot.data[index].provento,
                                  style: new TextStyle(fontSize: 12.0)),
                    );
                  });
            }
          },
        ),
      ) */
    ]));
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/dtPontoUser.json");
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  _getCCP() async {
    API.getCCP(_host, _porta, _coligada, _matricula).then((response) {
      setState(() {
        Iterable list = json.decode(response.body)['ContraChequePeriodo'];
        _ccPeriodo =
            list.map((model) => ContraChequePeriodo.fromJson(model)).toList();
      });
    });
  }

  Future<List<CCheque>> _getContraCheque() async {
    var url =
        "http://$_host:$_porta/PTGetContraCheque/$_coligada/$_matricula/$_itemCCPeriodo";
    var data = await http.get(url);
    var jsonData = json.decode(data.body)['ContraCheque'];

    List<CCheque> _listContraCheque = [];
    int x = 0;
    for (var u in jsonData) {
      CCheque documento = CCheque(x, u['CODEVENTO'], u['EVENTO'],
          u['REFERENCIA'], u['PROVENTO'], u['DESCONTO']);
      _listContraCheque.add(documento);
      x = x + 1;
    }
    return _listContraCheque;
  }
}

class CCheque {
  final int index;
  final String codEvento;
  final String evento;
  final String referencia;
  final String provento;
  final String desconto;

  CCheque(this.index, this.codEvento, this.evento, this.referencia,
      this.provento, this.desconto);
}

class CCPeriodo {
  final int index;
  final String ano;
  final String mes;
  final String nroPeriodo;
  final String periodo;

  CCPeriodo(this.index, this.ano, this.mes, this.nroPeriodo, this.periodo);
}

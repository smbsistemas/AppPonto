import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:rgti_ponto/models/infra/ContraChequePeriodo.dart';

class API {
  static Future getCCP(
      String phost, String pporta, String pColigada, String pMatricula) async {
    var url = "http://$phost:$pporta/PTGetContraChequePeriodo/$pColigada";
    var dataCCP = await http.get(url);
    return dataCCP;
  }
}

class EspelhoPonto extends StatefulWidget {
  @override
  _EspelhoPonto createState() {
    return new _EspelhoPonto();
  }
}

class _EspelhoPonto extends State<EspelhoPonto> {
  List _acessoUserList = [];
  String _coligada;
  String _matricula;
  String _host = '';
  String _porta = '';
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
        _host = _acessoUserList[0]['host'];
        _porta = _acessoUserList[0]['porta'];

        _getCCP();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ccPeriodo.length > 0 && _unico) {
      _itemCCPeriodo = _ccPeriodo[0].ccpPeriodo;
      _unico = false;
    }
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 6),
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
                  //print('itemCCU_value: $_itemCCU');
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 8),
          ),
          Row(
            children: <Widget>[
              Container(padding: const EdgeInsets.only(left: 10.0, top: 0.0)),
              Container(
                width: 80.0,
                child: Column(children: <Widget>[
                  Text('Data',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0)),
                  Text('HT',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0))
                ]),
              ),
              Container(
                width: 60.0,
                child: Column(children: <Widget>[
                  Text('Entrada',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0)),
                  Text('HE',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0))
                ]),
              ),
              Container(
                width: 70.0,
                child: Column(children: <Widget>[
                  Text('Saida',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0)),
                  Text('Atraso',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0))
                ]),
              ),
              Container(
                width: 70.0,
                child: Column(children: <Widget>[
                  Text('Entrada',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0)),
                  Text('Falta',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0))
                ]),
              ),
              Container(
                width: 70.0,
                child: Column(children: <Widget>[
                  Text('Saída',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0)),
                  Text('Abono',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0))
                ]),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: _getEspelhoPonto(),
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
                                width: 80.0,
                                child: Column(children: <Widget>[
                                  Text(snapshot.data[index].dataBatida),
                                  Text(snapshot.data[index].htrab)
                                ]),
                              ),
                              Container(
                                width: 60.0,
                                child: Column(children: <Widget>[
                                  Text(snapshot.data[index].ent1 != ''
                                      ? snapshot.data[index].ent1
                                      : '-'),
                                  Text(snapshot.data[index].he_exec)
                                ]),
                              ),
                              Container(
                                width: 70.0,
                                child: Column(children: <Widget>[
                                  Text(snapshot.data[index].alm_sai != ''
                                      ? snapshot.data[index].alm_sai
                                      : '-'),
                                  Text(snapshot.data[index].atraso)
                                ]),
                              ),
                              Container(
                                width: 70.0,
                                child: Column(children: <Widget>[
                                  Text(snapshot.data[index].alm_ent != ''
                                      ? snapshot.data[index].alm_ent
                                      : '-'),
                                  Text(snapshot.data[index].falta)
                                ]),
                              ),
                              Container(
                                width: 70.0,
                                child: Column(children: <Widget>[
                                  Text(snapshot.data[index].sai1 != ''
                                      ? snapshot.data[index].sai1
                                      : '-'),
                                  Text(snapshot.data[index].abono)
                                ]),
                              ),
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
        ],
      ),
    );
  }

  Future<List<EspPonto>> _getEspelhoPonto() async {
    var data = await http.get(
        'http://$_host:$_porta/PTGetEspelhoPonto/$_coligada/$_matricula/$_itemCCPeriodo');
    var jsonData = json.decode(data.body)['EspelhoPonto'];

    List<EspPonto> _listPonto = [];
    int x = 0;

    for (var u in jsonData) {
      EspPonto documento = EspPonto(
          x,
          u['DT_BATIDA'],
          u['ENT1'],
          u['ALM_SAI'],
          u['ALM_ENT'],
          u['SAI1'],
          u['HTRAB'],
          u['HE_EXEC'],
          u['ATRASO'],
          u['FALTA'],
          u['ADICIONAL'],
          u['ABONO']);

      _listPonto.add(documento);
      x = x + 1;
    }
    return _listPonto;
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
}

class EspPonto {
  final int index;
  final String dataBatida;
  final String ent1;
  final String alm_sai;
  final String alm_ent;
  final String sai1;
  final String htrab;
  final String he_exec;
  final String atraso;
  final String falta;
  final String adicional;
  final String abono;

  EspPonto(
      this.index,
      this.dataBatida,
      this.ent1,
      this.alm_sai,
      this.alm_ent,
      this.sai1,
      this.htrab,
      this.he_exec,
      this.atraso,
      this.falta,
      this.adicional,
      this.abono);
}

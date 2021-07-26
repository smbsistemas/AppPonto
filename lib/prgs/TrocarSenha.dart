import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rgti_ponto/prgs/TrocarSenha.dart';
import 'package:path_provider/path_provider.dart';

class TrocarSenha extends StatefulWidget {
  @override
  _TrocarSenha createState() => _TrocarSenha();
}

class _TrocarSenha extends State<TrocarSenha> {
  final _formKey = GlobalKey<FormState>();
  List _acessoUserList = [];
  String _coligada;
  String _matricula;
  String _host = '';
  String _porta = '';
  String _local = '';

  String _passwordAtual;
  String _passwordNova;
  String _passwordConfirme;

  @override
  void initState() {
    super.initState();
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
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: EdgeInsets.all(20.0),
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  SizedBox(height: 20.0),
                  SizedBox(height: 20.0),
                  TextFormField(
                      onSaved: (value) => _passwordAtual = value,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Senha Atual")),
                  TextFormField(
                      onSaved: (value) => _passwordNova = value,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Nova Senha")),
                  TextFormField(
                      onSaved: (value) => _passwordConfirme = value,
                      obscureText: true,
                      decoration:
                          InputDecoration(labelText: "Confirme a Senha")),
                  SizedBox(height: 20.0),
                  RaisedButton(
                      child: Text("Enviar"),
                      onPressed: () async {
                        // save the fields..
                        final form = _formKey.currentState;
                        form.save();

                        if (form.validate()) {
                          var result = await _validaAcesso();
                          if (result != null) {
                            Navigator.pushReplacementNamed(context, "/");
                          } else {
                            return _buildShowErrorDialog(
                                context, "Senha de confirmação invalida!");
                          }
                        }
                      }),
                ]))));
  }

  _validaAcesso() async {
    if (_passwordNova == _passwordConfirme) {
      var dataValidaAcesso = await http.get(
          'http://$_host:$_porta/PTTrocaSenha/$_coligada/$_matricula/$_passwordAtual/$_passwordNova');
      var jsonData = json.decode(dataValidaAcesso.body)['TrocaSenha'];

      List<TrocaSenha> _trocaSenha = [];
      int x = 0;

      for (var u in jsonData) {
        TrocaSenha documento = TrocaSenha(x, u['CODIGO'], u['MENSAGEM']);
        _trocaSenha.add(documento);
        x = x + 1;
      }
      final String wRetorno = _trocaSenha[0].pCodigo;
      if (wRetorno == 'SUCESSO') {
        _buildShowErrorDialog(context, "Senha alterada com!");
        return wRetorno;
      }
    } else {
      return null;
    }
  }

  Future _buildShowErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('Ponto Eletrônico:'),
          content: Text(_message),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<File> _getFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return File("${directory.path}/dtPontoUser.json");
    } catch (e) {
      return null;
    }
  }

  Future<File> _saveData() async {
    try {
      String data = json.encode(_acessoUserList);
      final file = await _getFile();
      return file.writeAsString(data);
    } catch (e) {
      return null;
    }
  }
}

class TrocaSenha {
  final int index;
  final String pCodigo;
  final String pMensagem;

  TrocaSenha(this.index, this.pCodigo, this.pMensagem);
}

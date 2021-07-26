import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _porta = '';
  String _host = '';

  String _password;
  String _user;
  String _nome;
  String _coligada;
  String _nomeFantasia;
  String _matricula;
  String _cpf;
  String _apelido;
  String _codFuncao;
  String _funcao;
  String _codSecao;
  String _secao;
  String _mensagem;

  List _acessoUserList = [];

  @override
  void initState() {
    super.initState();
// Conexao Terraço
//    _porta = '8180';
//    _host = 'remoto.terraco.local';
//    Conexao RGTI - Teste
    _porta = '8080';
//    _host = '192.168.0.7'; // LocalHost - Rogerio Peter
    _host = 'srvrgti.ddns.net';
//    Conexao RGTI - Produçãp
//    _porta = '8080';
//    _host = 'srvrgti.ddns.net';
//    _host = '100.68.70.101';
    _readData().then((data) {
      setState(() {
        _acessoUserList = json.decode(data);
        final String _login = _acessoUserList[1]['login'];
        print('LoginPage - login: $_login');
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
                  Text(
                    'Ponto Eletrônico',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                      onSaved: (value) => _user = value,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(labelText: "Login")),
                  TextFormField(
                      onSaved: (value) => _password = value,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Senha")),
                  SizedBox(height: 20.0),
                  RaisedButton(
                      child: Text("Enviar"),
                      onPressed: () async {
                        // save the fields..
                        final form = _formKey.currentState;
                        form.save();

                        // Validate will return true if is valid, or false if invalid.
                        if (form.validate()) {
                          var result = await _validaAcesso();
                          if (result != null) {
                            Navigator.pushReplacementNamed(context, "/");
                          } else {
                            return _buildShowErrorDialog(
                                context, "Acesso negado!");
                          }
                        }
                      }),
/*                  SizedBox(height: 120.0),
                  new Row(children: <Widget>[
                    // Espacamento
                    Container(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TrocarSenha()),
                            );
                          },
                          child: Text('Trocar a senha'),
                        ))
                  ]), */
                ]))));
  }

  _validaAcesso() async {
    var dataValidaAcesso = await http
        .get('http://$_host:$_porta/PTGetValidaUser/$_user/$_password');
    var jsonData = json.decode(dataValidaAcesso.body)['CTRLAcesso'];

    List<Login> _loginPage = [];
    int x = 0;
    for (var u in jsonData) {
      Login documento = Login(
          x,
          u['CODCOLIGADA'],
          u['NOMEFANTASIA'],
          u['CHAPA'],
          u['NOME'],
          u['APELIDO'],
          u['CODSITUACAO'],
          u['CPF'],
          u['CODFUNCAO'],
          u['FUNCAO'],
          u['CODSECAO'],
          u['SECAO'],
          u['MENSAGEM']);
      _loginPage.add(documento);
      x = x + 1;
    }
    _coligada = _loginPage[0].lpCodColigada;
    _nomeFantasia = _loginPage[0].lpNomeFantasia;
    _matricula = _loginPage[0].lpMatricula;
    _nome = _loginPage[0].lpNome;
    _cpf = _loginPage[0].lpCPF;
    _apelido = _loginPage[0].lpApelido;
    _codFuncao = _loginPage[0].lpCodFuncao;
    _funcao = _loginPage[0].lpFuncao;
    _codSecao = _loginPage[0].lpCodSecao;
    _secao = _loginPage[0].lpSecao;
    _mensagem = _loginPage[0].lpMensagem;

    if (_mensagem == 'LIBERADO') {
      _addUser();
      return ('LIBERADO');
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

  void _addUser() {
    setState(() {
      print('_addUser : $_user matricula: $_matricula');
      Map<String, dynamic> newUser = Map();
      newUser["login"] = _user;
      newUser["senha"] = _password;
      newUser["codigo"] = _matricula;
      newUser["nome"] = _nome;
      newUser['coligada'] = _coligada;
      newUser['cpf'] = _cpf;
      newUser['nomeFantasia'] = _nomeFantasia;
      newUser['apelido'] = _apelido;
      newUser['codfuncao'] = _codFuncao;
      newUser['funcao'] = _funcao;
      newUser['codsecao'] = _codSecao;
      newUser['secao'] = _secao;

      newUser["host"] = _host;
      newUser["porta"] = _porta;
      _acessoUserList.add(newUser);
      _saveData();
    });
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

class Login {
  final int index;
  final String lpCodColigada;
  final String lpNomeFantasia;
  final String lpMatricula;
  final String lpNome;
  final String lpApelido;
  final String lpCodSituacao;
  final String lpCPF;
  final String lpCodFuncao;
  final String lpFuncao;
  final String lpCodSecao;
  final String lpSecao;
  final String lpMensagem;
  Login(
      this.index,
      this.lpCodColigada,
      this.lpNomeFantasia,
      this.lpMatricula,
      this.lpNome,
      this.lpApelido,
      this.lpCodSituacao,
      this.lpCPF,
      this.lpCodFuncao,
      this.lpFuncao,
      this.lpCodSecao,
      this.lpSecao,
      this.lpMensagem);
}

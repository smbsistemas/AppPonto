import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import 'package:rgti_ponto/models/infra/menu_item.dart';
import 'package:rgti_ponto/prgs/ContraCheque.dart';
import 'package:rgti_ponto/prgs/EspelhoPonto.dart';
import 'package:rgti_ponto/prgs/MinhasMarcacoes.dart';
import 'package:rgti_ponto/prgs/RegistrarPonto.dart';
import 'package:rgti_ponto/prgs/Sobre.dart';
import 'package:rgti_ponto/prgs/TrocarSenha.dart';
import 'package:rgti_ponto/prgs/loginPage.dart';
import 'package:rgti_ponto/models/infra/marcacoes.dart';
import 'package:rgti_ponto/prgs/MinhasMarcacoesOff.dart';
import 'package:rgti_ponto/prgs/TrocarSenha.dart';
import 'package:rgti_ponto/prgs/LogOut.dart';

class MainMenu extends StatefulWidget {
  @override
  MainMenuState createState() {
    return MainMenuState();
  }
}

class MainMenuState extends State<MainMenu> {
  Widget _appBarTitle;
  Color _appBarBackgroundColor;
  MenuItem _selectedMenuItem;
  List<MenuItem> _menuItems;
  List<Widget> _menuOptionWidgets = [];
  List _acessoUserList = [];
  Marcacoes regPontoOff = Marcacoes();

  String _login = '';
  String _password = '';
  String _nome = '';
  String _codigo = '';
  String _host = '';
  String _porta = '';
  String _coligada;
  String _matricula;

  bool _temLogin = true;

  @override
  initState() {
    super.initState();

    _menuItems = createMenuItems();
    _selectedMenuItem = _menuItems.first;
    _appBarTitle = new Text(_menuItems.first.title);
    _appBarBackgroundColor = _menuItems.first.color;

    try {
      _readData().then((data) {
        setState(() {
          _acessoUserList = json.decode(data);
          _login = _acessoUserList[0]['login'];
          _password = _acessoUserList[0]['senha'];
          _nome = _acessoUserList[0]['nome'];
          _codigo = _acessoUserList[0]['codigo'];
          _host = _acessoUserList[0]['host'];
          _porta = _acessoUserList[0]['porta'];
          _coligada = _acessoUserList[0]['coligada'];
          _matricula = _acessoUserList[0]['codigo'];
          _temLogin = true;

          if (_nome == null) {
            _temLogin = false;
          }

          print('Main - _password: $_password');
          print('Main - _nome: $_nome');
          print('Main - _codigo: $_codigo ');
          print('Main - _host: $_host');
          print('Main - _porta: $_porta');
          print('Main - _login: $_login');
        });
      });
    } catch (e) {
      _temLogin = false;
    }

    if (_login.length == 0) {
      _temLogin = false;
    }
  }

  Future<File> _getFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _temLogin = true;
      return File("${directory.path}/dtPontoUser.json");
    } catch (e) {
      _temLogin = false;
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

  _getMenuItemWidget(MenuItem menuItem) {
    return menuItem.func();
  }

  _onSelectItem(MenuItem menuItem) {
    setState(() {
      _selectedMenuItem = menuItem;
      _appBarTitle = new Text(menuItem.title);
      _appBarBackgroundColor = menuItem.color;
    });
    Navigator.of(context).pop(); // close side menu
  }

  @override
  Widget build(BuildContext context) {
    _menuOptionWidgets = [];
    print('Main - inicio');
    for (var menuItem in _menuItems) {
      _menuOptionWidgets.add(new Container(
          decoration: new BoxDecoration(
              color: menuItem == _selectedMenuItem
                  ? Colors.grey[200]
                  : Colors.white),
          child: new ListTile(
              leading: new Image.asset(menuItem.icon),
              onTap: () => _onSelectItem(menuItem),
              title: Text(
                menuItem.title,
                style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontWeight: menuItem == _selectedMenuItem
                        ? FontWeight.bold
                        : FontWeight.w300),
              ))));

      _menuOptionWidgets.add(
        new SizedBox(
          child: new Center(
            child: new Container(
              margin: new EdgeInsetsDirectional.only(start: 10.0, end: 10.0),
              height: 0.3,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: _appBarTitle,
        backgroundColor: _appBarBackgroundColor,
        centerTitle: true,
      ),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            new Container(
              width: 260,
              height: 260,
              child: Image.asset(
                'images/logorgti.jpg',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            new Container(
                child: new ListTile(
                    //  leading: new Image.asset('assets/images/lion.png'),
                    title: Text(
                  "Ponto Eletrônico",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black),
                )),
                margin: new EdgeInsetsDirectional.only(top: 17.0),
                color: Colors.white,
                constraints: BoxConstraints(maxHeight: 90.0, minHeight: 90.0)),
            new SizedBox(
              child: new Center(
                child: new Container(
                  margin: new EdgeInsetsDirectional.only(start: 7.0, end: 7.0),
                  height: 0.6,
                  color: Colors.black,
                ),
              ),
            ),
            new Container(
              color: Colors.white,
              child: new Column(children: _menuOptionWidgets),
            ),
          ],
        ),
      ),
      body: _getMenuItemWidget(_selectedMenuItem),
    );
  }

  List<MenuItem> createMenuItems() {
    final menuItems = [
      new MenuItem(
          _temLogin == true ? "Minhas marcações" : "Login",
          '',
          Colors.red,
          () => (_temLogin == true ? MinhasMarcacoes() : LoginPage())),
      new MenuItem("Minhas marcações - Off Line", '', Colors.red,
          () => MinhasMarcacoesOff()),
      new MenuItem(
          "Registrar Ponto", '', Colors.red, () => new RegistrarPonto()),
      new MenuItem(
          "Espelho de Ponto", '', Colors.red, () => new EspelhoPonto()),
      new MenuItem("Contracheque", '', Colors.red, () => new ContraCheque()),
      new MenuItem("Trocar Senha", '', Colors.red, () => new TrocarSenha()),
      new MenuItem(_temLogin == true ? "LogOut" : "Login", '', Colors.red,
          () => _temLogin == true ? LogOut() : LoginPage()),
      new MenuItem("Sobre", '', Colors.red, () => new Sobre()),
    ];
    return menuItems;
  }
}

class RegistraPonto {
  final int index;
  final String rpCodigo;
  final String rpMensagem;

  RegistraPonto(this.index, this.rpCodigo, this.rpMensagem);
}

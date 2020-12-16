import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tabelaMarcacoes = "tabelaMarcacoes";
final String idCL = "idCL";
final String coligadaCL = "coligadaCL";
final String matriculaCL = "matriculaCL";
final String dataHoraCL = "dataHoraCL";
final String localCL = 'localCL';

class Marcacoes {
  static final Marcacoes _instance = Marcacoes.internal();

  factory Marcacoes() => _instance;

  Marcacoes.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null)
      return _db;
    else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "marcacoes.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $tabelaMarcacoes($idCL INTEGER PRIMARY KEY, $coligadaCL TEXT, $matriculaCL TEXT, $dataHoraCL TEXT, $localCL TEXT)");
    });
  }

  Future saveMarcacoes(RegPonto ponto) async {
    Database dbMarcacoes = await db;
    ponto.id = await dbMarcacoes.insert(tabelaMarcacoes, ponto.toMap());
    return ponto;
  }

  Future<List> getAllPonto() async {
    Database dbMarcacoes = await db;
    List listMap = await dbMarcacoes.rawQuery("SELECT * FROM $tabelaMarcacoes");
    List<RegPonto> listPonto = List();
    for (Map m in listMap) {
      listPonto.add(RegPonto.fromMap(m));
    }
    return listPonto;
  }

  Future<int> deletePonto(int id) async {
    Database dbMarcacoes = await db;
    await dbMarcacoes
        .delete(tabelaMarcacoes, where: "$idCL = ?", whereArgs: [id]);
  }

  Future<int> getNumMarcacoes() async {
    Database dbMarcacoes = await db;
    return Sqflite.firstIntValue(
        await dbMarcacoes.rawQuery("SELECT COUNT(*) FROM $tabelaMarcacoes"));
  }

  close() async {
    Database dbMarcacoes = await db;
    dbMarcacoes.close();
  }
}

class RegPonto {
  int id;
  String coligada;
  String matricula;
  String dataHora;
  String local;

  RegPonto();

  RegPonto.fromMap(Map map) {
    id = map[idCL];
    coligada = map[coligadaCL];
    matricula = map[matriculaCL];
    dataHora = map[dataHoraCL];
    local = map[localCL];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      coligadaCL: coligada,
      matriculaCL: matricula,
      dataHoraCL: dataHora,
      localCL: local
    };
    if (id != null) {
      map[idCL] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "RegPonto(id: $id, coligada: $coligada, matricula: $matricula, dataHora: $dataHora, local: $local)";
  }
}

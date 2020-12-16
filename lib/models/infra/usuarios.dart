class Usuarios {
  String codigo;
  String nome;

  Usuarios(String codigo, String nome) {
    this.codigo = codigo;
    this.nome = nome;
  }

  Usuarios.fromJson(Map json)
      : codigo = json['CODIGO'],
        nome = json['NOME'];

  Map toJson() {
    return {'CODIGO': codigo, 'NOME': nome};
  }
}

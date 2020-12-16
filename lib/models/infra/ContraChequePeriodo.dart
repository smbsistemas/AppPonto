class ContraChequePeriodo {
  String ccpAno;
  String ccpMes;
  String ccpNroPeriodo;
  String ccpPeriodo;

  ContraChequePeriodo(
      String ccpAno, String ccpMes, String ccpNroPeriodo, String ccpPeriodo) {
    this.ccpAno = ccpAno;
    this.ccpMes = ccpMes;
    this.ccpNroPeriodo = ccpNroPeriodo;
    this.ccpPeriodo = ccpPeriodo;
  }

  ContraChequePeriodo.fromJson(Map json)
      : ccpAno = json['ANOCOMP'],
        ccpMes = json['MESCOMP'],
        ccpNroPeriodo = json['NROPERIODO'],
        ccpPeriodo = json['PERIODO'];

  Map toJson() {
    return {
      'ANOCOMP': ccpAno,
      'MESCOMP': ccpMes,
      'NROPERIODO': ccpNroPeriodo,
      'PERIODO': ccpPeriodo
    };
  }
}

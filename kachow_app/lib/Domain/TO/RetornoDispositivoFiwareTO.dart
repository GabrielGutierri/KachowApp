class RetornoDispositivoFiwareTO {
  String id;
  String type;

  RetornoDispositivoFiwareTO({
    required this.id,
    required this.type,
  });

  factory RetornoDispositivoFiwareTO.fromJson(Map<String, dynamic> json) {
    return RetornoDispositivoFiwareTO(
      id: json['id'],
      type: json['type'],
    );
  }
}

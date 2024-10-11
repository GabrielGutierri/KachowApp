class RetornoErroFiwareTO {
  String error;
  String description;

  RetornoErroFiwareTO({required this.error, required this.description});

  factory RetornoErroFiwareTO.fromJson(Map<String, dynamic> json) {
    return RetornoErroFiwareTO(
      error: json['error'],
      description: json['description'],
    );
  }
}

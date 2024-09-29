import 'package:flutter/material.dart';
import 'package:kachow_app/IoC/DependencyFactory.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Identificação de veículo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DependencyFactory.createIdentificacaoCarroPage(),
    );
  }
}

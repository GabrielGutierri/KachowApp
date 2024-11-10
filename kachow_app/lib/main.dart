import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kachow_app/Domain/entities/DadoCarro.dart';
import 'package:kachow_app/IoC/DependencyFactory.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DadoCarroAdapter());

  await Hive.openBox<DadoCarro>('tbFilaDados');

  runApp(const MyApp());
  await checkPermissions();
}

Future<void> checkPermissions() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  await Permission.bluetoothScan.request();
  await Permission.bluetoothConnect.request();
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

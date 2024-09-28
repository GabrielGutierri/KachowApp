import 'package:kachow_app/Business/Controllers/BluetoothController.dart';
import 'package:kachow_app/Business/Controllers/IdentificacaoCarroController.dart';
import 'package:kachow_app/Business/Services/FiwareService.dart';
import 'package:kachow_app/Business/Services/GeolocationService.dart';
import 'package:kachow_app/Business/Services/MQTTService.dart';
import 'package:kachow_app/Business/Services/OBDService.dart';
import 'package:kachow_app/Presentation/Pages/BluetoothPage.dart';
import 'package:kachow_app/Presentation/Pages/IdentificacaoCarroPage.dart';

class DependencyFactory {
  static BluetoothPage createBluetoothPage() {
    final mqttService = Mqttservice();
    final geolocationService = GeolocationService();
    final obdService = Obdservice(mqttService, geolocationService);
    final bluetoothController = BluetoothController(obdService);
    return BluetoothPage(bluetoothController);
  }

  static IdentificacaoCarroPage createIdentificacaoCarroPage() {
    final fiwareservice = Fiwareservice();
    final identificacaoCarroController =
        IdentificacaoCarroController(fiwareservice);
    return IdentificacaoCarroPage(identificacaoCarroController);
  }
}

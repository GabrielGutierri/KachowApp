import 'package:kachow_app/Business/Controllers/BluetoothController.dart';
import 'package:kachow_app/Business/Controllers/IdentificacaoCarroController.dart';
import 'package:kachow_app/Business/Services/FiwareService.dart';
import 'package:kachow_app/Business/Services/OBDService.dart';
import 'package:kachow_app/Business/Services/RequestFIWAREService.dart';
import 'package:kachow_app/Presentation/Pages/BluetoothPage.dart';
import 'package:kachow_app/Presentation/Pages/IdentificacaoCarroPage.dart';

class DependencyFactory {
  static BluetoothPage createBluetoothPage() {
    final obdService = Obdservice();
    final bluetoothController = BluetoothController(obdService);
    return BluetoothPage(bluetoothController);
  }

  static IdentificacaoCarroPage createIdentificacaoCarroPage() {
    final fiwareservice = Fiwareservice();
    final requestService = RequestFIWAREService();
    final identificacaoCarroController =
        IdentificacaoCarroController(fiwareservice, requestService);
    return IdentificacaoCarroPage(identificacaoCarroController);
  }
}

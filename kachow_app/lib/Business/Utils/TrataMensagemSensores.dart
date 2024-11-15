import 'dart:math';

class TrataMensagemSensores {
  // Método para obter o valor do giroscópio e devolver os ângulos de Roll, Pitch e Yaw
  static double CalculaGiroscopioPitch(aceleracaoY, aceleracaoX, aceleracaoZ) {
    double pitch = atan2(aceleracaoY,
            sqrt(aceleracaoX * aceleracaoX + aceleracaoZ * aceleracaoZ)) *
        (180 / pi);
    return pitch;
  }

  static double CalculaGiroscopioRow(aceleracaoX, aceleracaoY, aceleracaoZ) {
    double row = atan2(aceleracaoX,
            sqrt(aceleracaoY * aceleracaoY + aceleracaoZ * aceleracaoZ)) *
        (180 / pi);
    return row;
  }

  static double CalculaGiroscopioYaw(giroscopioZ) {
    double yaw = giroscopioZ * (180 / pi);
    return yaw;
  }
}

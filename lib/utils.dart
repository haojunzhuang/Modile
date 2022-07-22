import 'package:modbus/modbus.dart' as modbus;
import 'package:modbus/modbus.dart';
import 'package:logging/logging.dart';

class Utils {
  static double GEARBOX = 7 * 4;

  //TODO: why 4

  static Future<ModbusClient> _connect(String ip) async {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print(
          '${rec.level.name}: ${rec.time} [${rec.loggerName}]: ${rec.message}');
    });

    var client = modbus.createTcpClient(
      ip,
      port: 502,
      mode: modbus.ModbusMode.rtu,
    );

    //await
    await client.connect();

    return client;
  }

  static String velocityFormula(int x) {
    double result;
    if (x >= 32767) {
      result = x - 65535;
    } else {
      result = x / 1;
    }

    result = result / GEARBOX;

    return result.toStringAsFixed(2);
  }

  static List<int> splitLong(int x) {
    List<int> result = <int>[0, 0];
    if (x > 65535) {
      result[0] = x ~/ 65536;
      //truncating division
    }

    result[1] = x % 65536;

    return result;
  }

  static void instructBoth(int opcode) async {
    var cli1 = await _connect('10.10.10.11');
    cli1.writeSingleRegister(124, opcode);
    var cli2 = await _connect('10.10.10.10');
    cli2.writeSingleRegister(124, opcode);
  }

  static List<double> polarCalculator(double x, double y) {
    double left = 0;
    double right = 0;

    left = -0.7 * x + y;
    right = 0.7 * x + y;

    return <double>[left, right];
  }
}

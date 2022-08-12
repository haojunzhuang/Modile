import 'package:modbus/modbus.dart' as modbus;
import 'package:modbus/modbus.dart';

class Utils {
  static const gearBox = 7 * 4;

  static Future<ModbusClient> connect(String ip) async {
    var client = modbus.createTcpClient(
      ip,
      port: 502,
      mode: modbus.ModbusMode.rtu,
    );

    //await
    await client.connect();

    return client;
  }

  static double velocityFormula(int x) {
    double result;
    if (x >= 32767) {
      result = x - 65535;
    } else {
      result = x / 1;
    }

    result = result / gearBox;

    // rounding the result
    return double.parse(result.toStringAsFixed(2));
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
    // Note that Modbus functions 3, 6, and 16 all have 40001 offset
    // For example, here: 40125 - 40001 = 124.

    var cli1 = await Utils.connect('192.168.0.201');
    cli1.writeSingleRegister(124, opcode);
    var cli2 = await Utils.connect('192.168.0.200');
    cli2.writeSingleRegister(124, opcode);
  }

  static List<double> polarCalculator(double x, double y) {
    double left = 0;
    double right = 0;

    left = -0.7 * x + y;
    right = 0.7 * x + y;

    return <double>[left, right];
  }

  // clean all the motions
  static void clean() async {
    instructBoth(225);
  }
}

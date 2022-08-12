import 'package:modbus/modbus.dart' as modbus;
import 'package:modbus/modbus.dart';

/// contains convenience methods for calculating and communicating
class Utils {
  static const gearBox = 7 * 4;

  /// returns a modbus TCP client according to the given IP address
  //TODO: error handling
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

  /// determines the direction of the speed
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

  /// breaks down a long into two bytes
  static List<int> splitLong(int x) {
    List<int> result = <int>[0, 0];
    if (x > 65535) {
      result[0] = x ~/ 65536;
      //truncating division
    }

    result[1] = x % 65536;

    return result;
  }

  /// gives an opcode command to both motors
  static void instructBoth(int opcode) async {
    // Note that Modbus functions 3, 6, and 16 all have 40001 offset
    // For example, here: 40125 - 40001 = 124.

    var cli1 = await Utils.connect('192.168.0.201');
    cli1.writeSingleRegister(124, opcode);
    var cli2 = await Utils.connect('192.168.0.200');
    cli2.writeSingleRegister(124, opcode);
  }

  /// math formula that maps the relative position of joystick to the speed of two motors
  static List<double> polarCalculator(double x, double y) {
    double left = 0;
    double right = 0;

    left = -0.7 * x + y;
    right = 0.7 * x + y;

    return <double>[left, right];
  }

  // clear all the motions
  static void clean() async {
    instructBoth(225);
  }
}

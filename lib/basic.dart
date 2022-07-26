import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:modbus/modbus.dart' as modbus;
import 'package:modbus/modbus.dart';
import 'utils.dart';

class BasicPage extends StatefulWidget {
  @override
  _BasicPageState createState() => _BasicPageState();
}

class _BasicPageState extends State<BasicPage> {
  final myController = TextEditingController();

  static ModbusClient? cli;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text("Basic Commands to Control and Monitor Motor"),
                TextButton(onPressed: _sendFL, child: Text('Feed to Length')),
                TextButton(
                    onPressed: _emergencyStop,
                    child: Text(
                      'Emergency Stop',
                      style: TextStyle(color: Colors.red),
                    )),
                ReadMotor(),
                SetDistance(),
              ],
            )),
      ),
    );
  }

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

  void _sendFL() async {
    Utils.instructBoth(102);
    //40001 offset
  }

  void _emergencyStop() async {
    Utils.instructBoth(225);
  }
}

class SetDistance extends StatefulWidget {
  @override
  _SetDistanceState createState() => _SetDistanceState();
}

class _SetDistanceState extends State<SetDistance> {
  final _textController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50.0,
        width: 300.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: TextButton(onPressed: _DI, child: Text('setDistance')),),
            Expanded(child: TextField(
              controller: _textController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Distance'
              ),
            ))
          ],
    ));
  }

  void _DI() async {
    List<int> input = Utils.splitLong(int.parse(_textController.text));
    var cli1 = await _connect('192.168.0.201');
    cli1.writeSingleRegister(31, input[1]);
    cli1.writeSingleRegister(30, input[0]);
    var cli2 = await _connect('192.168.0.200');
    cli2.writeSingleRegister(31, input[1]);
    cli2.writeSingleRegister(30, input[0]);
  }
}

class ReadMotor extends StatefulWidget {
  @override
  _ReadMotorState createState() => _ReadMotorState();
}

class _ReadMotorState extends State<ReadMotor> {
  var speed;

  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('immediate speed: $speed'),
        TextButton(onPressed: _refresh, child: Text('read'))
      ],
    );
  }

  void _refresh() async {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print(
          '${rec.level.name}: ${rec.time} [${rec.loggerName}]: ${rec.message}');
    });

    var client = modbus.createTcpClient(
      '10.10.10.11',
      port: 502,
      mode: modbus.ModbusMode.rtu,
    );

    //await
    await client.connect();

    var speed_now;
    speed_now = await client.readInputRegisters(10, 1);
    speed_now = speed_now[0];

    setState(() {
      speed = Utils.velocityFormula(speed_now);
    });

    client.close();
  }
}

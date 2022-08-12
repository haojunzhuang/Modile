/// basic_page.dart
/// This page demonstrates the mobile app's ability to both
/// send (single or multiple, with or without extra parameter)
/// and read modbus registers.

import 'package:flutter/material.dart';
import 'package:modbus/modbus.dart' as modbus;
import 'utils.dart';

class BasicPage extends StatefulWidget {
  const BasicPage({Key? key}) : super(key: key);

  @override
  _BasicPageState createState() => _BasicPageState();
}

class _BasicPageState extends State<BasicPage> {
  final myController = TextEditingController();
  final basicStyle = const TextStyle(
    fontSize: 20,
  );

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  // build the buttons and fields on the page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Basic Commands to Control and Monitor Motor",
                  style: basicStyle,
                ),
                TextButton(
                    onPressed: _sendFL,
                    child: Text(
                      'Feed to Length',
                      style: basicStyle,
                    )),
                TextButton(
                    onPressed: _emergencyStop,
                    child: const Text(
                      'Emergency Stop',
                      style: TextStyle(fontSize: 20, color: Colors.red),
                    )),
                const ReadMotor(),
                const SetDistance(),
              ],
            )),
      ),
    );
  }

  void _sendFL() async {
    Utils.instructBoth(102);
  }

  void _emergencyStop() async {
    Utils.clean();
  }
}

class SetDistance extends StatefulWidget {
  const SetDistance({Key? key}) : super(key: key);

  @override
  _SetDistanceState createState() => _SetDistanceState();
}

class _SetDistanceState extends State<SetDistance> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50.0,
        width: 300.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TextButton(
                  onPressed: _setDistance,
                  child: const Text('setDistance',
                      style: TextStyle(fontSize: 20))),
            ),
            Expanded(
                child: TextField(
              controller: _textController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Distance'),
            ))
          ],
        ));
  }

  // Since distance register is a 16 bit register, we need to send two bytes
  void _setDistance() async {
    List<int> input = Utils.splitLong(int.parse(_textController.text));
    var cli1 = await Utils.connect('192.168.0.201');
    cli1.writeSingleRegister(31, input[1]);
    cli1.writeSingleRegister(30, input[0]);
    var cli2 = await Utils.connect('192.168.0.200');
    cli2.writeSingleRegister(31, input[1]);
    cli2.writeSingleRegister(30, input[0]);
  }
}

class ReadMotor extends StatefulWidget {
  const ReadMotor({Key? key}) : super(key: key);

  @override
  _ReadMotorState createState() => _ReadMotorState();
}

class _ReadMotorState extends State<ReadMotor> {
  double speed = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('immediate speed: $speed'),
        TextButton(
            onPressed: _refresh,
            child: const Text(
              'read',
              style: TextStyle(fontSize: 20),
            ))
      ],
    );
  }

  void _refresh() async {
    var client = modbus.createTcpClient(
      '192.168.0.201',
      port: 502,
      mode: modbus.ModbusMode.rtu,
    );

    //await
    await client.connect();

    var speedNow;
    speedNow = await client.readInputRegisters(10, 1);
    speedNow = speedNow[0];

    setState(() {
      speed = Utils.velocityFormula(speedNow);
    });

    client.close();
  }
}

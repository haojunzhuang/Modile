import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:logging/logging.dart';
import 'package:modbus/modbus.dart' as modbus;
import 'package:modbus/modbus.dart';

import 'utils.dart';

const ballSize = 12.0;
const velocityCoefficient = 2000;

String mode = 'sliders';

class AdvancePage extends StatefulWidget {
  const AdvancePage({Key? key}) : super(key: key);

  @override
  _AdvancePageState createState() => _AdvancePageState();
}

class _AdvancePageState extends State<AdvancePage> {
  bool jogging = false;

  void toggleJogging(bool value) async {
    if (!jogging) {
      Utils.instructBoth(150);
      setState(() {
        jogging = value;
      });
    } else {
      Utils.instructBoth(225);
      setState(() {
        jogging = value;
      });
    }
  }

  void roundZero() async {
    var cli1 = await Utils.connect('192.168.0.201');
    cli1.writeSingleRegister(48, 0);
    var cli2 = await Utils.connect('192.168.0.200');
    cli2.writeSingleRegister(48, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 60.0,
              child: DropdownButton<String>(
                value: mode,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    mode = newValue!;
                    //rebuild the widget everytime
                    roundZero();
                  });
                },
                items: <String>['sliders', 'joystick']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
                color: Colors.orangeAccent,
                height: 50.0,
                child: Switch(
                  value: jogging,
                  onChanged: toggleJogging,
                )),
          ],
        ),
        JoyStickPage(),
      ],
    ));
  }
}

class JoyStickPage extends StatefulWidget {
  const JoyStickPage({Key? key}) : super(key: key);

  @override
  _JoyStickPageState createState() => _JoyStickPageState();
}

class _JoyStickPageState extends State<JoyStickPage> {

  void roundSimilar() {
    if (_speed0 != 0 && _speed1 != 0 && (_speed0 - _speed1).abs() < 0.2) {
      _speed1 = _speed0;
    } else {}
  }

  void roundZero() {
    _speed0 = 0;
    _speed1 = 0;
    changeSpeed0();
    changeSpeed1();
  }

  void changeSpeed0() async {
    _speed0 *= velocityCoefficient;
    var cli = await Utils.connect('192.168.0.201');
    cli.writeSingleRegister(48, _speed0.toInt());
  }

  void changeSpeed1() async {
    _speed1 *= velocityCoefficient;
    var cli = await Utils.connect('192.168.0.200');
    cli.writeSingleRegister(48, -_speed1.toInt());
    //negative
  }

  void end0() async {
    _speed0 = 0;
    changeSpeed0();
  }

  void end1() async {
    _speed1 = 0;
    changeSpeed1();
  }

  void test() async {
    var cli = await Utils.connect('10.10.10.11');
    cli.writeSingleRegister(48, 1000);
  }

  var _speed0;
  var _speed1;
  var speedLeft;
  var speedRight;

  void readVelocity() async {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print(
          '${rec.level.name}: ${rec.time} [${rec.loggerName}]: ${rec.message}');
    });

    var clientLeft = modbus.createTcpClient(
      '192.168.0.201',
      port: 502,
      mode: modbus.ModbusMode.rtu,
    );

    await clientLeft.connect();

    speedLeft = await clientLeft.readInputRegisters(10, 1);
    speedLeft = speedLeft[0];

    setState(() {
      speedLeft = Utils.velocityFormula(speedLeft);
    });

    var clientRight = modbus.createTcpClient(
      '192.168.0.200',
      port: 502,
      mode: modbus.ModbusMode.rtu,
    );

    await clientRight.connect();

    speedRight = await clientRight.readInputRegisters(10, 1);
    speedRight = speedRight[0];

    setState(() {
      speedRight = Utils.velocityFormula(speedRight);
    });
  }


  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case 'sliders':
        return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 50.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 150.0,
                    height: 150.0,
                    child: Align(
                      alignment: Alignment(0, 0.8),
                      child: Joystick(
                          mode: JoystickMode.vertical,
                          period: const Duration(milliseconds: 100),
                          listener: (details) {
                            setState(() {
                              _speed0 = details.y;
                              roundSimilar();
                              changeSpeed0();
                            });
                          },
                          onStickDragEnd: () {
                            setState(() {
                              _speed0 = 0;
                              end0();
                            });
                          }),
                    ),
                  ),
                  Container(
                    width: 150.0,
                    height: 150.0,
                    child: Joystick(
                        mode: JoystickMode.vertical,
                        period: const Duration(milliseconds: 100),
                        listener: (details) {
                          setState(() {
                            _speed1 = details.y;
                            roundSimilar();
                            changeSpeed1();
                          });
                        },
                        onStickDragEnd: () {
                          setState(() {
                            _speed1 = 0;
                            end1();
                          });
                        }),
                  )
                ],
              )
            ]);
      case 'joystick':
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 50.0,
            ),
            Align(
              alignment: const Alignment(0, 0.8),
              child: Joystick(
                  mode: JoystickMode.all,
                  period: const Duration(milliseconds: 100),
                  listener: (details) {
                    setState(() {
                      List<double> result =
                          Utils.polarCalculator(details.x, details.y);
                      _speed0 = result[0];
                      _speed1 = result[1];
                      roundSimilar();
                      changeSpeed0();
                      changeSpeed1();
                    });
                  },
                  onStickDragEnd: () {
                    setState(() {
                      _speed0 = 0;
                      _speed1 = 0;
                      end0();
                      end1();
                    });
                  }),
            ),
          ],
        );

      default:
        return Text('default');
    }
  }
}

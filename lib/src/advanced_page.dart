import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'utils.dart';

/// Size of the joystick
const ballSize = 12.0;

/// a convenient coefficient that should be multiplied by the velocity sent to the motor
const velocityCoefficient = 2000;

/// a switch that indicates which control mode is selected
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
      var cli1 = await Utils.connect('192.168.0.201');
      cli1.writeSingleRegister(48, 0);
      var cli2 = await Utils.connect('192.168.0.200');
      cli2.writeSingleRegister(48, 0);
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
            SizedBox(
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
                  });
                },
                items: <String>['sliders', 'joystick']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
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
        const MaxVelocitySetter(),
        // const is avoided here because this is built based on the global variable 'mode'
        // TODO: change to stream builder
        JoyStickPage(),
      ],
    ));
  }
}

//TODO: add a slider for max velocity
class MaxVelocitySetter extends StatefulWidget {
  const MaxVelocitySetter({Key? key}) : super(key: key);

  @override
  State<MaxVelocitySetter> createState() => _MaxVelocitySetterState();
}

class _MaxVelocitySetterState extends State<MaxVelocitySetter> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class JoyStickPage extends StatefulWidget {
  const JoyStickPage({Key? key}) : super(key: key);

  @override
  _JoyStickPageState createState() => _JoyStickPageState();
}

class _JoyStickPageState extends State<JoyStickPage> {
  void deadband() {
    if (_speed0 != 0 && _speed1 != 0 && (_speed0 - _speed1).abs() < 0.3) {
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

  void endLeft() async {
    _speed0 = 0;
    changeSpeed0();
  }

  void endRight() async {
    _speed1 = 0;
    changeSpeed1();
  }

  void test() async {
    var cli = await Utils.connect('10.10.10.11');
    cli.writeSingleRegister(48, 1000);
  }

  double _speed0 = 0;
  double _speed1 = 0;

  double actualSpeedLeft = 0;
  double actualSpeedRight = 0;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case 'sliders':
        return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                height: 50.0,
              ),
              Text('left: $actualSpeedLeft right: $actualSpeedRight'),
              const SizedBox(
                height: 50.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150.0,
                    height: 150.0,
                    child: Align(
                      alignment: const Alignment(0, 0.8),
                      child: Joystick(
                          mode: JoystickMode.vertical,
                          period: const Duration(milliseconds: 100),
                          listener: (details) {
                            setState(() {
                              _speed0 = details.y;
                              //no round similar
                              changeSpeed0();
                            });
                          },
                          onStickDragEnd: () {
                            setState(() {
                              _speed0 = 0;
                              endLeft();
                            });
                          }),
                    ),
                  ),
                  SizedBox(
                    width: 150.0,
                    height: 150.0,
                    child: Joystick(
                        mode: JoystickMode.vertical,
                        period: const Duration(milliseconds: 100),
                        listener: (details) {
                          setState(() {
                            _speed1 = details.y;
                            deadband();
                            changeSpeed1();
                          });
                        },
                        onStickDragEnd: () {
                          setState(() {
                            _speed1 = 0;
                            endRight();
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
            const SizedBox(
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
                      deadband();
                      changeSpeed0();
                      changeSpeed1();
                    });
                  },
                  onStickDragEnd: () {
                    setState(() {
                      _speed0 = 0;
                      _speed1 = 0;
                      endLeft();
                      endRight();
                    });
                  }),
            ),
          ],
        );

      default:
        return const Text('default');
    }
  }
}

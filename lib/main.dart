/// main.dart
/// A flutter-based mobile app that controls MDX-series motors.
/// More information about flutter here: https://flutter.dev/.
/// The IP address of the two motors in the AGV demo are 192.108.0.201(left) and 192.108.0.200(right),
/// but they can be set to other addresses.
/// The communication uses Modbus TCP protocol.
/// More information could be found at appendix K of Host Command Reference:
/// https://www.applied-motion.com/sites/default/files/Host-Command-Reference_920-0002P.PDF.
/// Feel free to submit pull requests at: https://github.com/Hogean/Modile.
/// Testflight invitation is available, please contact me at
/// hzhuang@applied-motion.com or (510)-710-8946.
/// Arthor: Haojun Zhuang
///

// This app adopts material design.
import 'package:flutter/material.dart';

import 'basic_page.dart';
import 'advanced.dart';
import 'utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'MDX Mobile Controller';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  // options of the bottom navigation bar
  static final List<Widget> _widgetOptions = <Widget>[
    const BasicPage(),
    const AdvancePage(),
    const Text(
      'Settings',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    Utils.clean();
    setState(() {
      // setState takes an anonymous function, whcih should be responsible of
      // changing the internal state of the widget
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MDX Mobile'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Basic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Advanced',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo[500],
        onTap: _onItemTapped,
      ),
    );
  }
}

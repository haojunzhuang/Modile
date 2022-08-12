# Modile

A flutter-based app that uses Modbus TCP protocol to Control MDX motors

## How it works

This mobile app is intended to serve the AGV demo. In the demo, the ethernet port of the motors are connected to a wifi router with IP 192.168.0.1, which enables a mobile device's wireless connection to the AGV.

In order to use the app, first power up the wifi router and connect your device to the wifi named "wifidemo". Note that no internet is supplied to the router so the devices actually talk in LAN.

## Links

### Flutter Framework

https://docs.flutter.dev/get-started/install

### Modbus Package

https://pub.dev/packages/modbus

### Host Command Reference

https://www.applied-motion.com/sites/default/files/Host-Command-Reference_920-0002P.PDF

### Modbus Cheat Sheet

https://ozeki.hu/p_5873-modbus-function-codes.html

## Debugging

- make sure that on the wifi router, the indicator lights marked "LAN" and "PWR" are green.
- make sure that on the wifi router, the indicator light makred WLAN is constantly blinking (if not, then probably the mobile device is not properly connected to wifidemo)
- if using emulator, try erasing all the data or install a new one
- the IP address of the motors may be lost sometimes. Try recovering address of 10.10.10.11(left) and 10.10.10.10(right)

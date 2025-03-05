import 'dart:io';
import 'package:osc/osc.dart';

class VrcOsc {
  final _sendAddress = InternetAddress("127.0.0.1");
  final _sendPort = 9000;

  Future<void> sendAvatar(String avatarId) async {
    await _sendOSCMessage("/avatar/change", avatarId);
  }

  Future<void> _sendOSCMessage(String address, String argument) async {
    await _sendSocket().send(OSCMessage(address, arguments: [argument]));
  }

  OSCSocket _sendSocket() {
    return OSCSocket(destination: _sendAddress, destinationPort: _sendPort);
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:udp/udp.dart';

class VRCOSC {
  final _sendAddress = InternetAddress("127.0.0.1");
  final _sendPort = Port(9000);

  Future<void> sendAvatar(String avatarId) async {
    await _sendOSCMessage("/avatar/change", avatarId);
  }

  Future<void> _sendOSCMessage(String address, String argument) async {
    final message = _buildOscMessage(address, argument);
    final sender = await UDP.bind(Endpoint.any());
    await sender.send(Uint8List.fromList(message),
        Endpoint.unicast(_sendAddress, port: _sendPort));
    sender.close();
  }

  // OSCメッセージのフォーマットを作成する関数
  List<int> _buildOscMessage(String address, String argument) {
    List<int> addressBytes = _oscStringToBytes(address);
    List<int> typeTagBytes = _oscStringToBytes(",s"); // OSCの型タグ（文字列: "s"）
    List<int> argumentBytes = _oscStringToBytes(argument);
    return [...addressBytes, ...typeTagBytes, ...argumentBytes];
  }

  // OSCの文字列をバイト配列に変換する関数（Null文字で終端し、4バイト区切り）
  List<int> _oscStringToBytes(String value) {
    List<int> bytes = value.codeUnits + [0]; // 文字列にNull終端を追加
    while (bytes.length % 4 != 0) {
      bytes.add(0); // 4バイト境界に揃える
    }
    return bytes;
  }
}

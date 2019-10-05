import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  final key = "SESSION";
  final storage = new FlutterSecureStorage();

  set(String token, int expiresIn) async {
    final data = {
      "token": token,
      "expiresIn": expiresIn,
      "createdAt": DateTime.now().toString()
    };
    await storage.write(key: key, value: jsonEncode(data));
  }

  get() async {
    final result = await storage.read(key: key);
    if (result != null) {
      return jsonDecode(result);
    }
    return null;
  }

  clear() async {
    await storage.deleteAll();
  }
}

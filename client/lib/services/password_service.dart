import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordService {
  static final PasswordService _instance = PasswordService._internal();
  factory PasswordService() => _instance;
  PasswordService._internal();

  static const int _saltLength = 16;
  static const int _iterations = 10000;

  String hashPassword(String password) {
    final salt = _generateSalt();
    final hash = _pbkdf2(password, salt);
    final combined = salt + hash;
    return base64.encode(combined);
  }

  bool verifyPassword(String password, String hashedPassword) {
    try {
      final decoded = base64.decode(hashedPassword);
      final salt = decoded.sublist(0, _saltLength);
      final storedHash = decoded.sublist(_saltLength);
      final computedHash = _pbkdf2(password, salt);
      return _constantTimeEquals(storedHash, computedHash);
    } catch (e) {
      return false;
    }
  }

  Uint8List _generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final salt = Uint8List(_saltLength);
    for (int i = 0; i < _saltLength; i++) {
      salt[i] = (random >> (8 * (i % 4))) & 0xFF;
    }
    return salt;
  }

  Uint8List _pbkdf2(String password, Uint8List salt) {
    final passwordBytes = utf8.encode(password);
    final hmac = Hmac(sha256, passwordBytes);
    
    Uint8List result = Uint8List(32);
    Uint8List block = Uint8List(32 + salt.length);
    block.setAll(0, salt);
    
    for (int i = 1; i <= _iterations; i++) {
      final iBytes = _intToBytes(i);
      block.setAll(salt.length, iBytes);
      
      final u = hmac.convert(block).bytes;
      for (int j = 0; j < result.length; j++) {
        result[j] = result[j] ^ u[j];
      }
    }
    
    return result;
  }

  Uint8List _intToBytes(int value) {
    final bytes = Uint8List(4);
    bytes[0] = (value >> 24) & 0xFF;
    bytes[1] = (value >> 16) & 0xFF;
    bytes[2] = (value >> 8) & 0xFF;
    bytes[3] = value & 0xFF;
    return bytes;
  }

  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) {
      return false;
    }
    
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    
    return result == 0;
  }
}

final passwordServiceProvider = Provider<PasswordService>((ref) => PasswordService());
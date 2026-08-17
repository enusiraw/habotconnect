import 'dart:convert';
import 'package:crypto/crypto.dart';

class Sha256Generator {

  // Generate SHA-256 hash from a string
  static String generate(String input) {
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
  
  // Generate SHA-256 hash from a map 
  static String generateFromMap(Map<String, dynamic> data) {
    
    final sortedMap = Map.fromEntries(
      data.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    final jsonString = jsonEncode(sortedMap);
    return generate(jsonString);
  }
  
  // Validate SHA-256 hash 
  static bool isValid(String? hash) {
    if (hash == null || hash.isEmpty) return false;
    if (hash.length != 64) return false;
    return RegExp(r'^[a-f0-9]{64}$').hasMatch(hash);
  }
}
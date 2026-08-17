import 'package:uuid/uuid.dart';

// Generates UUID v4 for trace_id metadata
class UuidGenerator {
  static const Uuid _uuid = Uuid();
  
  // Generate a new UUID v4 string
  static String generate() {
    return _uuid.v4();
  }
  
  // Validate if a string is a valid UUID v4
  static bool isValid(String? uuid) {
    if (uuid == null || uuid.isEmpty) return false;
    try {
      return Uuid.isValidUUID(fromString: uuid);
    } catch (e) {
      return false;
    }
  }
}
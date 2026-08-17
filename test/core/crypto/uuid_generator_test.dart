import 'package:flutter_test/flutter_test.dart';
import 'package:habotconnect_lsa_verification/core/crypto/uuid_generator.dart';

void main() {
  group('UuidGenerator', () {
    test('should generate valid UUID v4', () {
      final uuid = UuidGenerator.generate();
      
      expect(uuid, isNotEmpty);
      expect(UuidGenerator.isValid(uuid), isTrue);
    });

    test('should generate different UUIDs on each call', () {
      final uuid1 = UuidGenerator.generate();
      final uuid2 = UuidGenerator.generate();
      
      expect(uuid1, isNot(equals(uuid2)));
    });

    test('should validate valid UUID', () {
      const validUuid = '550e8400-e29b-41d4-a716-446655440000';
      
      expect(UuidGenerator.isValid(validUuid), isTrue);
    });

    test('should reject invalid UUID', () {
      expect(UuidGenerator.isValid(null), isFalse);
      expect(UuidGenerator.isValid(''), isFalse);
      expect(UuidGenerator.isValid('not-a-uuid'), isFalse);
      expect(UuidGenerator.isValid('12345'), isFalse);
    });
  });
}
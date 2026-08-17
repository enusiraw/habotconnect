import 'package:flutter_test/flutter_test.dart';
import 'package:habotconnect_lsa_verification/core/crypto/sha256_generator.dart';

void main() {
  group('Sha256Generator', () {
    test('should generate valid SHA-256 hash', () {
      const input = 'test input';
      final hash = Sha256Generator.generate(input);
      
      expect(hash, isNotEmpty);
      expect(hash.length, equals(64));
      expect(Sha256Generator.isValid(hash), isTrue);
    });

    test('should generate consistent hash for same input', () {
      const input = 'consistent input';
      final hash1 = Sha256Generator.generate(input);
      final hash2 = Sha256Generator.generate(input);
      
      expect(hash1, equals(hash2));
    });

    test('should generate different hashes for different inputs', () {
      final hash1 = Sha256Generator.generate('input1');
      final hash2 = Sha256Generator.generate('input2');
      
      expect(hash1, isNot(equals(hash2)));
    });

    test('should generate hash from map deterministically', () {
      final map1 = {'a': '1', 'b': '2'};
      final map2 = {'b': '2', 'a': '1'}; // Different order
      
      final hash1 = Sha256Generator.generateFromMap(map1);
      final hash2 = Sha256Generator.generateFromMap(map2);
      
      // Should be same because keys are sorted
      expect(hash1, equals(hash2));
    });

    test('should validate valid SHA-256 hash', () {
      const validHash = 'a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e';
      
      expect(Sha256Generator.isValid(validHash), isTrue);
    });

    test('should reject invalid SHA-256 hash', () {
      expect(Sha256Generator.isValid(null), isFalse);
      expect(Sha256Generator.isValid(''), isFalse);
      expect(Sha256Generator.isValid('not-a-hash'), isFalse);
      expect(Sha256Generator.isValid('12345'), isFalse);
      expect(Sha256Generator.isValid('g' * 64), isFalse); // Invalid hex characters
    });
  });
}
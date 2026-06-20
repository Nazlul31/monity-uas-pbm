import 'package:flutter_test/flutter_test.dart';
import 'package:monity/data/models/transaction_model.dart';

void main() {
  group('TransactionModel Tests', () {
    final testDate = DateTime(2026, 6, 20, 12, 0, 0);
    
    test('should correctly convert to and from map', () {
      final model = TransactionModel(
        id: 'tx-test',
        title: 'Test Income',
        amount: 150000.0,
        type: 'pemasukan',
        category: 'Test Category',
        date: testDate,
      );

      final map = model.toMap();
      expect(map['id'], 'tx-test');
      expect(map['title'], 'Test Income');
      expect(map['amount'], 150000.0);
      expect(map['type'], 'pemasukan');
      expect(map['category'], 'Test Category');
      expect(map['date'], testDate.toIso8601String());

      final fromMapModel = TransactionModel.fromMap(map);
      expect(fromMapModel.id, model.id);
      expect(fromMapModel.title, model.title);
      expect(fromMapModel.amount, model.amount);
      expect(fromMapModel.type, model.type);
      expect(fromMapModel.category, model.category);
      expect(fromMapModel.date, model.date);
    });

    test('should throw assertion error on invalid type during initialization', () {
      expect(
        () => TransactionModel(
          id: 'tx-invalid',
          title: 'Invalid type',
          amount: 100.0,
          type: 'invalid_type',
          category: 'Category',
          date: testDate,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should throw ArgumentError on invalid type fromMap', () {
      final invalidMap = {
        'id': 'tx-invalid',
        'title': 'Invalid type',
        'amount': 100.0,
        'type': 'wrong',
        'category': 'Category',
        'date': testDate.toIso8601String(),
      };
      
      expect(
        () => TransactionModel.fromMap(invalidMap),
        throwsA(isA<ArgumentError>()),
      );
    });
  group('json serialization', () {
    test('should serialize to and from json correctly', () {
      final model = TransactionModel(
        id: 'tx-json',
        title: 'JSON Income',
        amount: 20000.0,
        type: 'pemasukan',
        category: 'Food',
        date: testDate,
      );

      final json = model.toJson();
      final fromJsonModel = TransactionModel.fromJson(json);

      expect(fromJsonModel.id, model.id);
      expect(fromJsonModel.type, model.type);
      expect(fromJsonModel.amount, model.amount);
    });
  });
  });
}

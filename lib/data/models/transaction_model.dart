class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; // Must be 'pemasukan' or 'pengeluaran'
  final String category;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  }) : assert(
          type == 'pemasukan' || type == 'pengeluaran',
          'Type must be either "pemasukan" or "pengeluaran"',
        );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final typeVal = json['type'] as String;
    if (typeVal != 'pemasukan' && typeVal != 'pengeluaran') {
      throw ArgumentError('Type must be either "pemasukan" or "pengeluaran"');
    }
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: typeVal,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final typeVal = map['type'] as String;
    if (typeVal != 'pemasukan' && typeVal != 'pengeluaran') {
      throw ArgumentError('Type must be either "pemasukan" or "pengeluaran"');
    }
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: typeVal,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
    };
  }
}

class TransactionModel {
  final String id;
  final int userId;
  final String title;
  final double amount;
  final String type; // Must be 'pemasukan' or 'pengeluaran'
  final String category;
  final DateTime date;
  final String? note;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
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
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: typeVal,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel.fromJson(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  Map<String, dynamic> toMap() => toJson();
}

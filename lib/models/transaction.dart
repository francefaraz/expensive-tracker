class TransactionModel {
  final int? id;
  final String type; // 'income' or 'expense'
  final String title;
  final double amount;
  final String paymentMethod; // 'Cash', 'Online', etc.
  final String category;
  final String date; // Store as ISO string
  final String? note;
  final String? tag; // Source/Destination

  TransactionModel({
    this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.paymentMethod,
    required this.category,
    required this.date,
    this.note,
    this.tag,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'category': category,
      'date': date,
      'note': note,
      'tag': tag,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      type: map['type'],
      title: map['title'],
      amount: map['amount'],
      paymentMethod: map['paymentMethod'],
      category: map['category'],
      date: map['date'],
      note: map['note'],
      tag: map['tag'],
    );
  }
}

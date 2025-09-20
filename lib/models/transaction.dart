class TransactionModel {
  final int? id;
  final String type; // 'income' or 'expense'
  final String title;
  final double amount;
  final String paymentMethod; // 'Cash', 'Online', 'Credit Card', etc.
  final String category;
  final String date; // Store as ISO string
  final String? note;
  final String? tag; // Source/Destination
  final bool isCreditCard; // New field for credit card transactions
  final String? creditCardName; // Credit card name like 'HDFC', 'SBI', etc.
  final bool isPaidOff; // Whether credit card bill is paid or not

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
    this.isCreditCard = false,
    this.creditCardName,
    this.isPaidOff = false,
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
      'isCreditCard': isCreditCard ? 1 : 0,
      'creditCardName': creditCardName,
      'isPaidOff': isPaidOff ? 1 : 0,
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
      isCreditCard: (map['isCreditCard'] ?? 0) == 1,
      creditCardName: map['creditCardName'],
      isPaidOff: (map['isPaidOff'] ?? 0) == 1,
    );
  }
}

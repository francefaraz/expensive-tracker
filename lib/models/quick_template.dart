class QuickTemplate {
  final String type; // 'income' or 'expense'
  final String title;
  final double amount;
  final String paymentMethod;
  final String category;
  final String? provider;

  QuickTemplate({
    required this.type,
    required this.title,
    required this.amount,
    required this.paymentMethod,
    required this.category,
    this.provider,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'category': category,
      'provider': provider,
    };
  }

  factory QuickTemplate.fromMap(Map<String, dynamic> map) {
    return QuickTemplate(
      type: map['type'] ?? 'expense',
      title: map['title'],
      amount: map['amount'],
      paymentMethod: map['paymentMethod'],
      category: map['category'],
      provider: map['provider'],
    );
  }
} 
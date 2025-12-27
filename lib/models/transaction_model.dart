class Transaction {
  final int id;
  final String type; // 'earning', 'withdrawal', 'subscription'
  final double amount;
  final String description;
  final String status; // 'completed', 'pending', 'failed'
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'] ?? '',
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

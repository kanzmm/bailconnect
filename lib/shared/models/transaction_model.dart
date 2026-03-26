/// Modèle Transaction/Paiement
class Transaction {
  final String id;
  final String userId;
  final String? listingId;
  final double amount;
  final String currency; // Fc, USD, etc.
  final String provider; // Orange Money, Airtel Money, etc.
  final String status; // pending, success, failed
  final String? referenceNumber;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;

  const Transaction({
    required this.id,
    required this.userId,
    this.listingId,
    required this.amount,
    required this.currency,
    required this.provider,
    required this.status,
    this.referenceNumber,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
  });

  bool get isPending => status == 'pending';
  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';

  Transaction copyWith({
    String? id,
    String? userId,
    String? listingId,
    double? amount,
    String? currency,
    String? provider,
    String? status,
    String? referenceNumber,
    DateTime? createdAt,
    DateTime? completedAt,
    String? failureReason,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      listingId: listingId ?? this.listingId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}

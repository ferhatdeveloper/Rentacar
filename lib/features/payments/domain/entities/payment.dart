import 'package:equatable/equatable.dart';

enum PaymentStatus {
  pending('Beklemede'),
  completed('Tamamlandı'),
  failed('Başarısız'),
  refunded('İade');

  const PaymentStatus(this.label);
  final String label;

  static PaymentStatus fromDb(String v) => switch (v) {
        'completed' => PaymentStatus.completed,
        'failed' => PaymentStatus.failed,
        'refunded' => PaymentStatus.refunded,
        _ => PaymentStatus.pending,
      };
}

class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.tenantId,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.status,
    this.rentalId,
    this.customerName,
    this.rentalNumber,
    this.method = 'card',
    this.paidAt,
  });

  final String id;
  final String tenantId;
  final String customerId;
  final String type;
  final double amount;
  final PaymentStatus status;
  final String? rentalId;
  final String? customerName;
  final String? rentalNumber;
  final String method;
  final DateTime? paidAt;

  String get typeLabel => switch (type) {
        'rental' => 'Kiralama',
        'deposit' => 'Depozito',
        'damage' => 'Hasar',
        'refund' => 'İade',
        _ => type,
      };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String,
        customerId: json['customer_id'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        status: PaymentStatus.fromDb(json['status'] as String? ?? 'pending'),
        rentalId: json['rental_id'] as String?,
        customerName: json['customer_name'] as String?,
        rentalNumber: json['rental_number'] as String?,
        method: json['method'] as String? ?? 'card',
        paidAt: json['paid_at'] != null
            ? DateTime.parse(json['paid_at'] as String)
            : null,
      );

  @override
  List<Object?> get props => [id];
}

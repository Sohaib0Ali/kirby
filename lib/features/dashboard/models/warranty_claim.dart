class WarrantyClaim {
  final String id;
  final String productName;
  final String customerName;
  final String customerEmail;
  final String claimStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String description;
  final String? serialNumber;

  WarrantyClaim({
    required this.id,
    required this.productName,
    required this.customerName,
    required this.customerEmail,
    required this.claimStatus,
    required this.createdAt,
    this.updatedAt,
    required this.description,
    this.serialNumber,
  });

  factory WarrantyClaim.fromJson(Map<String, dynamic> json) {
    return WarrantyClaim(
      id: json['id'] as String,
      productName: json['product_name'] as String,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      claimStatus: json['claim_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      description: json['description'] as String,
      serialNumber: json['serial_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'claim_status': claimStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'description': description,
      'serial_number': serialNumber,
    };
  }
}

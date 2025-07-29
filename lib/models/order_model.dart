class OrderModel {
  final String id;
  final String userEmail; // នេះជា userId នៅក្នុង backend របស់អ្នក
  final String roomName;
  final String checkInDate;
  final String checkOutDate;
  final int guests;
  final String paymentMethod;
  final double totalPrice;
  final String status;
  final String createdAt;

  OrderModel({
    required this.id,
    required this.userEmail, // នេះជា userId នៅក្នុង backend របស់អ្នក
    required this.roomName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.paymentMethod,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'], // ✅ ល្អណាស់សម្រាប់ការគ្រប់គ្រង MongoDB _id
      userEmail:
          json['userEmail'] ??
          json['userId'] ??
          '', // ✅ កែសម្រួលដើម្បីទទួលយក userEmail ឬ userId
      roomName: json['roomName'] ?? '',
      checkInDate: json['checkInDate'] ?? '',
      checkOutDate: json['checkOutDate'] ?? '',
      guests: json['guests'] as int? ?? 1, // ✅ ប្រើ as int? ??
      paymentMethod: json['paymentMethod'] ?? '',
      totalPrice:
          double.tryParse(json['totalPrice'].toString()) ?? 0.0, // ✅ ល្អណាស់
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

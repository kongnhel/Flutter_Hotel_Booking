import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:hotel_booking/models/order_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  static const String id = '/adminOrdersScreen';

  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final url = "http://localhost:3000/api/orders";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _orders = data.map((e) => OrderModel.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        _showSnackBar(
          "បរាជ័យក្នុងការផ្ទុកការកក់",
          isError: true,
        ); // Failed to load orders
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar("កំហុសបណ្តាញ: $e", isError: true); // Network error:
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(String id, String newStatus) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("កំពុងធ្វើបច្ចុប្បន្នភាព..."), // Updating...
          ],
        ),
      ),
    );

    try {
      final response = await http.put(
        Uri.parse("http://localhost:3000/api/orders/$id/status"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": newStatus}),
      );

      Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        _showSnackBar(
          "ការកក់ត្រូវបានធ្វើបច្ចុប្បន្នភាពទៅ $newStatus",
        ); // Order updated to
        await fetchOrders();
      } else {
        _showSnackBar(
          "ការធ្វើបច្ចុប្បន្នភាពបរាជ័យ: ${response.body}",
          isError: true,
        ); // Update failed:
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      _showSnackBar("កំហុសបណ្តាញ: $e", isError: true); // Network error:
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  String _formatDate(String date) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  // Helper to translate status strings for display
  String _getTranslatedStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'បានបញ្ជាក់'; // Confirmed
      case 'rejected':
        return 'បានបដិសេធ'; // Rejected
      case 'pending':
        return 'កំពុងរង់ចាំ'; // Pending
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "គ្រប់គ្រងការកក់", // Manage Orders
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.cyan,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text(
                    "រកមិនឃើញការកក់ណាមួយទេ", // No orders found
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: fetchOrders,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("ធ្វើឱ្យស្រស់"), // Refresh
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (_, i) {
                final o = _orders[i];
                return _buildOrderCard(o);
              },
            ),
    );
  }

  Widget _buildOrderCard(OrderModel o) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "លេខសម្គាល់ការកក់: ${o.id}", // Order ID:
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
            const Divider(),
            _row("អ្នកប្រើប្រាស់:", o.userEmail), // User:
            _row("បន្ទប់:", o.roomName), // Room:
            _row("ថ្ងៃចូល:", _formatDate(o.checkInDate)), // Check-in:
            _row("ថ្ងៃចេញ:", _formatDate(o.checkOutDate)), // Check-out:
            _row("ភ្ញៀវ:", o.guests.toString()), // Guests:
            _row("ការទូទាត់:", o.paymentMethod), // Payment:
            _row("សរុប:", "\$${o.totalPrice.toStringAsFixed(2)}"), // Total:
            _row("បានកក់:", _formatDate(o.createdAt)), // Booked:
            _row(
              "ស្ថានភាព:",
              _getTranslatedStatus(o.status),
              color: _getStatusColor(o.status),
            ), // Status:
            if (o.status == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(o.id, 'confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("ទទួលយក"), // Accept
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(o.id, 'rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("បដិសេធ"), // Reject
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

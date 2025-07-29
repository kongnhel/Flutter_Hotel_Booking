import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotel_booking/models/order_model.dart';

class OrdersScreen extends StatefulWidget {
  static const String id = '/ordersScreen';

  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _checkUserRoleAndFetchOrders();
  }

  Future<void> _checkUserRoleAndFetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    _isAdmin = prefs.getBool('isAdmin') ?? false;
    _userEmail = prefs.getString('email');

    await fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final url = _isAdmin
          ? "http://localhost:3000/api/orders"
          : "http://localhost:3000/api/orders/user/$_userEmail";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _orders = data.map((e) => OrderModel.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        _showSnackBar("Failed to load orders", isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar("Network error: $e", isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Updating..."),
          ],
        ),
      ),
    );

    try {
      final response = await http.put(
        Uri.parse("http://localhost:3000/api/orders/$orderId/status"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": newStatus}),
      );

      Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        _showSnackBar("Order updated to $newStatus");
        await fetchOrders();
      } else {
        _showSnackBar("Update failed: ${response.body}", isError: true);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      _showSnackBar("Network error: $e", isError: true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
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
                    "No orders found",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: fetchOrders,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      "Refresh",
                      style: TextStyle(color: Colors.white),
                    ),
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
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order ID: ${o.id}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const Divider(),
                        _row("Email:", o.userEmail),
                        _row("Room:", o.roomName),
                        _row("Check-in:", _formatDate(o.checkInDate)),
                        _row("Check-out:", _formatDate(o.checkOutDate)),
                        _row("Guests:", o.guests.toString()),
                        _row("Payment:", o.paymentMethod),
                        _row("Total:", "\$${o.totalPrice.toStringAsFixed(2)}"),
                        _row("Booked:", _formatDate(o.createdAt)),
                        _row(
                          "Status:",
                          o.status,
                          color: _getStatusColor(o.status),
                        ),
                        if (_isAdmin && o.status == 'pending')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _updateOrderStatus(o.id, 'confirmed'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text("Accept"),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () =>
                                    _updateOrderStatus(o.id, 'rejected'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text("Reject"),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
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

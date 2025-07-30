import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotel_booking/models/order_model.dart';

// Base URL for your API. Ensure this matches your backend.
const String kBaseUrl = 'http://localhost:3000/api';

class OrdersScreen extends StatefulWidget {
  static const String id = '/ordersScreen';

  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchOrders();
  }

  Future<void> _loadUserAndFetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('email');

    if (_userEmail == null || _userEmail!.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(
        "សូម Login ដើម្បីមើលការកក់របស់អ្នក",
        isError: true,
      ); // Please login to view your bookings
      return;
    }

    await fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      // Use the user's email as userId for fetching orders
      final url = "$kBaseUrl/orders/user/$_userEmail";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _orders = data.map((e) => OrderModel.fromJson(e)).toList();
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        // No orders found for this user
        setState(() {
          _orders = [];
          _isLoading = false;
        });
        // _showSnackBar("មិនមានការកក់ណាមួយសម្រាប់អ្នកប្រើប្រាស់នេះទេ។"); // No bookings for this user.
      } else {
        _showSnackBar(
          "បរាជ័យក្នុងការផ្ទុកការកក់",
          isError: true,
        ); // Failed to load orders
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar("មានបញ្ហាបណ្តាញ: $e", isError: true); // Network error
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    // Show confirmation dialog
    final bool? confirm = await _showConfirmationDialog(
      "លុបការកក់", // Delete Booking
      "តើអ្នកពិតជាចង់លុបការកក់នេះមែនទេ?", // Are you sure you want to delete this booking?
    );

    if (confirm == true) {
      // Show loading indicator
      _showLoadingDialog("កំពុងលុបការកក់..."); // Deleting booking...
      try {
        final url = "$kBaseUrl/orders/$orderId";
        final response = await http.delete(Uri.parse(url));

        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(); // Dismiss loading dialog

        if (response.statusCode == 200) {
          _showSnackBar(
            "ការកក់ត្រូវបានលុបដោយជោគជ័យ!",
          ); // Booking deleted successfully!
          await fetchOrders(); // Refresh the list
        } else {
          String errorMessage =
              "បរាជ័យក្នុងការលុបការកក់។"; // Failed to delete booking.
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData["error"] ?? errorMessage;
          } catch (_) {
            // Fallback if response body is not JSON
          }
          _showSnackBar(errorMessage, isError: true);
        }
      } catch (e) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(); // Dismiss loading dialog
        _showSnackBar("មានបញ្ហាបណ្តាញ: $e", isError: true); // Network error
      }
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    String confirmationMessage = "";
    String successMessage = "";
    String errorMessage = "";
    String loadingMessage = "";

    if (newStatus == "canceled") {
      confirmationMessage =
          "តើអ្នកពិតជាចង់បោះបង់ការកក់នេះមែនទេ?"; // Are you sure you want to cancel this booking?
      successMessage =
          "ការកក់ត្រូវបានបោះបង់ដោយជោគជ័យ!"; // Booking canceled successfully!
      errorMessage = "បរាជ័យក្នុងការបោះបង់ការកក់។"; // Failed to cancel booking.
      loadingMessage = "កំពុងបោះបង់ការកក់..."; // Cancelling booking...
    } else {
      // Add other status update messages if needed
      return;
    }

    final bool? confirm = await _showConfirmationDialog(
      "ធ្វើបច្ចុប្បន្នភាពស្ថានភាព", // Update Status
      confirmationMessage,
    );

    if (confirm == true) {
      _showLoadingDialog(loadingMessage);
      try {
        // Corrected URL to match the backend router: /orders/:id/status
        final url = "$kBaseUrl/orders/$orderId/status";
        final response = await http.put(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode({"status": newStatus}),
        );

        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(); // Dismiss loading dialog

        if (response.statusCode == 200) {
          _showSnackBar(successMessage);
          await fetchOrders(); // Refresh the list
        } else {
          String apiErrorMessage = errorMessage;
          try {
            final errorData = json.decode(response.body);
            apiErrorMessage = errorData["error"] ?? apiErrorMessage;
          } catch (_) {
            // Fallback if response body is not JSON
          }
          _showSnackBar(apiErrorMessage, isError: true);
        }
      } catch (e) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(); // Dismiss loading dialog
        _showSnackBar("មានបញ្ហាបណ្តាញ: $e", isError: true); // Network error
      }
    }
  }

  Future<bool?> _showConfirmationDialog(String title, String content) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap a button to close
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Dismiss and return false
              child: const Text(
                "បោះបង់",
                style: TextStyle(color: Colors.red),
              ), // Cancel
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // Dismiss and return true
              child: const Text(
                "បញ្ជាក់",
                style: TextStyle(color: Colors.green),
              ), // Confirm
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
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
      case 'canceled': // Added 'canceled' status
        return Colors.red;
      case 'completed': // Added 'completed' status
        return Colors.blueGrey;
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
        title: const Text(
          "ការកក់របស់ខ្ញុំ",
          style: TextStyle(color: Colors.white),
        ), // My Orders
        backgroundColor: Colors.cyan,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? _emptyOrdersView()
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

  Widget _emptyOrdersView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            "អ្នកមិនទាន់មានការកក់ណាមួយទេ។", // You have no bookings yet.
            style: TextStyle(color: Colors.grey, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: fetchOrders,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              "ផ្ទុកឡើងវិញ", // Refresh
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel o) {
    // Determine if the order can be canceled
    final bool canCancel = o.status.toLowerCase() == 'pending';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row("បន្ទប់:", o.roomName), // Room:
            _row("ថ្ងៃចូល:", _formatDate(o.checkInDate)), // Check-in Date:
            _row("ថ្ងៃចេញ:", _formatDate(o.checkOutDate)), // Check-out Date:
            _row("ភ្ញៀវ:", o.guests.toString()), // Guests:
            _row("វិធីទូទាត់:", o.paymentMethod), // Payment Method:
            _row(
              "តម្លៃសរុប:",
              "\$${o.totalPrice.toStringAsFixed(2)}",
            ), // Total Price:
            _row("កក់នៅ:", _formatDate(o.createdAt)), // Booked On:
            _row(
              "ស្ថានភាព:",
              o.status,
              color: _getStatusColor(o.status),
            ), // Status:
            const Divider(height: 25, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button
                if (canCancel) // Only show cancel if pending
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(o.id, 'canceled'),
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text(
                      "បោះបង់", // Cancel
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                // Delete Button
                ElevatedButton.icon(
                  onPressed: () => _deleteOrder(o.id),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text(
                    "លុប", // Delete
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 15,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hotel_booking/screens/root_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> roomData;
  final String roomTypeName;

  const CheckoutPage({
    super.key,
    required this.roomData,
    required this.roomTypeName,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final List<String> _paymentMethods = [
    'PayPal',
    'ការផ្ទេរប្រាក់តាមធនាគារ', // Bank Transfer
  ];
  String? _selectedPaymentMethod;

  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 1));

  final TextEditingController _guestsController = TextEditingController(
    text: '2',
  ); // Default to 2 guests

  String _currentUserEmail = '';

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = _paymentMethods.first; // កំណត់វិធីទូទាត់ដំបូង
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserEmail = prefs.getString('email') ?? '';
    });
    if (_currentUserEmail.isEmpty) {
      _showSnackBar(
        "មិនមានព័ត៌មាន Email របស់អ្នកប្រើប្រាស់ទេ។ សូមព្យាយាម Login ឡើងវិញ។",
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _guestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate : _checkOutDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      helpText: isCheckIn
          ? 'ជ្រើសរើសថ្ងៃចូល'
          : 'ជ្រើសរើសថ្ងៃចេញ', // Select Check-in Date / Select Check-out Date
      cancelText: 'បោះបង់', // Cancel
      confirmText: 'បញ្ជាក់', // Confirm
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate.isBefore(_checkInDate)) {
            _checkOutDate = _checkInDate.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
          if (_checkInDate.isAfter(_checkOutDate)) {
            _checkInDate = _checkOutDate.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _createOrder(BuildContext context) async {
    if (_selectedPaymentMethod == null || _selectedPaymentMethod!.isEmpty) {
      _showSnackBar("សូមជ្រើសរើសវិធីសាស្រ្តទូទាត់។", isError: true);
      return;
    }

    if (_checkInDate.isAfter(_checkOutDate)) {
      _showSnackBar("ថ្ងៃចេញត្រូវតែធំជាងថ្ងៃចូល។", isError: true);
      return;
    }

    final int? guests = int.tryParse(_guestsController.text);
    if (guests == null || guests <= 0) {
      _showSnackBar("សូមបញ្ចូលចំនួនភ្ញៀវត្រឹមត្រូវ។", isError: true);
      return;
    }

    if (_currentUserEmail.isEmpty) {
      _showSnackBar(
        "មិនមានព័ត៌មាន Email របស់អ្នកប្រើប្រាស់ទេ។ សូម Login ឡើងវិញ។",
        isError: true,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("កំពុងដំណើរការទូទាត់..."),
          ],
        ),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/api/orders"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "roomId": widget.roomData["id"],
          "roomName": widget.roomData["name"],
          "roomTypeId": widget.roomData["roomTypeId"] ?? "",
          "checkInDate": _checkInDate.toIso8601String().split('T').first,
          "checkOutDate": _checkOutDate.toIso8601String().split('T').first,
          "guests": guests,
          "totalPrice": _getPriceAsDouble(),
          "paymentMethod": _selectedPaymentMethod,
          "status": "pending",
          "userId": _currentUserEmail,
        }),
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 201) {
        _showSnackBar("ការទូទាត់បានជោគជ័យ! ការបញ្ជាទិញត្រូវបានបង្កើត។");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const RootApp()),
          (route) => false,
        );
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData["error"] ?? "មានបញ្ហាដែលមិនស្គាល់!";
        } catch (_) {
          errorMessage = response.body;
        }

        print("API Error Response: ${response.statusCode} - $errorMessage");
        _showSnackBar("បរាជ័យ: $errorMessage", isError: true);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print("Network Error: $e");
      _showSnackBar("មានបញ្ហា: $e", isError: true);
    }
  }

  double _getPriceAsDouble() {
    final price = widget.roomData['price'];
    if (price is num) {
      return price.toDouble();
    } else if (price is String) {
      try {
        return double.parse(price);
      } catch (e) {
        print("Error parsing price string: $e");
        return 0.0;
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ការទូទាត់",
          style: TextStyle(color: Colors.white),
        ), // Checkout
        backgroundColor: Colors.deepPurple,
        leading: const BackButton(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingSummary(textTheme),
            const SizedBox(height: 20),
            _buildDateSelection(textTheme),
            const SizedBox(height: 20),
            _buildGuestsInput(textTheme), // New guests input widget
            const SizedBox(height: 20),
            _buildPaymentMethod(textTheme),
            const SizedBox(height: 20),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _createOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "ទូទាត់ឥឡូវនេះ ${_getPriceAsDouble().toStringAsFixed(2)}\$", // Pay Now
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary(TextTheme textTheme) => Card(
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "សេចក្តីសង្ខេបការកក់", // Booking Summary
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const Divider(height: 25, thickness: 1),
          _summaryRow("បន្ទប់:", widget.roomData['name'] ?? 'N/A'), // Room:
          _summaryRow("ប្រភេទ:", widget.roomTypeName), // Type:
          _summaryRow(
            "តម្លៃ:",
            "${_getPriceAsDouble().toStringAsFixed(2)}\$",
          ), // Price:
        ],
      ),
    ),
  );

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    ),
  );

  Widget _buildDateSelection(TextTheme textTheme) => Card(
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "កាលបរិច្ឆេទស្នាក់នៅ", // Stay Dates
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const Divider(height: 25, thickness: 1),
          _buildDateRow(
            "ថ្ងៃចូល:", // Check-in Date:
            _checkInDate,
            () => _selectDate(context, true),
          ),
          const SizedBox(height: 10),
          _buildDateRow(
            "ថ្ងៃចេញ:", // Check-out Date:
            _checkOutDate,
            () => _selectDate(context, false),
          ),
        ],
      ),
    ),
  );

  Widget _buildDateRow(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            Row(
              children: [
                Text(
                  "${date.day}/${date.month}/${date.year}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_today,
                  color: Colors.deepPurple,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestsInput(TextTheme textTheme) => Card(
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ចំនួនភ្ញៀវ", // Number of Guests
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const Divider(height: 25, thickness: 1),
          _textField(
            _guestsController,
            "ចំនួនភ្ញៀវ", // Number of Guests
            Icons.people,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    ),
  );

  Widget _buildPaymentMethod(TextTheme textTheme) => Card(
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "វិធីសាស្រ្តទូទាត់", // Payment Method
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const Divider(height: 25, thickness: 1),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPaymentMethod,
              isExpanded: true,
              icon: const Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.deepPurple,
              ),
              items: _paymentMethods
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 16)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedPaymentMethod = v),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    ),
  );
}

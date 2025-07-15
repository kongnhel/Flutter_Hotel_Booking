import 'package:flutter/material.dart';
import 'package:hotel_booking/screens/home.dart'; // Import HomePage
import 'package:hotel_booking/screens/root_app.dart'; // Import RootApp

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> roomData;

  const CheckoutPage({super.key, required this.roomData});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Dummy payment methods
  final List<String> _paymentMethods = [
    'Credit Card',
    'PayPal',
    'Bank Transfer',
  ];
  String? _selectedPaymentMethod;

  // Dummy form controllers for demonstration
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set a default payment method
    if (_paymentMethods.isNotEmpty) {
      _selectedPaymentMethod = _paymentMethods[0];
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to OrderPage
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Summary',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Room:', widget.roomData['name'] ?? 'N/A'),
                    _buildSummaryRow('Type:', widget.roomData['type'] ?? 'N/A'),
                    _buildSummaryRow(
                      'Price:',
                      widget.roomData['price'] ?? 'N/A',
                    ),
                    // Add more summary details like dates, guests, rooms if available
                    // For this example, we'll use placeholder values
                    _buildSummaryRow('Check-in:', '20/07/24'),
                    _buildSummaryRow('Check-out:', '25/07/24'),
                    _buildSummaryRow('Guests:', '2'),
                    _buildSummaryRow('Rooms:', '1'),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.roomData['price'] ??
                              'N/A', // Using room price as total for simplicity
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method Selection
            Text(
              'Payment Method',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedPaymentMethod,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    hint: const Text('Select Payment Method'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPaymentMethod = newValue;
                      });
                    },
                    items: _paymentMethods.map<DropdownMenuItem<String>>((
                      method,
                    ) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Credit Card Details (Conditional based on selected method)
            if (_selectedPaymentMethod == 'Credit Card') ...[
              Text(
                'Card Details',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        _cardNumberController,
                        'Card Number',
                        Icons.credit_card,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _expiryDateController,
                              'Expiry Date (MM/YY)',
                              Icons.calendar_today,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              _cvvController,
                              'CVV',
                              Icons.lock,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _cardHolderNameController,
                        'Cardholder Name',
                        Icons.person,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Simulate payment processing
                  _processPayment(context, widget.roomData);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Pay Now ${widget.roomData['price'] ?? ''}',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
    );
  }

  void _processPayment(BuildContext context, Map<String, dynamic> room) {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing Payment..."),
            ],
          ),
        );
      },
    );

    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      // Check if the widget is still mounted before performing UI operations
      if (!mounted) {
        // If the widget is no longer in the tree, do not attempt to update UI
        return;
      }

      // Dismiss the loading dialog using its specific context
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop(); // Use rootNavigator to ensure dialog is popped

      // Show a SnackBar for payment success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful for ${room['name']}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to the RootApp and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const RootApp(), // Navigate to RootApp
        ),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    });
  }
}

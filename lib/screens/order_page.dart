import 'package:flutter/material.dart';
import 'package:hotel_booking/screens/check_out.dart';
import 'package:hotel_booking/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A page to display detailed information about a room and allow users to book it.
class OrderViewPage extends StatelessWidget {
  /// The data for the room to be displayed.
  final Map<String, dynamic> roomData;

  /// The human-readable name of the room type.
  final String roomTypeName; // Add this new field

  /// Creates an [OrderViewPage].
  /// The [roomData] is required and contains all the details of the room.
  /// The [roomTypeName] is required to display the friendly name of the room type.
  const OrderViewPage({
    super.key,
    required this.roomData,
    required this.roomTypeName, // Make it required in the constructor
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          roomData['name'] ?? 'Room Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'roomImage_${roomData['id']}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    roomData['image'] ??
                        'https://placehold.co/600x400/CCCCCC/000000?text=No+Image',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image Failed to Load',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roomData['name'] ?? 'N/A',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Use the roomTypeName directly here
                      _buildDetailRow(
                        icon: Icons.category_outlined,
                        label: "Type:",
                        value: roomTypeName, // Use the passed roomTypeName
                        style: textTheme.bodyLarge,
                        iconColor: Colors.grey[600],
                      ),
                      const SizedBox(height: 5),
                      _buildDetailRow(
                        icon: Icons.location_on_outlined,
                        label: "Location:",
                        value: roomData['location'] ?? 'N/A',
                        style: textTheme.bodyLarge,
                        iconColor: Colors.grey[600],
                      ),
                      const SizedBox(height: 5),
                      _buildDetailRow(
                        icon: Icons.star_rate_rounded,
                        label: "Rate:",
                        value: "${roomData['rate'] ?? 'N/A'}",
                        style: textTheme.bodyLarge,
                        iconColor: Colors.amber,
                      ),
                      const SizedBox(height: 5),
                      _buildDetailRow(
                        icon: Icons.attach_money,
                        label: "Price:",
                        value: "${roomData['price'] ?? 'N/A'}",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                        iconColor: Colors.green[700],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Description:",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        roomData['description'] ?? 'No description available.',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _confirmBooking(context, roomData),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Confirm Booking",
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
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? style,
    Color? iconColor,
  }) => Row(
    children: [
      Icon(icon, size: 18, color: iconColor ?? Colors.grey[600]),
      const SizedBox(width: 5),
      Text("$label $value", style: style),
    ],
  );

  void _confirmBooking(BuildContext context, Map<String, dynamic> room) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Your Booking"),
          content: Text(
            "Are you sure you want to book ${room['name']} for ${room['price']}?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                if (email == null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Login Required'),
                      content: const Text('Please login to continue.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(roomData: room),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}

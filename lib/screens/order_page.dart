import 'package:flutter/material.dart';
import 'package:hotel_booking/screens/check_out.dart';
import 'package:hotel_booking/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A page to display detailed information about a room and allow users to book it.
class OrderViewPage extends StatelessWidget {
  /// The data for the room to be displayed.
  final Map<String, dynamic> roomData;

  /// Creates an [OrderViewPage].
  ///
  /// The [roomData] is required and contains all the details of the room.
  const OrderViewPage({super.key, required this.roomData});

  @override
  Widget build(BuildContext context) {
    // Access the current theme's text styles for consistent typography.
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        // The title of the app bar, defaulting to 'Room Details' if room name is null.
        title: Text(
          roomData['name'] ?? 'Room Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Set the background color of the app bar.
        backgroundColor: Colors.blueGrey[800],
        // Leading icon button to navigate back.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the previous page.
          },
        ),
      ),
      // Use SingleChildScrollView to prevent overflow if content is too long.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero animation for a smooth transition of the room image.
              Hero(
                tag:
                    'roomImage_${roomData['id']}', // Unique tag is crucial for Hero.
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    // Display room image, with a fallback placeholder if the URL is null.
                    roomData['image'] ??
                        'https://placehold.co/600x400/CCCCCC/000000?text=No+Image',
                    height: 250, // Fixed height for the image.
                    width: double.infinity, // Image takes full available width.
                    fit: BoxFit.cover, // Cover the box with the image.
                    // Builder to show loading progress.
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
                    // Builder to show an error placeholder if image fails to load.
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
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
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20), // Spacing below the image.
              // Card to display room details in a structured manner.
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room Name
                      Text(
                        roomData['name'] ?? 'N/A',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Room Type
                      _buildDetailRow(
                        icon: Icons.category_outlined,
                        label: "Type:",
                        value: roomData['type'] ?? 'N/A',
                        style: textTheme.bodyLarge,
                        iconColor: Colors.grey[600],
                      ),
                      const SizedBox(height: 5),
                      // Room Location
                      _buildDetailRow(
                        icon: Icons.location_on_outlined,
                        label: "Location:",
                        value: roomData['location'] ?? 'N/A',
                        style: textTheme.bodyLarge,
                        iconColor: Colors.grey[600],
                      ),
                      const SizedBox(height: 5),
                      // Room Rate (Stars)
                      _buildDetailRow(
                        icon: Icons.star_rate_rounded,
                        label: "Rate:",
                        value: "${roomData['rate'] ?? 'N/A'}",
                        style: textTheme.bodyLarge,
                        iconColor: Colors.amber,
                      ),
                      const SizedBox(height: 5),
                      // Room Price
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
                      // Description Heading
                      Text(
                        "Description:",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Room Description
                      Text(
                        roomData['description'] ?? 'No description available.',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30), // Spacing before the button.
              // Confirm Booking Button
              SizedBox(
                width: double.infinity, // Button takes full width.
                child: ElevatedButton(
                  onPressed: () {
                    _confirmBooking(context, roomData); // Handle booking logic.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blueGrey[700], // Button background color.
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

  /// Helper method to build a consistent detail row with an icon, label, and value.
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? style,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? Colors.grey[600]),
        const SizedBox(width: 5),
        Text("$label $value", style: style),
      ],
    );
  }

  /// Displays a confirmation dialog and navigates based on user login status.
  void _confirmBooking(BuildContext context, Map<String, dynamic> room) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(
      'email',
    ); // Check for an existing email (or token).

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Your Booking"),
          content: Text(
            "Are you sure you want to book ${room['name']} for ${room['price']}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog.
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog first.

                if (email == null) {
                  // If not logged in, navigate to the LoginPage.
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                } else {
                  // If logged in, navigate to the CheckoutPage, passing room data.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(roomData: room),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ), // Green confirm button.
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}

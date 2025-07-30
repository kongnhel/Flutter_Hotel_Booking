import 'package:flutter/material.dart';
import 'package:hotel_booking/screens/check_out.dart';
import 'package:hotel_booking/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderViewPage extends StatelessWidget {
  final Map<String, dynamic> roomData;
  final String roomTypeName; // <-- នេះជា roomTypeName ដែល OrderViewPage ទទួល

  const OrderViewPage({
    super.key,
    required this.roomData,
    required this.roomTypeName,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isRoomBooked = roomData['isBooked'] ?? false;

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
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildRoomDetailCard(textTheme),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isRoomBooked ? null : () => _confirmBooking(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRoomBooked
                      ? Colors.grey
                      : Colors.blueGrey[700],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isRoomBooked ? "បន្ទប់នេះបានកក់រួច" : "បញ្ជាក់ការកក់",
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

  Widget _buildRoomDetailCard(TextTheme textTheme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            _buildDetailRow(
              Icons.category_outlined,
              "ប្រភេទ:",
              roomTypeName, // <-- នេះជា roomTypeName ដែលបង្ហាញក្នុង OrderViewPage
              style: textTheme.bodyLarge,
            ),
            _buildDetailRow(
              Icons.location_on_outlined,
              "ទីតាំង:",
              roomData['location'] ?? 'N/A',
              style: textTheme.bodyLarge,
            ),
            _buildDetailRow(
              Icons.star_rate_rounded,
              "អត្រា:",
              "${roomData['rate'] ?? 'N/A'}",
              style: textTheme.bodyLarge,
              iconColor: Colors.amber,
            ),
            _buildDetailRow(
              Icons.attach_money,
              "តម្លៃ:",
              "${roomData['price'] ?? 'N/A'}",
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
              iconColor: Colors.green[700],
            ),
            const SizedBox(height: 15),
            Text(
              "ការពិពណ៌នា:",
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
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    TextStyle? style,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? Colors.grey[600]),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              "$label $value",
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userEmail = prefs.getString('email');

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("បញ្ជាក់ការកក់របស់អ្នក"),
            content: Text(
              "តើអ្នកប្រាកដជាចង់កក់ ${roomData['name']} ក្នុងតម្លៃ ${roomData['price']} ទេ?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("បោះបង់"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.of(dialogContext).pop();

                  if (userEmail == null || userEmail.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('តម្រូវឱ្យ Login'),
                        content: const Text('សូម Login ដើម្បីបន្ត។'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text('យល់ព្រម'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutPage(
                          roomData: roomData,
                          roomTypeName:
                              roomTypeName, // ✅ កែប្រែត្រង់នេះ គឺបញ្ជូន roomTypeName ដែល OrderViewPage ទទួលបាន
                        ),
                      ),
                    );
                  }
                },
                child: const Text("បញ្ជាក់"),
              ),
            ],
          );
        },
      );
    }
  }
}

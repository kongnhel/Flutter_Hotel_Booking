import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/models/room_model.dart'; // Ensure this path is correct
import 'package:hotel_booking/screens/sidebar_screen/room/add_room.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

// IMPORTANT: Update this URL for production deployments!
const String kBaseUrl =
    'http://localhost:3000/api'; // Or 'http://10.0.2.2:3000/api' for Android Emulator

class RoomListScreen extends StatefulWidget {
  static const String id = '/RoomListScreen';

  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  List<Room> rooms = [];
  bool _isFetchingRooms = false; // Add a loading indicator state

  @override
  void initState() {
    super.initState();
    debugPrint('RoomListScreen: initState called.');
    fetchRooms();
  }

  /// Displays a SnackBar with the given [message] and [isError] status.
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color.fromRGBO(244, 67, 54, 1) // Red for error
            : Colors.green, // Green for success
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Fetches the list of rooms from the API.
  Future<void> fetchRooms() async {
    if (_isFetchingRooms) {
      debugPrint('RoomListScreen: Already fetching rooms, skipping.');
      return;
    }
    setState(() {
      _isFetchingRooms = true;
    });
    debugPrint('RoomListScreen: Starting fetchRooms...');
    try {
      final res = await http.get(Uri.parse('$kBaseUrl/rooms'));
      if (!mounted) {
        debugPrint(
          'RoomListScreen: fetchRooms completed, but widget is not mounted.',
        );
        return;
      }

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          rooms = data.map((e) => Room.fromJson(e)).toList();
          _isFetchingRooms = false;
        });
        debugPrint(
          'RoomListScreen: Successfully fetched ${rooms.length} rooms.',
        );
      } else {
        debugPrint(
          'RoomListScreen: Failed to fetch rooms, status: ${res.statusCode}, Body: ${res.body}',
        );
        _showSnackBar(
          'បរាជ័យក្នុងការផ្ទុកបន្ទប់។ ស្ថានភាព: ${res.statusCode}',
          isError: true,
        );
        setState(() {
          _isFetchingRooms = false;
        });
      }
    } catch (e) {
      debugPrint('RoomListScreen: Error fetching rooms: $e');
      _showSnackBar('កំហុសបណ្តាញពេលទាញយកបន្ទប់។', isError: true);
      setState(() {
        _isFetchingRooms = false;
      });
    }
  }

  /// Deletes a room by its [id].
  Future<void> deleteRoom(String? id) async {
    if (id == null) return;
    debugPrint('RoomListScreen: Attempting to delete room with ID: $id');

    final bool confirm =
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('បញ្ជាក់ការលុប'), // Confirm Deletion
              content: const Text(
                'តើអ្នកប្រាកដជាចង់លុបបន្ទប់នេះទេ?',
              ), // Are you sure you want to delete this room?
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    debugPrint('RoomListScreen: Delete cancelled by user.');
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('បោះបង់'), // Cancel
                ),
                TextButton(
                  onPressed: () {
                    debugPrint('RoomListScreen: Delete confirmed by user.');
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('លុប'), // Delete
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ), // Red color for delete
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirm) {
      return;
    }

    try {
      final res = await http.delete(Uri.parse('$kBaseUrl/rooms/$id'));

      if (!mounted) {
        debugPrint(
          'RoomListScreen: Delete operation completed, but widget is not mounted.',
        );
        return;
      }

      if (res.statusCode == 200) {
        _showSnackBar(
          'បន្ទប់ត្រូវបានលុបដោយជោគជ័យ',
        ); // Room deleted successfully
        debugPrint(
          'RoomListScreen: Room deleted successfully. Refreshing list...',
        );
        fetchRooms(); // Refresh the list after deletion
      } else {
        debugPrint('RoomListScreen: Delete failed: ${res.body}');
        _showSnackBar(
          'បរាជ័យក្នុងការលុបបន្ទប់។ ស្ថានភាព: ${res.statusCode}', // Failed to delete room. Status:
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('RoomListScreen: Delete error: $e');
      _showSnackBar(
        'កំហុសបណ្តាញ។ បរាជ័យក្នុងការលុបបន្ទប់។',
        isError: true,
      ); // Network error. Failed to delete room.
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'RoomListScreen: build method called. _isFetchingRooms: $_isFetchingRooms, Rooms count: ${rooms.length}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'បញ្ជីបន្ទប់អ្នកគ្រប់គ្រង', // Room List Admin
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.cyan, // Consistent app bar color
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ), // White icon for consistency
            tooltip: 'បន្ថែមបន្ទប់ថ្មី', // Add New Room
            onPressed: () async {
              debugPrint(
                'RoomListScreen: Navigating to AddRoomScreen to add new room.',
              );
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRoomScreen()),
              );
              debugPrint(
                'RoomListScreen: Returned from AddRoomScreen with result: $result',
              );
              if (result == true) {
                debugPrint(
                  'RoomListScreen: Add/Edit successful, calling fetchRooms().',
                );
                fetchRooms();
              } else {
                debugPrint(
                  'RoomListScreen: Add/Edit cancelled or failed, not refreshing.',
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchRooms,
          color: Colors.deepPurple, // Consistent refresh indicator color
          child:
              _isFetchingRooms // Show loading indicator if currently fetching
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple,
                    ), // Consistent loading color
                  ),
                )
              : rooms
                    .isEmpty // If not fetching and rooms are empty, show message
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'មិនទាន់មានបន្ទប់ត្រូវបានបន្ថែមនៅឡើយទេ។ ទាញចុះក្រោមដើម្បីធ្វើឱ្យស្រស់ ឬចុច "+" ដើម្បីបន្ថែម!', // No rooms added yet. Pull down to refresh or click "+" to add one!
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  // Otherwise, display the list
                  padding: const EdgeInsets.all(16),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4, // Increased elevation for better shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Rounded corners
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, // Increased horizontal padding
                          vertical: 12, // Increased vertical padding
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // More rounded image corners
                          child: Image.network(
                            room.image,
                            width: 80, // Larger image
                            height: 80, // Larger image
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40, // Larger icon
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          room.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18, // Larger title font
                            color: Colors.deepPurple, // Title color
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'តម្លៃ: \$${room.price}', // Price:
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'ប្រភេទ: ${room.roomTypeId}', // Type:
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'ទីតាំង: ${room.location}', // Location:
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              room.isBooked
                                  ? 'ស្ថានភាព: បានកក់' // Status: Booked
                                  : 'ស្ថានភាព: មាន', // Status: Available
                              style: TextStyle(
                                color: room.isBooked
                                    ? Colors.redAccent
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color:
                                    Colors.blueAccent, // Consistent edit color
                                size: 26, // Larger icon
                              ),
                              onPressed: () async {
                                debugPrint(
                                  'RoomListScreen: Navigating to AddRoomScreen to edit room ID: ${room.id}',
                                );
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddRoomScreen(
                                      roomToEdit: room,
                                    ), // Pass the room
                                  ),
                                );
                                debugPrint(
                                  'RoomListScreen: Returned from AddRoomScreen with result: $result',
                                );
                                if (result == true) {
                                  debugPrint(
                                    'RoomListScreen: Add/Edit successful, calling fetchRooms().',
                                  );
                                  fetchRooms();
                                } else {
                                  debugPrint(
                                    'RoomListScreen: Add/Edit cancelled or failed, not refreshing.',
                                  );
                                }
                              },
                              tooltip: 'កែសម្រួលបន្ទប់', // Edit Room
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color:
                                    Colors.redAccent, // Consistent delete color
                                size: 26, // Larger icon
                              ),
                              onPressed: room.id != null
                                  ? () => deleteRoom(room.id!)
                                  : null,
                              tooltip: 'លុបបន្ទប់', // Delete Room
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

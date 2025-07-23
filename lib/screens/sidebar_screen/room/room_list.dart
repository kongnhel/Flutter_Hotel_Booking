import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotel_booking/models/room_model.dart'; // Ensure this path is correct
import 'package:hotel_booking/screens/sidebar_screen/room/add_room.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint

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
            ? const Color.fromRGBO(244, 67, 54, 1)
            : Colors.green,
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
          'Failed to load rooms. Status: ${res.statusCode}',
          isError: true,
        );
        setState(() {
          _isFetchingRooms = false;
        });
      }
    } catch (e) {
      debugPrint('RoomListScreen: Error fetching rooms: $e');
      _showSnackBar('Network error while fetching rooms.', isError: true);
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
              title: const Text('Confirm Deletion'),
              content: const Text('Are you sure you want to delete this room?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    debugPrint('RoomListScreen: Delete cancelled by user.');
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    debugPrint('RoomListScreen: Delete confirmed by user.');
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Delete'),
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
        _showSnackBar('Room deleted successfully');
        debugPrint(
          'RoomListScreen: Room deleted successfully. Refreshing list...',
        );
        fetchRooms(); // Refresh the list after deletion
      } else {
        debugPrint('RoomListScreen: Delete failed: ${res.body}');
        _showSnackBar(
          'Failed to delete room. Status: ${res.statusCode}',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('RoomListScreen: Delete error: $e');
      _showSnackBar('Network error. Failed to delete room.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'RoomListScreen: build method called. _isFetchingRooms: $_isFetchingRooms, Rooms count: ${rooms.length}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room List Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Room',
            onPressed: () async {
              debugPrint(
                'RoomListScreen: Navigating to AddRoomScreen to add new room.',
              );
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRoomScreen()),
              );
              // This line is crucial. Check if it appears in your logs.
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
          child:
              _isFetchingRooms // Show loading indicator if currently fetching
              ? const Center(child: CircularProgressIndicator())
              : rooms
                    .isEmpty // If not fetching and rooms are empty, show message
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'No rooms added yet. Pull down to refresh or click "+" to add one!',
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
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            room.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          room.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: \$${room.price}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Type: ${room.roomTypeId}', // Display roomTypeId for now, or actual type name if available
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Location: ${room.location}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 24,
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
                              tooltip: 'Edit Room',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 24,
                              ),
                              onPressed: room.id != null
                                  ? () => deleteRoom(room.id!)
                                  : null,
                              tooltip: 'Delete Room',
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

// import 'dart:io'; // Used for File operations on non-web platforms
// import 'dart:typed_data'; // Used for Uint8List on web
// import 'dart:convert'; // Used for JSON encoding/decoding

// import 'package:flutter/foundation.dart'; // Used for kIsWeb
// import 'package:flutter/material.dart';
// import 'package:hotel_booking/models/room_model.dart'; // Ensure this path is correct
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:cloudinary_public/cloudinary_public.dart';

// // ---
// // Constants
// // ---
// // IMPORTANT: Update this URL for production deployments!
// // For Android Emulators, '10.0.2.2' maps to your host machine's localhost.
// // For iOS Simulators, 'localhost' or '127.0.0.1' usually works.
// // For physical devices, you'll need your machine's local IP address or a deployed backend URL.
// const String kBaseUrl =
//     'http://localhost:3000/api'; // Or 'http://10.0.2.2:3000/api' for Android Emulator

// class RoomAdminScreen extends StatefulWidget {
//   static const String id = '/RoomAdminScreen';

//   const RoomAdminScreen({super.key});

//   @override
//   State<RoomAdminScreen> createState() => _RoomAdminScreenState();
// }

// class _RoomAdminScreenState extends State<RoomAdminScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController();
//   final priceController = TextEditingController();
//   final locationController = TextEditingController();
//   final descriptionController = TextEditingController();

//   String? uploadedImageUrl;
//   String? _editingRoomId; // To keep track of the room being edited

//   // Cloudinary config
//   // Consider moving to environment variables for production
//   final String _cloudName = 'dlykpbl7s';
//   final String _uploadPreset = 'rooms_images';

//   String selectedType = 'Standard';
//   final List<String> types = const [
//     'Standard',
//     'Deluxe',
//     'Superior',
//     'Single Room',
//     'Double Room',
//     'Family Room',
//     'Queen Room',
//     'King Room',
//     'Bungalow',
//     'Single Villa',
//     'Apartment',
//   ];

//   String selectedLocation = 'Phnom Penh'; // Default selected location
//   final List<String> locations = const [
//     'Phnom Penh',
//     'Siem Reap',
//     'Battambang',
//     'Sihanoukville',
//     'Kampot',
//     'Kep',
//     'Koh Rong',
//     'Beanteay Meanchey',
//     '',
//   ];

//   List<Room> rooms = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchRooms();
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     priceController.dispose();
//     locationController.dispose();
//     descriptionController.dispose();
//     super.dispose();
//   }

//   /// Displays a SnackBar with the given [message] and [isError] status.
//   void _showSnackBar(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   /// Resets the form fields and clears any editing state.
//   void _resetForm() {
//     _formKey.currentState?.reset();
//     nameController.clear();
//     priceController.clear();
//     // locationController.clear();
//     descriptionController.clear();
//     setState(() {
//       uploadedImageUrl = null;
//       selectedType = 'Standard';
//       selectedLocation = 'Phnom Penh';
//       _editingRoomId = null; // Clear editing state
//     });
//   }

//   // ---
//   // Image Upload Logic
//   // ---
//   Future<String?> uploadImage(XFile pickedFile) async {
//     try {
//       if (kIsWeb) {
//         // Web platform upload using http.MultipartRequest
//         Uint8List bytes = await pickedFile.readAsBytes();

//         var request = http.MultipartRequest(
//           'POST',
//           Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
//         );
//         request.fields['upload_preset'] = _uploadPreset;
//         request.files.add(
//           http.MultipartFile.fromBytes(
//             'file',
//             bytes,
//             filename: pickedFile.name,
//           ),
//         );

//         var response = await request.send();
//         if (response.statusCode == 200) {
//           final resStr = await response.stream.bytesToString();
//           final jsonRes = jsonDecode(resStr);
//           return jsonRes['secure_url'];
//         } else {
//           final resStr = await response.stream.bytesToString();
//           debugPrint(
//             'Web Image Upload failed: ${response.statusCode}, Response: $resStr',
//           );
//           return null;
//         }
//       } else {
//         // Mobile/Desktop platform upload using cloudinary_public package
//         final cloudinary = CloudinaryPublic(_cloudName, _uploadPreset);
//         File file = File(pickedFile.path);

//         CloudinaryResponse res = await cloudinary.uploadFile(
//           CloudinaryFile.fromFile(
//             file.path,
//             folder:
//                 'flutter_hotel_booking_rooms', // Specify a folder on Cloudinary
//           ),
//         );

//         return res.secureUrl;
//       }
//     } catch (e) {
//       debugPrint('Image Upload Error: $e');
//       return null;
//     }
//   }

//   Future<void> handlePickUploadImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);

//     if (picked == null) {
//       _showSnackBar('No image selected.');
//       return;
//     }

//     _showSnackBar('Uploading image...');

//     final url = await uploadImage(picked);
//     debugPrint("Uploaded URL: $url");

//     if (!mounted) return;

//     if (url != null) {
//       setState(() {
//         uploadedImageUrl = url;
//       });
//       _showSnackBar('Image uploaded successfully!');
//     } else {
//       _showSnackBar('Failed to upload image. Please try again.', isError: true);
//     }
//   }

//   // ---
//   // API Calls
//   // ---
//   Future<void> fetchRooms() async {
//     try {
//       final res = await http.get(Uri.parse('$kBaseUrl/rooms'));
//       if (!mounted) return;

//       if (res.statusCode == 200) {
//         final List data = jsonDecode(res.body);
//         setState(() {
//           rooms = data.map((e) => Room.fromJson(e)).toList();
//         });
//       } else {
//         debugPrint(
//           'Failed to fetch rooms, status: ${res.statusCode}, Body: ${res.body}',
//         );
//         _showSnackBar(
//           'Failed to load rooms. Status: ${res.statusCode}',
//           isError: true,
//         );
//       }
//     } catch (e) {
//       debugPrint('Error fetching rooms: $e');
//       _showSnackBar('Network error while fetching rooms.', isError: true);
//     }
//   }

//   Future<void> saveRoom() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (uploadedImageUrl == null || uploadedImageUrl!.isEmpty) {
//       _showSnackBar('Please upload an image for the room.', isError: true);
//       return;
//     }

//     // Determine if we are adding or updating based on _editingRoomId
//     if (_editingRoomId == null) {
//       await _addRoom();
//     } else {
//       await _updateRoom(_editingRoomId!);
//     }
//   }

//   Future<void> _addRoom() async {
//     final newRoom = Room(
//       id: null,
//       name: nameController.text.trim(),
//       image: uploadedImageUrl!,
//       price: priceController.text.trim(),
//       type: selectedType,
//       rate: '4.5', // Default rate
//       location: selectedLocation ?? '',
//       isFavorited: false, // Default favorited status
//       albumImages: const [], // Empty album images for new room
//       description: descriptionController.text.trim(),
//     );

//     try {
//       final res = await http.post(
//         Uri.parse('$kBaseUrl/rooms'),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(
//           newRoom.toJson()..remove('id'),
//         ), // Don't send ID for new room
//       );

//       if (!mounted) return;

//       if (res.statusCode == 201) {
//         _showSnackBar('Room added successfully!');
//         _resetForm();
//         fetchRooms();
//       } else {
//         debugPrint(
//           'Failed to add room. Status: ${res.statusCode}, Body: ${res.body}',
//         );
//         _showSnackBar(
//           'Failed to add room. Status: ${res.statusCode}.',
//           isError: true,
//         );
//       }
//     } catch (e) {
//       debugPrint('Add room error: $e');
//       _showSnackBar(
//         'Network error. Failed to add room. Please try again.',
//         isError: true,
//       );
//     }
//   }

//   Future<void> _updateRoom(String id) async {
//     final updatedRoom = Room(
//       id: id,
//       name: nameController.text.trim(),
//       image: uploadedImageUrl!,
//       price: priceController.text.trim(),
//       type: selectedType,
//       rate: '4.5', // Keep default or fetch original if needed
//       // location: locationController.text.trim(),
//       location: selectedLocation,
//       isFavorited: false, // Keep default or fetch original if needed
//       albumImages: const [], // Keep empty or fetch original if needed
//       description: descriptionController.text.trim(),
//     );

//     try {
//       final res = await http.put(
//         Uri.parse('$kBaseUrl/rooms/$id'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(updatedRoom.toJson()),
//       );

//       if (!mounted) return;

//       if (res.statusCode == 200) {
//         _showSnackBar('Room updated successfully!');
//         _resetForm(); // Reset form after successful update
//         fetchRooms(); // Refresh list
//       } else {
//         debugPrint('Update failed: ${res.body}');
//         _showSnackBar(
//           'Failed to update room. Status: ${res.statusCode}',
//           isError: true,
//         );
//       }
//     } catch (e) {
//       debugPrint('Update error: $e');
//       _showSnackBar('Network error. Failed to update room.', isError: true);
//     }
//   }

//   Future<void> deleteRoom(String? id) async {
//     if (id == null) return;

//     try {
//       final res = await http.delete(Uri.parse('$kBaseUrl/rooms/$id'));

//       if (!mounted) return;

//       if (res.statusCode == 200) {
//         _showSnackBar('Room deleted successfully');
//         fetchRooms();
//       } else {
//         debugPrint('Delete failed: ${res.body}');
//         _showSnackBar(
//           'Failed to delete room. Status: ${res.statusCode}',
//           isError: true,
//         );
//       }
//     } catch (e) {
//       debugPrint('Delete error: $e');
//       _showSnackBar('Network error. Failed to delete room.', isError: true);
//     }
//   }

//   /// Populates the form fields with the data of the given [room] for editing.
//   void populateFormForEdit(Room room) {
//     setState(() {
//       _editingRoomId = room.id; // Set the ID of the room being edited
//       nameController.text = room.name;
//       priceController.text = room.price;
//       // locationController.text = room.location;
//       selectedLocation = room.location;

//       descriptionController.text = room.description;
//       uploadedImageUrl = room.image;
//       selectedType = room.type;
//     });
//     print('Room location for editing: ${room.location}');
//     print('Available locations in dropdown: $locations');

//     // Scroll to top for editing experience
//     if (_formKey.currentContext != null) {
//       Scrollable.ensureVisible(
//         _formKey.currentContext!,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   // ---
//   // UI Build
//   // ---
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Admin Room Manager')),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ---
//               // Add/Edit Room Form
//               // ---
//               Text(
//                 _editingRoomId == null ? 'Add New Room' : 'Edit Room',
//                 style: const TextStyle(
//                   fontSize: 24, // Slightly larger for section title
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextFormField(
//                       controller: nameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Room Name',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (val) =>
//                           val!.trim().isEmpty ? 'Room name is required' : null,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: priceController,
//                       keyboardType:
//                           TextInputType.number, // Ensure numeric input
//                       decoration: const InputDecoration(
//                         labelText: 'Price',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (val) {
//                         if (val!.trim().isEmpty) return 'Price is required';
//                         if (double.tryParse(val) == null) {
//                           return 'Enter a valid number for price';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Room Image',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     // Display uploaded image or placeholder
//                     uploadedImageUrl != null &&
//                             uploadedImageUrl!.startsWith("http")
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Image.network(
//                               uploadedImageUrl!,
//                               height: 120,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => const Icon(
//                                 Icons.broken_image,
//                                 size: 100,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           )
//                         : Container(
//                             height: 120,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.grey.shade400),
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 'No image selected',
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                             ),
//                           ),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: TextButton.icon(
//                         onPressed: handlePickUploadImage,
//                         icon: const Icon(Icons.cloud_upload),
//                         label: const Text('Upload Image'),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     DropdownButtonFormField<String>(
//                       value: selectedType,
//                       decoration: const InputDecoration(
//                         labelText: 'Room Type',
//                         border: OutlineInputBorder(),
//                       ),
//                       items: types.map((type) {
//                         return DropdownMenuItem<String>(
//                           value: type,
//                           child: Text(type),
//                         );
//                       }).toList(),
//                       onChanged: (val) {
//                         if (val != null) {
//                           setState(() => selectedType = val);
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     // TextFormField(
//                     //   controller: locationController,
//                     //   decoration: const InputDecoration(
//                     //     labelText: 'Location',
//                     //     border: OutlineInputBorder(),
//                     //   ),
//                     //   validator: (val) =>
//                     //       val!.trim().isEmpty ? 'Location is required' : null,
//                     // ),
//                     DropdownButtonFormField<String>(
//                       value: selectedLocation, // Set the current value
//                       decoration: const InputDecoration(
//                         labelText: 'Location',
//                         border: OutlineInputBorder(),
//                       ),
//                       items: locations.map((location) {
//                         return DropdownMenuItem<String>(
//                           value: location,
//                           child: Text(location),
//                         );
//                       }).toList(),
//                       onChanged: (val) {
//                         if (val != null) {
//                           setState(
//                             () => selectedLocation = val,
//                           ); // Update selectedLocation
//                         }
//                       },
//                       validator: (val) => val == null || val.isEmpty
//                           ? 'Location is required'
//                           : null,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: descriptionController,
//                       maxLines: 3, // Allow more lines for description
//                       decoration: const InputDecoration(
//                         labelText: 'Description',
//                         alignLabelWithHint:
//                             true, // Aligns label to top for multiline
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (val) => val!.trim().isEmpty
//                           ? 'Description is required'
//                           : null,
//                     ),
//                     const SizedBox(height: 24),
//                     SizedBox(
//                       width: double.infinity, // Make button full width
//                       child: ElevatedButton.icon(
//                         onPressed: saveRoom, // Use saveRoom for both add/edit
//                         icon: Icon(
//                           _editingRoomId == null ? Icons.add_home : Icons.save,
//                         ),
//                         label: Text(
//                           _editingRoomId == null ? 'Add Room' : 'Update Room',
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                     if (_editingRoomId != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: SizedBox(
//                           width: double.infinity,
//                           child: OutlinedButton.icon(
//                             onPressed: _resetForm,
//                             icon: const Icon(Icons.cancel),
//                             label: const Text('Cancel Edit'),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               // ---
//               // Room List Section
//               // ---
//               const Divider(
//                 height: 48,
//                 thickness: 1,
//               ), // More substantial divider
//               const Text(
//                 'Existing Rooms',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               if (rooms.isEmpty)
//                 const Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: Text(
//                       'No rooms added yet.',
//                       style: TextStyle(color: Colors.grey, fontSize: 16),
//                     ),
//                   ),
//                 )
//               else
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: rooms.length,
//                   itemBuilder: (context, index) {
//                     final room = rooms[index];
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       elevation: 2,
//                       child: ListTile(
//                         // Adjusted contentPadding for a bit more horizontal space
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 8,
//                         ),
//                         leading: ClipRRect(
//                           borderRadius: BorderRadius.circular(4),
//                           child: Image.network(
//                             room.image,
//                             width: 60, // Slightly reduced leading image width
//                             height: 60, // Slightly reduced leading image height
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => Container(
//                               width: 60,
//                               height: 60,
//                               color: Colors.grey[300],
//                               child: const Icon(
//                                 Icons.broken_image,
//                                 color: Colors.grey,
//                                 size: 30, // Adjust size for error icon
//                               ),
//                             ),
//                           ),
//                         ),
//                         title: Text(
//                           room.name,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                           maxLines: 1, // Limit title to a single line
//                           overflow: TextOverflow
//                               .ellipsis, // Add ellipsis if it overflows
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Price: ${room.price}',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             Text(
//                               'Type: ${room.type}',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             Text(
//                               'Location: ${room.location}',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.edit,
//                                 color: Colors.blue,
//                                 size: 24,
//                               ), // Explicit size
//                               onPressed: () => populateFormForEdit(room),
//                               tooltip:
//                                   'Edit Room', // Added tooltip for better UX
//                             ),
//                             // This is the delete button
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.delete,
//                                 color: Colors.red,
//                                 size: 24,
//                               ), // Explicit size
//                               onPressed: room.id != null
//                                   ? () => deleteRoom(room.id!)
//                                   : null,
//                               tooltip: 'Delete Room', // Added tooltip
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

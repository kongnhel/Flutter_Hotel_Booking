import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/models/room_model.dart'; // Ensure this path is correct
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

// IMPORTANT: Update this URL for production deployments!
const String kBaseUrl =
    'http://localhost:3000/api'; // Or 'http://10.0.2.2:3000/api' for Android Emulator

class AddRoomScreen extends StatefulWidget {
  static const String id = '/AddRoomScreen';
  final Room? roomToEdit; // Optional parameter for editing

  const AddRoomScreen({super.key, this.roomToEdit});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  String? uploadedImageUrl;
  String? _editingRoomId; // To keep track of the room being edited

  // Cloudinary config
  final String _cloudName = 'dlykpbl7s';
  final String _uploadPreset = 'rooms_images';

  // Store fetched room types from API
  List<Map<String, dynamic>> roomTypes = [];
  String? selectedRoomTypeId;

  String selectedLocation = 'Phnom Penh'; // Default selected location
  final List<String> locations = const [
    'Phnom Penh',
    'Siem Reap',
    'Battambang',
    'Sihanoukville',
    'Kampot',
    'Kep',
    'Koh Rong',
    'Beanteay Meanchey',
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('AddRoomScreen: initState called.');
    fetchRoomTypes().then((_) {
      // After room types are fetched, then populate form if editing
      if (widget.roomToEdit != null) {
        _editingRoomId = widget.roomToEdit!.id;
        nameController.text = widget.roomToEdit!.name;
        priceController.text = widget.roomToEdit!.price;
        descriptionController.text = widget.roomToEdit!.description;
        uploadedImageUrl = widget.roomToEdit!.image;
        selectedLocation = widget.roomToEdit!.location;

        // Set selectedRoomTypeId based on the room being edited
        selectedRoomTypeId = widget.roomToEdit!.roomTypeId;
        debugPrint(
          'AddRoomScreen: Populated form for editing room ID: $_editingRoomId, Type ID: $selectedRoomTypeId',
        );
      } else {
        // If adding a new room and no type is selected, default to the first available
        if (selectedRoomTypeId == null && roomTypes.isNotEmpty) {
          setState(() {
            selectedRoomTypeId = roomTypes[0]['id'];
            debugPrint(
              'AddRoomScreen: Defaulting selectedRoomTypeId to: ${selectedRoomTypeId}',
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    debugPrint('AddRoomScreen: dispose called.');
    super.dispose();
  }

  Future<void> fetchRoomTypes() async {
    debugPrint('AddRoomScreen: Starting fetchRoomTypes...');
    try {
      final res = await http.get(Uri.parse('$kBaseUrl/room_types'));
      if (!mounted) {
        debugPrint(
          'AddRoomScreen: fetchRoomTypes completed, but widget is not mounted.',
        );
        return;
      }
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          roomTypes = data
              .map<Map<String, dynamic>>(
                (e) => {'id': e['id'], 'name': e['name']},
              )
              .toList();

          // Ensure selectedRoomTypeId is valid after fetching types
          if (selectedRoomTypeId != null &&
              !roomTypes.any((type) => type['id'] == selectedRoomTypeId)) {
            // If the previously selected ID is no longer valid, reset it
            selectedRoomTypeId = null;
          }

          if (selectedRoomTypeId == null && roomTypes.isNotEmpty) {
            selectedRoomTypeId = roomTypes[0]['id'];
          }
          debugPrint(
            'AddRoomScreen: Successfully fetched ${roomTypes.length} room types. Selected: $selectedRoomTypeId',
          );
        });
      } else {
        debugPrint(
          'AddRoomScreen: Failed to fetch room types: ${res.statusCode}, Body: ${res.body}',
        );
        _showSnackBar('Failed to load room types.', isError: true);
      }
    } catch (e) {
      debugPrint('AddRoomScreen: Error fetching room types: $e');
      _showSnackBar('Network error while fetching room types.', isError: true);
    }
  }

  /// Displays a SnackBar with the given [message] and [isError] status.
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Resets the form fields and clears any editing state.
  void _resetForm() {
    _formKey.currentState?.reset();
    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    setState(() {
      uploadedImageUrl = null;
      selectedRoomTypeId = roomTypes.isNotEmpty ? roomTypes[0]['id'] : null;
      selectedLocation = 'Phnom Penh';
      _editingRoomId = null; // Clear editing state
    });
    debugPrint('AddRoomScreen: Form reset.');
  }

  // --- Image Upload Logic (same as before) ---
  Future<String?> uploadImage(XFile pickedFile) async {
    debugPrint('AddRoomScreen: Starting image upload...');
    try {
      if (kIsWeb) {
        Uint8List bytes = await pickedFile.readAsBytes();

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
        );
        request.fields['upload_preset'] = _uploadPreset;
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: pickedFile.name,
          ),
        );

        var response = await request.send();
        if (response.statusCode == 200) {
          final resStr = await response.stream.bytesToString();
          final jsonRes = jsonDecode(resStr);
          debugPrint(
            'AddRoomScreen: Image uploaded successfully (Web). URL: ${jsonRes['secure_url']}',
          );
          return jsonRes['secure_url'];
        } else {
          final resStr = await response.stream.bytesToString();
          debugPrint(
            'AddRoomScreen: Web Image Upload failed: ${response.statusCode}, Response: $resStr',
          );
          return null;
        }
      } else {
        final cloudinary = CloudinaryPublic(_cloudName, _uploadPreset);
        File file = File(pickedFile.path);

        final res = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path,
            folder: 'flutter_hotel_booking_rooms',
          ),
        );
        debugPrint(
          'AddRoomScreen: Image uploaded successfully (Mobile/Desktop). URL: ${res.secureUrl}',
        );
        return res.secureUrl;
      }
    } catch (e) {
      debugPrint('AddRoomScreen: Image Upload Error: $e');
      return null;
    }
  }

  Future<void> handlePickUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) {
      _showSnackBar('No image selected.');
      debugPrint('AddRoomScreen: No image selected.');
      return;
    }

    _showSnackBar('Uploading image...');

    final url = await uploadImage(picked);
    debugPrint("AddRoomScreen: Uploaded URL: $url");

    if (!mounted) return;

    if (url != null) {
      setState(() {
        uploadedImageUrl = url;
      });
      _showSnackBar('Image uploaded successfully!');
    } else {
      _showSnackBar('Failed to upload image. Please try again.', isError: true);
    }
  }

  // --- API Calls ---
  Future<void> saveRoom() async {
    debugPrint('AddRoomScreen: saveRoom called. Editing ID: $_editingRoomId');
    if (!_formKey.currentState!.validate()) {
      debugPrint('AddRoomScreen: Form validation failed.');
      return;
    }

    if (uploadedImageUrl == null || uploadedImageUrl!.isEmpty) {
      _showSnackBar('Please upload an image for the room.', isError: true);
      debugPrint('AddRoomScreen: No image uploaded.');
      return;
    }

    if (selectedRoomTypeId == null) {
      _showSnackBar('Please select a room type.', isError: true);
      debugPrint('AddRoomScreen: No room type selected.');
      return;
    }

    if (_editingRoomId == null) {
      await _addRoom();
    } else {
      await _updateRoom(_editingRoomId!);
    }
  }

  Future<void> _addRoom() async {
    debugPrint('AddRoomScreen: _addRoom called.');
    final newRoom = Room(
      id: null,
      name: nameController.text.trim(),
      image: uploadedImageUrl!,
      price: priceController.text.trim(),
      roomTypeId: selectedRoomTypeId!,
      rate: '4.5',
      location: selectedLocation,
      isFavorited: false,
      albumImages: const [],
      description: descriptionController.text.trim(),
    );

    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/rooms'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newRoom.toJson()..remove('id')),
      );

      if (!mounted) {
        debugPrint(
          'AddRoomScreen: _addRoom completed, but widget is not mounted.',
        );
        return;
      }

      if (res.statusCode == 201) {
        _showSnackBar('Room added successfully!');
        _resetForm();
        debugPrint(
          'AddRoomScreen: Room added successfully. Popping with true.',
        );
        Navigator.pop(context, true); // Pop with true to indicate success
      } else {
        debugPrint(
          'AddRoomScreen: Failed to add room. Status: ${res.statusCode}, Body: ${res.body}',
        );
        _showSnackBar(
          'Failed to add room. Status: ${res.statusCode}.',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('AddRoomScreen: Add room error: $e');
      _showSnackBar(
        'Network error. Failed to add room. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _updateRoom(String id) async {
    debugPrint('AddRoomScreen: _updateRoom called for ID: $id');
    final updatedRoom = Room(
      id: id,
      name: nameController.text.trim(),
      image: uploadedImageUrl!,
      price: priceController.text.trim(),
      roomTypeId: selectedRoomTypeId!,
      rate: '4.5',
      location: selectedLocation,
      isFavorited: false,
      albumImages: const [],
      description: descriptionController.text.trim(),
    );

    try {
      final res = await http.put(
        Uri.parse('$kBaseUrl/rooms/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedRoom.toJson()),
      );

      if (!mounted) {
        debugPrint(
          'AddRoomScreen: _updateRoom completed, but widget is not mounted.',
        );
        return;
      }

      if (res.statusCode == 200) {
        _showSnackBar('Room updated successfully!');
        _resetForm();
        debugPrint(
          'AddRoomScreen: Room updated successfully. Popping with true.',
        );
        Navigator.pop(context, true); // Pop with true to indicate success
      } else {
        debugPrint('AddRoomScreen: Update failed: ${res.body}');
        _showSnackBar(
          'Failed to update room. Status: ${res.statusCode}',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('AddRoomScreen: Update error: $e');
      _showSnackBar('Network error. Failed to update room.', isError: true);
    }
  }

  Future<void> _addRoomType(String name) async {
    debugPrint('AddRoomScreen: _addRoomType called with name: $name');
    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/room_types'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name}),
      );

      if (!mounted) {
        debugPrint(
          'AddRoomScreen: _addRoomType completed, but widget is not mounted.',
        );
        return;
      }

      if (response.statusCode == 201) {
        _showSnackBar('Room type added');
        debugPrint(
          'AddRoomScreen: Room type added successfully. Refreshing dropdown.',
        );
        await fetchRoomTypes(); // refresh the dropdown
      } else {
        debugPrint(
          'AddRoomScreen: Failed to add room type: ${response.statusCode}, Body: ${response.body}',
        );
        _showSnackBar('Failed to add room type.', isError: true);
      }
    } catch (e) {
      debugPrint('AddRoomScreen: Add room type error: $e');
      _showSnackBar('Network error. Please try again.', isError: true);
    }
  }

  void _showAddRoomTypeDialog() {
    final TextEditingController typeController = TextEditingController();
    debugPrint('AddRoomScreen: Showing Add Room Type dialog.');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Room Type'),
          content: TextField(
            controller: typeController,
            decoration: const InputDecoration(
              labelText: 'Room Type Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('AddRoomScreen: Add Room Type dialog cancelled.');
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = typeController.text.trim();
                if (name.isEmpty) {
                  debugPrint('AddRoomScreen: Room type name is empty.');
                  return;
                }
                Navigator.of(ctx).pop();
                await _addRoomType(name);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'AddRoomScreen: build method called. Selected Room Type ID: $selectedRoomTypeId',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingRoomId == null ? 'Add New Room' : 'Edit Room'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _editingRoomId == null
                    ? 'Add New Room Details'
                    : 'Edit Room Details',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Room Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val!.trim().isEmpty ? 'Room name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val!.trim().isEmpty) return 'Price is required';
                        if (double.tryParse(val) == null) {
                          return 'Enter a valid number for price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Room Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    uploadedImageUrl != null &&
                            uploadedImageUrl!.startsWith("http")
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              uploadedImageUrl!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: const Center(
                              child: Text(
                                'No image selected',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: handlePickUploadImage,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Upload Image'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedRoomTypeId,
                            decoration: const InputDecoration(
                              labelText: 'Room Type',
                              border: OutlineInputBorder(),
                            ),
                            items: roomTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type['id'],
                                child: Text(type['name']),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedRoomTypeId = val);
                                debugPrint(
                                  'AddRoomScreen: Selected Room Type ID: $val',
                                );
                              }
                            },
                            validator: (val) => val == null || val.isEmpty
                                ? 'Room type is required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          tooltip: 'Add Room Type',
                          onPressed: _showAddRoomTypeDialog,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedLocation,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      items: locations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedLocation = val);
                          debugPrint('AddRoomScreen: Selected Location: $val');
                        }
                      },
                      validator: (val) => val == null || val.isEmpty
                          ? 'Location is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val!.trim().isEmpty
                          ? 'Description is required'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: saveRoom,
                        icon: Icon(
                          _editingRoomId == null ? Icons.add_home : Icons.save,
                        ),
                        label: Text(
                          _editingRoomId == null ? 'Add Room' : 'Update Room',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_editingRoomId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              debugPrint(
                                'AddRoomScreen: Cancel Edit button pressed. Popping with false.',
                              );
                              _resetForm();
                              Navigator.pop(
                                context,
                                false,
                              ); // Pop without success
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancel Edit'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

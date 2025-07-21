import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Keep this as it might be used for base64 encoding
import 'package:cached_network_image/cached_network_image.dart'; // ADD THIS IMPORT
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Keep kIsWeb
import 'package:flutter/material.dart';
import 'package:hotel_booking/auth/login.dart';
import 'package:hotel_booking/models/user_model.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final String email;

  const ProfilePage({Key? key, required this.email}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _currentUser;
  File? _profileImageFile;
  String? _profileImageUrl; // Stores the Cloudinary URL or blob: URL for web
  XFile? _pickedWebImage; // Stores the XFile for web picked image

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController =
      TextEditingController(); // Added for email display

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose(); // Dispose email controller
    super.dispose();
  }

  /// Loads the user session from SharedPreferences and updates the UI.
  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(
        'user',
      ); // THIS IS THE SOURCE OF YOUR LOCAL USER DATA

      debugPrint('*** DEBUG: _loadUserSession started ***');
      debugPrint('*** DEBUG: Raw user JSON from SharedPreferences: $userJson');

      if (userJson != null) {
        final userMap = json.decode(userJson);

        debugPrint('*** DEBUG: User Map after JSON decode: $userMap');

        setState(() {
          _currentUser = UserModel.fromJson(
            userMap,
          ); // This parses the JSON into your UserModel

          debugPrint(
            '*** DEBUG: UserModel firstName loaded: ${_currentUser?.firstName}',
          );
          debugPrint(
            '*** DEBUG: UserModel lastName loaded: ${_currentUser?.lastName}',
          );
          debugPrint(
            '*** DEBUG: UserModel email loaded: ${_currentUser?.email}',
          );
          debugPrint(
            '*** DEBUG: UserModel phone loaded: ${_currentUser?.phone}',
          );
          debugPrint(
            '*** DEBUG: UserModel profileImage loaded: ${_currentUser?.profileImage}',
          );

          _firstNameController.text = _currentUser?.firstName ?? "";
          _lastNameController.text = _currentUser?.lastName ?? "";
          _phoneController.text = _currentUser?.phone ?? "";
          _emailController.text = _currentUser?.email ?? widget.email;
          _profileImageUrl =
              _currentUser?.profileImage; // Assign the profile image URL
        });
      } else {
        debugPrint(
          '*** DEBUG: No user JSON found in SharedPreferences. Defaulting email. ***',
        );
        setState(() {
          _emailController.text = widget.email;
        });
      }
      debugPrint('*** DEBUG: _loadUserSession finished ***');
    } catch (e) {
      _showSnackBar("Error loading user session: $e", isError: true);
      debugPrint("Error decoding user session: $e");
    }
  }

  /// Allows the user to pick an image from the gallery.
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _pickedWebImage = pickedFile;
          _profileImageFile = null;
          // For web, pickedFile.path gives a 'blob:' URL which can be displayed directly
          _profileImageUrl = pickedFile.path;
        } else {
          _profileImageFile = File(pickedFile.path);
          _profileImageUrl =
              null; // Clear network URL when local file is picked
          _pickedWebImage = null;
        }
      });
    }
  }

  /// Updates the user's profile, including phone number and profile image.
  Future<void> _updateProfile() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No logged-in user found.");
      }

      final token = await user.getIdToken();
      final Map<String, dynamic> requestBody = {
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "phone": _phoneController.text.trim(),
        // Email is usually updated separately due to re-authentication/verification
        // "email": _emailController.text.trim(), // DO NOT send email here directly without proper Firebase update
      };

      // Handle image upload based on platform and what was picked
      if (!kIsWeb && _profileImageFile != null) {
        final bytes = await _profileImageFile!.readAsBytes();
        requestBody["profileImage"] =
            "data:image/jpeg;base64,${base64Encode(bytes)}";
      } else if (kIsWeb && _pickedWebImage != null) {
        final bytes = await _pickedWebImage!.readAsBytes();
        requestBody["profileImage"] =
            "data:image/jpeg;base64,${base64Encode(bytes)}";
      } else if (_profileImageUrl != null &&
          _profileImageUrl!.startsWith('http')) {
        // If profileImage was from Cloudinary and not changed, send it back
        requestBody["profileImage"] = _profileImageUrl;
      }
      // If profileImage is null or empty, it won't be sent in the requestBody,
      // which means the backend should handle it as no change or removal.

      final response = await http.put(
        Uri.parse("http://localhost:3000/api/users/updateProfile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);

        // Update Firebase User's displayName if you want it to reflect full name
        // await user.updateDisplayName("${_firstNameController.text.trim()} ${_lastNameController.text.trim()}");

        if (_currentUser != null) {
          // Update the local user model with potentially new profileImage URL from backend
          _currentUser = _currentUser!.copyWith(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _phoneController.text.trim(),
            // email: _emailController.text.trim(), // Only update local model after successful Firebase email update
            profileImage:
                resBody['updatedFields']?['profileImage'] ??
                _currentUser!
                    .profileImage, // Get updated URL from response or retain old
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', json.encode(_currentUser!.toJson()));

          setState(() {
            _profileImageUrl = _currentUser!.profileImage; // Update display URL
            _profileImageFile =
                null; // Clear local file after successful upload
            _pickedWebImage =
                null; // Clear web picked file after successful upload
          });

          _showSnackBar("Profile updated successfully!");
        }
      } else {
        _showSnackBar("Update failed: ${response.body}", isError: true);
      }
    } catch (e) {
      _showSnackBar("Error updating profile: $e", isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Logs out the user from Firebase and clears local session data.
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('user');
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  /// Shows a Cupertino-style confirmation dialog for logging out.
  void _showConfirmLogout() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Theme(
          data: ThemeData.light(),
          child: CupertinoActionSheet(
            message: const Text("Would you like to log out?"),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  _logout();
                },
                isDestructiveAction: true,
                child: Text(
                  "Log Out",
                  style: TextStyle(color: AppColor.actionColor),
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ),
        ),
      ),
    );
  }

  /// Displays a SnackBar message to the user.
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  /// Handles changing the user's email address.
  Future<void> _showChangeEmailDialog() async {
    final TextEditingController _newEmailController = TextEditingController();
    final TextEditingController _currentPasswordController =
        TextEditingController(); // For re-auth
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Email"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _newEmailController,
                decoration: InputDecoration(
                  labelText: "New Email",
                  hintText: "Enter your new email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter new email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  hintText: "Confirm with your current password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop(); // Dismiss dialog
                setState(() => _isLoading = true);
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    throw Exception("No logged-in user.");
                  }

                  // 1. Re-authenticate user
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: _currentPasswordController.text,
                  );
                  await user.reauthenticateWithCredential(credential);

                  // 2. Update email in Firebase Auth
                  await user.updateEmail(_newEmailController.text.trim());

                  // 3. (Optional but recommended) Send email verification
                  await user.sendEmailVerification();

                  // 4. Update email in your backend (if needed)
                  final token = await user.getIdToken();
                  await http.put(
                    Uri.parse("http://localhost:3000/api/users/updateProfile"),
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token",
                    },
                    body: json.encode({
                      "email": _newEmailController.text.trim(),
                    }),
                  );

                  // 5. Update local user model and shared preferences
                  if (_currentUser != null) {
                    _currentUser = _currentUser!.copyWith(
                      email: _newEmailController.text.trim(),
                      // firstName and lastName should not be set to empty here unless you explicitly want to clear them
                      // firstName: '',
                      // lastName: '',
                    );
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                      'user',
                      json.encode(_currentUser!.toJson()),
                    );
                    setState(() {
                      _emailController.text = _currentUser!.email;
                    });
                  }

                  _showSnackBar(
                    "Email updated. Please check your new email for verification.",
                  );
                } on FirebaseAuthException catch (e) {
                  _showSnackBar(
                    "Failed to change email: ${e.message}",
                    isError: true,
                  );
                } catch (e) {
                  _showSnackBar("Error changing email: $e", isError: true);
                } finally {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }

  /// Handles changing the user's password.
  Future<void> _showChangePasswordDialog() async {
    final TextEditingController _currentPasswordController =
        TextEditingController();
    final TextEditingController _newPasswordController =
        TextEditingController();
    final TextEditingController _confirmNewPasswordController =
        TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Min 6 characters",
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _confirmNewPasswordController,
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop(); // Dismiss dialog
                setState(() => _isLoading = true);
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    throw Exception("No logged-in user.");
                  }

                  // 1. Re-authenticate user
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: _currentPasswordController.text,
                  );
                  await user.reauthenticateWithCredential(credential);

                  // 2. Update password in Firebase Auth
                  await user.updatePassword(_newPasswordController.text);

                  _showSnackBar("Password updated successfully!");
                } on FirebaseAuthException catch (e) {
                  _showSnackBar(
                    "Failed to change password: ${e.message}",
                    isError: true,
                  );
                } catch (e) {
                  _showSnackBar("Error changing password: $e", isError: true);
                } finally {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }

  /// Builds the user's profile display, showing avatar or initial with an edit icon.
  Widget _buildProfileAvatar() {
    final displayImageFile = _profileImageFile;
    final displayImageUrl = _profileImageUrl;

    ImageProvider<Object>? imageProvider;

    // Order of precedence for image display:
    if (displayImageFile != null && !kIsWeb) {
      imageProvider = FileImage(displayImageFile);
    } else if (kIsWeb &&
        displayImageUrl != null &&
        (displayImageUrl.startsWith('blob:') ||
            displayImageUrl.startsWith('data:'))) {
      imageProvider = NetworkImage(displayImageUrl);
    } else if (displayImageUrl != null && displayImageUrl.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(displayImageUrl);
    }

    // Determine initials for fallback
    String initials = "";
    if (_firstNameController.text.isNotEmpty) {
      initials += _firstNameController.text[0].toUpperCase();
    }
    if (_lastNameController.text.isNotEmpty) {
      initials += _lastNameController.text[0].toUpperCase();
    }
    if (initials.isEmpty && _emailController.text.isNotEmpty) {
      initials = _emailController.text[0].toUpperCase();
    }
    if (initials.isEmpty) {
      initials = "?";
    }

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          imageProvider != null
              ? CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color.fromARGB(
                    255,
                    15,
                    189,
                    27,
                  ).withOpacity(0.3),
                  backgroundImage: imageProvider,
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint('Error loading image: $exception');
                    setState(() {
                      _profileImageUrl = null;
                      _profileImageFile = null;
                      _pickedWebImage = null;
                    });
                  },
                )
              : CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color.fromARGB(
                    255,
                    15,
                    189,
                    27,
                  ).withOpacity(0.3),

                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 15, 189, 27),

                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the app bar with the "Profile" title and user role.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.appBarColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Profile",
            style: TextStyle(
              color: AppColor.textColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColor.labelColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentUser?.role == 'admin' ? 'Admin' : 'User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a generic setting item with an icon, title, and optional tap handler.
  Widget _buildSettingItem({
    required String title,
    required IconData leadingIcon,
    required Color leadingIconColor,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Icon(leadingIcon, color: leadingIconColor, size: 24),
        title: Text(
          title,
          style: TextStyle(
            color: AppColor.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey)
            : null,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: _buildProfileAvatar(),
            ),
            const SizedBox(height: 20),

            // First Name Field
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: "First Name",
                labelStyle: TextStyle(color: AppColor.labelColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.labelColor.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.primary, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: TextStyle(color: AppColor.textColor),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 15),

            // Last Name Field
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: "Last Name",
                labelStyle: TextStyle(color: AppColor.labelColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.labelColor.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.primary, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: TextStyle(color: AppColor.textColor),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 15),

            // Email Display Field (read-only)
            TextField(
              controller: _emailController,
              readOnly: true, // Email displayed here is read-only
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: AppColor.labelColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.labelColor.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.labelColor.withOpacity(0.5),
                    width: 2,
                  ), // Keep focused color same as enabled if readOnly
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: TextStyle(color: AppColor.textColor),
            ),
            const SizedBox(height: 15),

            // Phone Number Field
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: TextStyle(color: AppColor.labelColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.labelColor.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.primary, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: TextStyle(color: AppColor.textColor),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
                elevation: 5,
                shadowColor: AppColor.primary.withOpacity(0.4),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Update Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 30),

            // Setting Items
            // _buildSettingItem(
            //   title: "Change Email",
            //   leadingIcon: Icons.email_outlined,
            //   leadingIconColor: AppColor.orange, // Use a suitable color
            //   onTap: _showChangeEmailDialog,
            // ),
            _buildSettingItem(
              title: "Change Password",
              leadingIcon: Icons.lock_outline,
              leadingIconColor: AppColor.blue, // Use a suitable color
              onTap: _showChangePasswordDialog,
            ),
            _buildSettingItem(
              title: "General Setting",
              leadingIcon: Icons.settings,
              leadingIconColor: AppColor.orange,
              onTap: () {
                // TODO: Navigate to General Settings page
              },
            ),
            // Add Log Out button
            _buildSettingItem(
              title: "Log Out",
              leadingIcon: Icons.logout,
              leadingIconColor: Colors.redAccent, // Red color for logout
              onTap: _showConfirmLogout,
            ),
          ],
        ),
      ),
    );
  }
}

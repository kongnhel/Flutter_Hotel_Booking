import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  String? _profileImageUrl;
  XFile? _pickedWebImage;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userMap = json.decode(userJson);
        setState(() {
          _currentUser = UserModel.fromJson(userMap);
          _firstNameController.text = _currentUser?.firstName ?? "";
          _lastNameController.text = _currentUser?.lastName ?? "";
          _phoneController.text = _currentUser?.phone ?? "";
          _emailController.text = _currentUser?.email ?? widget.email;
          _profileImageUrl = _currentUser?.profileImage;
        });
      } else {
        setState(() {
          _emailController.text = widget.email;
        });
      }
    } catch (e) {
      _showSnackBar("កំហុសក្នុងការផ្ទុកវគ្គអ្នកប្រើប្រាស់: $e", isError: true);
    }
  }

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
          _profileImageUrl = pickedFile.path;
        } else {
          _profileImageFile = File(pickedFile.path);
          _profileImageUrl = null;
          _pickedWebImage = null;
        }
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("រកមិនឃើញអ្នកប្រើប្រាស់ដែលបានចូលទេ។");
      }

      final token = await user.getIdToken();
      final Map<String, dynamic> requestBody = {
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "phone": _phoneController.text.trim(),
      };

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
        requestBody["profileImage"] = _profileImageUrl;
      }

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

        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _phoneController.text.trim(),
            profileImage:
                resBody['updatedFields']?['profileImage'] ??
                _currentUser!.profileImage,
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', json.encode(_currentUser!.toJson()));

          setState(() {
            _profileImageUrl = _currentUser!.profileImage;
            _profileImageFile = null;
            _pickedWebImage = null;
          });

          _showSnackBar("ប្រវត្តិរូបត្រូវបានធ្វើបច្ចុប្បន្នភាពដោយជោគជ័យ!");
        }
      } else {
        _showSnackBar(
          "ការធ្វើបច្ចុប្បន្នភាពបរាជ័យ: ${response.body}",
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar(
        "កំហុសក្នុងការធ្វើបច្ចុប្បន្នភាពប្រវត្តិរូប: $e",
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  void _showConfirmLogout() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Theme(
          data: ThemeData.light(),
          child: CupertinoActionSheet(
            message: const Text("តើអ្នកចង់ចេញពីគណនីទេ?"),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  _logout();
                },
                isDestructiveAction: true,
                child: Text(
                  "ចេញពីគណនី",
                  style: TextStyle(color: AppColor.actionColor),
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("បោះបង់"),
            ),
          ),
        ),
      ),
    );
  }

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

  Future<void> _showChangeEmailDialog() async {
    final TextEditingController _newEmailController = TextEditingController();
    final TextEditingController _currentPasswordController =
        TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ប្ដូរអ៊ីមែល"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _newEmailController,
                decoration: InputDecoration(
                  labelText: "អ៊ីមែលថ្មី",
                  hintText: "បញ្ចូលអ៊ីមែលថ្មីរបស់អ្នក",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'សូមបញ្ចូលអ៊ីមែលថ្មី';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                    return 'បញ្ចូលអ៊ីមែលត្រឹមត្រូវ';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: "ពាក្យសម្ងាត់បច្ចុប្បន្ន",
                  hintText: "បញ្ជាក់ជាមួយនឹងពាក្យសម្ងាត់បច្ចុប្បន្នរបស់អ្នក",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'សូមបញ្ចូលពាក្យសម្ងាត់បច្ចុប្បន្នរបស់អ្នក';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("បោះបង់"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                setState(() => _isLoading = true);
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null)
                    throw Exception("រកមិនឃើញអ្នកប្រើប្រាស់ដែលបានចូលទេ។");

                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: _currentPasswordController.text,
                  );
                  await user.reauthenticateWithCredential(credential);
                  await user.updateEmail(_newEmailController.text.trim());
                  await user.sendEmailVerification();

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

                  if (_currentUser != null) {
                    _currentUser = _currentUser!.copyWith(
                      email: _newEmailController.text.trim(),
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
                    "អ៊ីមែលត្រូវបានធ្វើបច្ចុប្បន្នភាព។ សូមពិនិត្យអ៊ីមែលថ្មីរបស់អ្នកសម្រាប់ការផ្ទៀងផ្ទាត់។",
                  );
                } on FirebaseAuthException catch (e) {
                  _showSnackBar(
                    "បរាជ័យក្នុងការប្ដូរអ៊ីមែល: ${e.message}",
                    isError: true,
                  );
                } catch (e) {
                  _showSnackBar("កំហុសក្នុងការប្ដូរអ៊ីមែល: $e", isError: true);
                } finally {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: const Text("ប្ដូរ"),
          ),
        ],
      ),
    );
  }

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
        title: const Text("ប្ដូរពាក្យសម្ងាត់"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: "ពាក្យសម្ងាត់បច្ចុប្បន្ន",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'សូមបញ្ចូលពាក្យសម្ងាត់បច្ចុប្បន្នរបស់អ្នក';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: "ពាក្យសម្ងាត់ថ្មី",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "អក្សរយ៉ាងតិច ៦ តួ",
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6)
                    return 'ពាក្យសម្ងាត់ត្រូវតែមានយ៉ាងតិច ៦ តួអក្សរ';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _confirmNewPasswordController,
                decoration: InputDecoration(
                  labelText: "បញ្ជាក់ពាក្យសម្ងាត់ថ្មី",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'សូមបញ្ជាក់ពាក្យសម្ងាត់ថ្មីរបស់អ្នក';
                  if (value != _newPasswordController.text)
                    return 'ពាក្យសម្ងាត់មិនត្រូវគ្នាទេ';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("បោះបង់"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                setState(() => _isLoading = true);
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null)
                    throw Exception("រកមិនឃើញអ្នកប្រើប្រាស់ដែលបានចូលទេ។");

                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: _currentPasswordController.text,
                  );
                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(_newPasswordController.text);
                  _showSnackBar(
                    "ពាក្យសម្ងាត់ត្រូវបានធ្វើបច្ចុប្បន្នភាពដោយជោគជ័យ!",
                  );
                } on FirebaseAuthException catch (e) {
                  _showSnackBar(
                    "បរាជ័យក្នុងការប្ដូរពាក្យសម្ងាត់: ${e.message}",
                    isError: true,
                  );
                } catch (e) {
                  _showSnackBar(
                    "កំហុសក្នុងការប្ដូរពាក្យសម្ងាត់: $e",
                    isError: true,
                  );
                } finally {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: const Text("ប្ដូរ"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final displayImageFile = _profileImageFile;
    final displayImageUrl = _profileImageUrl;

    ImageProvider<Object>? imageProvider;

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

    String initials = "";
    if (_firstNameController.text.isNotEmpty)
      initials += _firstNameController.text[0].toUpperCase();
    if (_lastNameController.text.isNotEmpty)
      initials += _lastNameController.text[0].toUpperCase();
    if (initials.isEmpty && _emailController.text.isNotEmpty)
      initials = _emailController.text[0].toUpperCase();
    if (initials.isEmpty) initials = "?";

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
                    debugPrint('កំហុសក្នុងការផ្ទុករូបភាព: $exception');
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.appBarColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "ប្រវត្តិរូប",
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
              _currentUser?.role == 'admin'
                  ? 'អ្នកគ្រប់គ្រង'
                  : 'អ្នកប្រើប្រាស់',
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

            _buildTextField(
              controller: _firstNameController,
              labelText: "ឈ្មោះដំបូង",
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 15),

            _buildTextField(
              controller: _lastNameController,
              labelText: "នាមត្រកូល",
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 15),

            _buildTextField(
              controller: _emailController,
              labelText: "អ៊ីមែល",
              readOnly: true,
            ),
            const SizedBox(height: 15),

            _buildTextField(
              controller: _phoneController,
              labelText: "លេខទូរសព្ទ",
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cyan,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
                elevation: 5,
                shadowColor: AppColor.cyan.withOpacity(0.4),
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
                      "ធ្វើបច្ចុប្បន្នភាពប្រវត្តិរូប",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 30),

            _buildSettingItem(
              title: "ប្ដូរអ៊ីមែល",
              leadingIcon: Icons.email_outlined,
              leadingIconColor: Colors.blue,
              onTap: _showChangeEmailDialog,
            ),
            _buildSettingItem(
              title: "ប្ដូរពាក្យសម្ងាត់",
              leadingIcon: Icons.lock_outline,
              leadingIconColor: Colors.orange,
              onTap: _showChangePasswordDialog,
            ),
            _buildSettingItem(
              title: "ការកក់របស់ខ្ញុំ",
              leadingIcon: Icons.book_online,
              leadingIconColor: Colors.purple,
              onTap: () {
                // Navigate to OrdersScreen
                Navigator.pushNamed(context, '/ordersScreen');
              },
            ),
            _buildSettingItem(
              title: "ចេញពីគណនី",
              leadingIcon: Icons.logout,
              leadingIconColor: Colors.red,
              onTap: _showConfirmLogout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper method for consistent TextField styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: AppColor.labelColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColor.labelColor.withOpacity(0.5)),
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
      keyboardType: keyboardType,
    );
  }
}

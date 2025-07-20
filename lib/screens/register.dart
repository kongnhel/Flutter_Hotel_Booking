import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/models/user_model.dart';
import 'package:hotel_booking/screens/login.dart';
import 'package:hotel_booking/screens/root_app.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false; // To show loading indicator on button
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        final user = userCredential.user;
        if (user == null) throw Exception("User creation failed");

        // Get Firebase ID Token for backend API verification
        String? idToken = await user.getIdToken();

        // Prepare user profile data
        final profileData = {
          'id': user.uid,
          'email': user.email,
          'role': 'user',
          'canEdit': false,
          'canDelete': false,
          // បន្ថែម firstName, lastName ប្រសិនបើចង់
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
        };

        // Call your backend API to create user profile
        final response = await http.post(
          Uri.parse("http://localhost:3000/api/users/register"),
          headers: {
            "Content-Type": "application/json",
            "Authorization":
                "Bearer $idToken", // Pass token in header for security
          },
          body: json.encode(profileData),
        );

        final resBody = json.decode(response.body);

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registered successfully! Please login.")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed: ${resBody['error'] ?? response.body}"),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = "Registration failed.";
        if (e.code == 'email-already-in-use') {
          message = "This email is already in use.";
        } else if (e.code == 'weak-password') {
          message = "Password is too weak.";
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor, // Use your app's background color
      appBar: AppBar(
        backgroundColor: AppColor.appBarColor,
        elevation: 0,
        title: Text(
          "Register",
          style: TextStyle(color: AppColor.textColor, fontSize: 18),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Create Your Account",
                  style: TextStyle(
                    color: AppColor.textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                _buildTextFormField(
                  controller: _firstNameController,
                  labelText: "First Name",
                  hintText: "Enter your first name",
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildTextFormField(
                  controller: _lastNameController,
                  labelText: "Last Name",
                  hintText: "Enter your last name",
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildTextFormField(
                  controller: _emailController,
                  labelText: "Email",
                  hintText: "Enter your email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildPasswordFormField(
                  controller: _passwordController,
                  labelText: "Password",
                  hintText: "Enter your password",
                  isVisible: _isPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildPasswordFormField(
                  controller: _confirmPasswordController,
                  labelText: "Confirm Password",
                  hintText: "Re-enter your password",
                  isVisible: _isConfirmPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColor.primary, // Your primary button color
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColor.textColor, // Or white
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Register",
                          style: TextStyle(
                            color: AppColor.textColor, // Button text color
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: AppColor.labelColor,
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to the login page and remove all previous routes
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },

                      child: Text(
                        "Login /",
                        style: TextStyle(
                          color:
                              AppColor.primary, // Your primary color for links
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        // Navigate to the login page and remove all previous routes
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RootApp(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },

                      child: Text(
                        "Continue to page",
                        style: TextStyle(
                          color: const Color.fromARGB(
                            255,
                            44,
                            220,
                            41,
                          ), // Your primary color for links
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColor.labelColor),
        filled: true,
        fillColor:
            AppColor.appBarColor, // Use a lighter background for text fields
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // No border for a cleaner look
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColor.primary,
            width: 2,
          ), // Highlight on focus
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(color: AppColor.labelColor),
        hintStyle: TextStyle(color: AppColor.labelColor.withOpacity(0.7)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),
      ),
      style: TextStyle(color: AppColor.textColor),
      validator: validator,
    );
  }

  Widget _buildPasswordFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(Icons.lock_outline, color: AppColor.labelColor),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColor.labelColor,
          ),
          onPressed: toggleVisibility,
        ),
        filled: true,
        fillColor: AppColor.appBarColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColor.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(color: AppColor.labelColor),
        hintStyle: TextStyle(color: AppColor.labelColor.withOpacity(0.7)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),
      ),
      style: TextStyle(color: AppColor.textColor),
      validator: validator,
    );
  }
}

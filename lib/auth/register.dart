import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/models/user_model.dart'; // Make sure this path is correct
import 'package:hotel_booking/auth/login.dart'; // Assuming your LoginPage path
import 'package:hotel_booking/screens/root_app.dart'; // Assuming your RootApp path
import 'package:hotel_booking/theme/color.dart'; // Assuming AppColor is defined here
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

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

  /// Handles user registration, including Firebase Auth and backend API call.
  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Create user with Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        final user = userCredential.user;
        if (user == null) {
          throw Exception("User creation failed in Firebase.");
        }

        // Get Firebase ID Token for backend API verification
        String? idToken = await user.getIdToken();
        if (idToken == null) {
          throw Exception("Firebase ID Token not available.");
        }

        // 2. Prepare user profile data to send to your backend
        final Map<String, dynamic> profileData = {
          'id': user.uid,
          'email': user.email,
          'role': 'user', // Default role for new registrations
          'canEdit': true, // Assuming new users can edit their profile
          'canDelete':
              false, // Assuming new users cannot delete their own account initially
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phone':
              '', // Add a phone input field if you want to capture this at registration
          'profileImage': '', // Or provide a default placeholder image URL
        };

        debugPrint(
          'Sending profile data to backend: ${json.encode(profileData)}',
        );

        // 3. Call your backend API to create user profile in your database
        final response = await http.post(
          Uri.parse("http://localhost:3000/api/users/register"),
          headers: {
            "Content-Type": "application/json",
            "Authorization":
                "Bearer $idToken", // Pass token for backend verification
          },
          body: json.encode(profileData),
        );

        final resBody = json.decode(response.body);
        debugPrint(
          'Backend registration response status: ${response.statusCode}',
        );
        debugPrint('Backend registration response body: $resBody');

        if (response.statusCode == 201) {
          // Assuming your backend's /api/users/register returns the full created user object
          // For example: { "message": "User registered", "user": { ...full_user_data... } }
          final Map<String, dynamic>? userDataFromBackend = resBody['user'];

          UserModel newUserModel;
          if (userDataFromBackend != null) {
            newUserModel = UserModel.fromJson(userDataFromBackend);
            debugPrint('Successfully parsed UserModel from backend response.');
          } else {
            // Fallback: If backend doesn't return the full user data, construct it from input fields
            debugPrint(
              'Warning: Backend did not return full user data on registration success. Constructing from input.',
            );
            newUserModel = UserModel(
              id: user.uid,
              email: user.email!,
              role: 'user',
              canEdit: true,
              canDelete: false,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: '',
              profileImage: '',
            );
          }

          // 4. Save the complete UserModel to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', json.encode(newUserModel.toJson()));
          await prefs.setString(
            'email',
            newUserModel.email,
          ); // Also save email separately for convenience
          debugPrint(
            'User profile and email saved to SharedPreferences after registration.',
          );

          // 5. Show success message and navigate
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registered successfully! You can now log in."),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          // Backend returned an error status code
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Registration failed: ${resBody['error'] ?? 'Unknown error'}",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = "Registration failed.";
        if (e.code == 'email-already-in-use') {
          message = "This email is already in use.";
        } else if (e.code == 'weak-password') {
          message = "Password is too weak. Please choose a stronger one.";
        } else {
          message = "Firebase Auth Error: ${e.message}";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
        debugPrint('Firebase Auth Exception: $e');
      } catch (e) {
        // General errors (e.g., network issues, JSON decoding errors)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An unexpected error occurred: $e"),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('General Error during registration: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Helper to build consistent TextFormFields.
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

  /// Helper to build consistent password TextFormFields with visibility toggle.
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
                    backgroundColor: AppColor.cyan, // Your cyan button color
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5, // Added elevation
                    shadowColor: AppColor.cyan.withOpacity(
                      0.4,
                    ), // Subtle shadow
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors
                                .white, // Changed to white for better contrast on primary button
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Register",
                          style: TextStyle(
                            color: Colors
                                .white, // Changed to white for better contrast
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Text(
                        "Login", // Changed from "Login /" for clarity
                        style: TextStyle(
                          color: AppColor
                              .cyan, // Consistent primary color for links
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Removed "Continue to page" as it's confusing after registration
                    // and typically a user would log in after registering.
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

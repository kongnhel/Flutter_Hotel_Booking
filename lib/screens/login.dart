import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/material.dart'; // Core Flutter widgets
import 'package:hotel_booking/screens/home.dart'; // Assuming this is your main app home page
import 'package:hotel_booking/screens/root_app.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:http/http.dart' as http; // For making HTTP requests

import 'package:hotel_booking/screens/register.dart'; // For navigating to the registration page
// import 'package:hotel_booking/screens/root_app.dart'; // This import seems unused, removed for clarity
// import 'package:hotel_booking/theme/color.dart'; // This import is for your custom colors
import 'package:shared_preferences/shared_preferences.dart'; // For local data storage (e.g., user session)

// --- Placeholder for AppColor class ---
// You should replace this with your actual AppColor class from 'package:hotel_booking/theme/color.dart'
// This is included here to make the provided code runnable.

// --- End of AppColor Placeholder ---

/// A stateful widget for the user login page.
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // GlobalKey for the Form widget to validate input fields.
  final _formKey = GlobalKey<FormState>();
  // Text editing controllers for email and password input fields.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variables for managing UI feedback during login.
  bool _isLoading = false; // To show a loading indicator on the button
  bool _isPasswordVisible = false; // To toggle password visibility

  @override
  void dispose() {
    // Dispose controllers to free up resources when the widget is removed from the tree.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the user login process.
  ///
  /// It sends the email and password to the backend API,
  /// saves the user's email on successful login, and navigates
  /// to the home page or shows an error message.
  Future<void> _loginUser() async {
    // Validate form fields before proceeding with the login request.
    if (!_formKey.currentState!.validate()) {
      return; // If validation fails, stop the login process.
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final url = Uri.parse(
        "http://localhost:3000/api/users/login",
      ); // Your backend API endpoint
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": _emailController.text.trim(), // Trim whitespace from email
          "password": _passwordController.text
              .trim(), // Trim whitespace from password
        }),
      );

      final responseBody = json.decode(
        response.body,
      ); // Decode the JSON response
      if (response.statusCode == 200) {
        // Login successful
        final prefs = await SharedPreferences.getInstance();
        // Save the user's email for session management (consistent with OrderViewPage)
        await prefs.setString('email', responseBody['email']);

        // Navigate to the home page and replace the current route (prevent going back to login)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RootApp(initialEmail: responseBody['email']),
          ),
        );
      } else {
        // Login failed, show error message from the backend or a generic one
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseBody['error'] ?? "Login failed. Please try again.",
            ),
            backgroundColor: Colors.red, // Indicate error
          ),
        );
      }
    } catch (e) {
      // Handle network errors or other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Your Email or Password is incorrect!!"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColor.appBgColor, // Set background color from your theme
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(color: AppColor.textColor), // AppBar title style
        ),
        backgroundColor: AppColor.appBarColor, // AppBar background color
        elevation: 0, // Remove shadow for a flat look
      ),
      // The main content of the login page, centered and scrollable.
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey, // Assign the form key for validation
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretch children horizontally
              children: [
                // Welcome Back! text
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    color: AppColor.textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Sign in message
                Text(
                  "Sign in to continue to your account",
                  style: TextStyle(color: AppColor.labelColor, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Email Input Field
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

                // Password Input Field
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
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Forgot Password Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Forgot Password functionality coming soon!',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: AppColor.labelColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _loginUser, // Disable button while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColor.primary, // Button background color
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                      : Text(
                          "Login",
                          style: TextStyle(
                            color:
                                AppColor.textColor, // Text color for the button
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // Register Redirect Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: AppColor.labelColor,
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Register",
                        style: TextStyle(
                          color: AppColor
                              .primary, // Primary color for the register link
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

  /// Helper widget to build a standard text form field with consistent styling.
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
        fillColor: AppColor.appBarColor, // Background color for the input field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // No border line
        ),
        labelStyle: TextStyle(color: AppColor.labelColor),
        hintStyle: TextStyle(color: AppColor.labelColor.withOpacity(0.7)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),
      ),
      style: TextStyle(color: AppColor.textColor), // Text input color
      validator: validator, // Validator function for input validation
    );
  }

  /// Helper widget to build a password text form field with a toggle visibility icon.
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
      obscureText: !isVisible, // Hide text if not visible
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(Icons.lock_outline, color: AppColor.labelColor),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_off
                : Icons.visibility, // Toggle icon based on visibility
            color: AppColor.labelColor,
          ),
          onPressed: toggleVisibility, // Callback to change visibility state
        ),
        filled: true,
        fillColor: AppColor.appBarColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
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

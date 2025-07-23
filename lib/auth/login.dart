import 'dart:convert'; // For JSON encoding/decoding
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Core Flutter widgets
import 'package:hotel_booking/models/user_model.dart'; // User model definition
import 'package:hotel_booking/screens/root_app.dart'; // The main admin dashboard
import 'package:hotel_booking/theme/color.dart'; // Your app's custom color theme
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:hotel_booking/auth/register.dart'; // For navigating to the registration page
import 'package:shared_preferences/shared_preferences.dart'; // For local data storage (e.g., user session)

/// A stateful widget for the user login page.
/// This page allows users to enter their credentials and log in.
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

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Login with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user == null) throw Exception("User not found");

      // Get Firebase ID token
      String? idToken = await user.getIdToken();

      // Call your backend API to fetch user profile
      final response = await http.post(
        Uri.parse("http://localhost:3000/api/users/login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"idToken": idToken}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final userModel = UserModel.fromJson(responseBody);

        final prefs = await SharedPreferences.getInstance();

        // Save user model JSON and user email separately for session persistence
        await prefs.setString('user', json.encode(userModel.toJson()));
        await prefs.setString('email', user.email ?? '');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful! Welcome back, ${user.email}'),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RootApp()),
          );
        }
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['error'] ?? 'Login failed';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed. Please check your credentials.';
      if (e.code == 'user-not-found') message = 'No user found for that email.';
      if (e.code == 'wrong-password') message = 'Wrong password provided.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } on http.ClientException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Network error: Could not connect to the server. Please check your internet connection.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unexpected error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
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
                      ? null // Disable button while loading
                      : _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cyan, // Button background color
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
                              .cyan, // Primary color for the register link
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Removed the "Continue to Page" button as it bypasses login and is redundant
                    // with the main app's login check.
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

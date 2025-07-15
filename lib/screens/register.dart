import 'package:flutter/material.dart';
import 'package:hotel_booking/theme/color.dart';

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

      // --- Here you will integrate with Firebase Authentication ---
      // Example:
      // try {
      //   await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //     email: _emailController.text.trim(),
      //     password: _passwordController.text,
      //   );
      //   // If registration is successful, you might want to:
      //   // 1. Store additional user data in Firestore (first name, last name)
      //   //    e.g., FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({...});
      //   // 2. Navigate to the home page or a success screen
      //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootApp())); // Or your main app screen
      // } on FirebaseAuthException catch (e) {
      //   String message = 'An error occurred. Please try again.';
      //   if (e.code == 'weak-password') {
      //     message = 'The password provided is too weak.';
      //   } else if (e.code == 'email-already-in-use') {
      //     message = 'An account already exists for that email.';
      //   }
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      // } catch (e) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occurred.')));
      // } finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      // }
      // --- End of Firebase Integration example ---

      // For demonstration, simulate a delay
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration attempt for ${_emailController.text}'),
        ),
      );
      Navigator.pop(
        context,
      ); // Go back to login page after successful "registration"
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
                        Navigator.pop(context); // Go back to login page
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color:
                              AppColor.primary, // Your primary color for links
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

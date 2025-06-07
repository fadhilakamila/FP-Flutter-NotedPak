// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'login_page.dart';

class RegistrationPage extends StatefulWidget {
  // ignore: use_super_parameters
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordHidden = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildForm(),
                const SizedBox(height: 24),
                _buildCreateAccountButton(),
                const SizedBox(height: 16),
                _buildSignInLink(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4285F4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'In order to sync your notes to the cloud, you have to sign up/sign in to the app',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _fullNameController,
            labelText: 'Username',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            labelText: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
        floatingLabelStyle: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4285F4)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        if (labelText.contains('Email') &&
            !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _isPasswordHidden,
      decoration: InputDecoration(
        labelText: 'Password', // GANTI dari hintText ke labelText
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[500],
          ),
          onPressed: () {
            setState(() {
              _isPasswordHidden = !_isPasswordHidden;
            });
          },
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4285F4)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            _showEmailVerificationDialog();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4285F4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Create my account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmailVerificationDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 48,
                    color: Color(0xFF4285F4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Verify Email',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We have sent email verification to your email address',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4285F4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

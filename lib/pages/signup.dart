import 'package:energie_project/pages/login.dart';
import 'package:energie_project/pages/second.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordVisible = false;
  bool _isPrivacyPolicyChecked = false;
  bool _isLoading = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      _showErrorSnackBar('Firebase initialization failed: $e');
    }
  }

  // Validation Methods
  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  // Register User
  Future<void> _registerUser() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isPrivacyPolicyChecked) {
      _showErrorSnackBar('Please accept the Privacy Policy and User Agreement');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        await _saveUserDetailsToFirestore(user.uid);
        _navigateToSuccessPage();
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserDetailsToFirestore(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _showErrorSnackBar('Error saving user details: $e');
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String errorMessage = 'Registration failed';
    switch (e.code) {
      case 'weak-password':
        errorMessage = 'The password is too weak';
        break;
      case 'email-already-in-use':
        errorMessage = 'An account already exists with this email';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email address';
        break;
      default:
        errorMessage = e.message ?? 'An unexpected error occurred';
    }
    _showErrorSnackBar(errorMessage);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToSuccessPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SecondPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rest of the build method remains the same as the original code
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopNavigation(),
                  _buildWelcomeSection(),
                  const SizedBox(height: 30),
                  _buildFullNameField(),
                  const SizedBox(height: 20),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  _buildPrivacyPolicyCheckbox(),
                  const SizedBox(height: 20),
                  _buildRegisterButton(),
                  const SizedBox(height: 20),
                  _buildSocialLoginDivider(),
                  const SizedBox(height: 20),
                  _buildSocialLoginButtons(),
                  const SizedBox(height: 20),
                  _buildLoginLink(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // All the widget build methods remain the same as in the original code
  Widget _buildTopNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.grey[600])),
        IconButton(
            onPressed: () {},
            icon: Icon(Icons.help_outline, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return const Center(
      child: Column(
        children: [
          Text("Let's get started 👇",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Create an account to continue",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      validator: _validateFullName,
      decoration: _inputDecoration('Full Name'),
      keyboardType: TextInputType.name,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      validator: _validateEmail,
      decoration: _inputDecoration('Email'),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      validator: _validatePassword,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Password',
        fillColor: Colors.grey[200],
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      fillColor: Colors.grey[200],
      filled: true,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _buildPrivacyPolicyCheckbox() {
    return Row(
      children: [
        Checkbox(
            value: _isPrivacyPolicyChecked,
            onChanged: (value) {
              setState(() {
                _isPrivacyPolicyChecked = value ?? false;
              });
            }),
        Expanded(child: _buildPrivacyPolicyText()),
      ],
    );
  }

  Widget _buildPrivacyPolicyText() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black54),
        children: [
          const TextSpan(text: 'I agree to the '),
          TextSpan(
            text: 'Privacy Policy',
            style:
                TextStyle(color: Colors.pink[600], fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'User Agreement',
            style:
                TextStyle(color: Colors.pink[600], fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _registerUser,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor:
            _isPrivacyPolicyChecked ? Colors.amber[700] : Colors.grey,
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Register', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildSocialLoginDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('Or register with',
              style: TextStyle(color: Colors.grey[600])),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialButton('assets/go.svg'),
        _buildSocialButton('assets/fb.svg'),
        _buildSocialButton('assets/app.svg'),
      ],
    );
  }

  Widget _buildSocialButton(String assetPath) {
    return Container(
      height: 56,
      width: 56,
      decoration:
          BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
      child: Center(
        child: SvgPicture.asset(assetPath, height: 24, width: 24),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? ",
            style: TextStyle(color: Colors.black54)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
          },
          child: Text('Log In',
              style: TextStyle(
                  color: Colors.pink[600], fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

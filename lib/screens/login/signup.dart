import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home/HomePage.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Sign-up Method using Firebase
  Future<void> _signUp() async {
    try {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email and Password are required")),
        );
        return;
      }

      // Create user with email and password in Firebase Authentication
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to login page after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred during sign up";
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The email is already in use by another account.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE1BEE7), // Richer Light Purple
            Color(0xFFD1C4E9), // Deeper Lavender
            Color(0xFFB3E5FC), // Saturated Light Blue
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4C0B58)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Create Account",
          style: TextStyle(
            color: Color(0xFF4C0B58),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4C0B58).withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'lib/assets/images/login.png',
                      height: 240,
                      width: 240,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Full Name
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Full Name",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4C0B58),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: "Enter Your Name",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty)
                              ? "Name is required"
                              : null,
                ),

                const SizedBox(height: 20),

                // Email Address
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email Address",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4C0B58),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter Email Address",
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF4C0B58),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Email is required";
                    }
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
                    if (!emailRegex.hasMatch(v.trim())) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4C0B58),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Enter The Password",
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF4C0B58),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF4C0B58),
                      ),
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Password is required";
                    if (v.length < 6) return "Minimum 6 characters";
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Sign-Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _signUp(); // Sign up the user
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C0B58),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Sign Up"),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "By using Classroom, you agree to the\nTerms and Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

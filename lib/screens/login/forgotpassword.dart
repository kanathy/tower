import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase import
// Optional: OTP screen if you want a manual OTP approach

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  // Function to send the password reset link to the user's email
  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter an email")));
      return;
    }

    try {
      // Send password reset email using Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Navigate to OTP page (Optional, if you need OTP verification)

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent to $email")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4C0B58)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Reset Password",
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
          child: Column(
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'lib/assets/images/login.png',
                height: 300,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 50),

              // ── Email label & input ───────────────────────────────
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
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter Email Address",
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF4C0B58),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ── Send Reset Link button  →  Email reset link ───────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendResetLink, // Trigger the reset password link
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C0B58),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Send Reset Link"),
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                "A reset link has been sent to your email for verification.",
                style: TextStyle(fontSize: 12),
              ),

              const SizedBox(height: 40),
              const Text(
                "By using Classroom, you agree to the\nTerms and Privacy Policy.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:tower/screens/home/homepage.dart';
import 'package:tower/screens/login/signup.dart';
import 'package:tower/screens/login/forgotpassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tower/adminscreens/adminpanel/admin_dashboard_screen.dart';
import 'package:tower/adminscreens/verification/login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Firebase Login Method
  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    // Validate email before Firebase call
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password cannot be empty")));
      return;
    }

    try {
      // Sign in with Firebase Authentication
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Check if the user has verified their email
      // Refresh user object before checking verification
      await userCredential.user!.reload();
      final user = FirebaseAuth.instance.currentUser;
      /*
      if (user != null && !user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please verify your email first")),
        );
        // Optionally: show a button instead of sending automatically
        await user.sendEmailVerification();
        await FirebaseAuth.instance.signOut(); // prevent unverified login
        return;
      }
*/
      // Navigate to HomePage after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  // Check if the email format is valid using regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Log into account",
          style: TextStyle(
            color: Color(0xFF4C0B58),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'lib/assets/images/login.png', // asset path
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // Email -------------------------------------------------------
                const Text(
                  "Email Address",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4C0B58),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter email address",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty)
                              ? "Email is required"
                              : null,
                ),

                const SizedBox(height: 20),

                // Password ----------------------------------------------------
                const Text(
                  "Password",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4C0B58),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Password is required";
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Log-in button -----------------------------------------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login();
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
                    child: const Text("Log in"),
                  ),
                ),

                const SizedBox(height: 16),

                // Forgot password  (→ ResetPasswordScreen) --------------------
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ResetPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),

                // Sign-up link -------------------------------------------------
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Sign up Here",
                          style: const TextStyle(
                            color: Color(0xFF4C0B58),
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => const CreateAccountScreen(),
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Admin text ---------------------------------------------------
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "If you are the admin please ",
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Login Here",
                          style: const TextStyle(
                            color: Color(0xFF4C0B58),
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const AdminLoginScreen(),
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    "By using Classroom, you agree to the\nTerms and Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

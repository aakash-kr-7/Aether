import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:ui';

// Import backend dependencies
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import '../home/onboardingscreen.dart';
import 'register_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    var user = await _authService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      _showGlassToast("Login Failed! Check your credentials.");
    }
  }

  void _showGlassToast(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 30,
        right: 30,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _signInWithGoogle() async {
  setState(() => _isLoading = true);
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      setState(() => _isLoading = false);
      return; // User cancelled the sign-in process
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(user.uid);

      // Check if user exists in Firestore
      final docSnapshot = await userRef.get();
      if (!docSnapshot.exists) {
        // New user, set necessary fields
        await userRef.set({
          'onboardingComplete': false,  // Set to false for new users
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // If onboarding is not complete, navigate to OnboardingScreen
      bool onboardingComplete = docSnapshot.data()?['onboardingComplete'] ?? false;
      if (!onboardingComplete) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    }
  } catch (e) {
    print('Google Sign-In error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Google Sign-In failed. Try again."),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  Widget _buildTextField(TextEditingController controller, String labelText, bool obscureText, IconData icon) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white),
        ),
        fillColor: Colors.white.withOpacity(0.1),
        filled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimateGradient(
            primaryColors: [Colors.indigo, Colors.purple, Colors.blue],
            secondaryColors: [Colors.teal, Colors.cyan, Colors.deepPurple],
            duration: Duration(seconds: 6),
            child: Container(),
          ),
          Positioned(
            top: 75,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 300,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 180, left: 24, right: 24, bottom: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'hello friend...',
                              textStyle: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 28,
                              ),
                              speed: Duration(milliseconds: 150),
                            ),
                          ],
                          totalRepeatCount: 1,
                        ),
                        SizedBox(height: 30),
                        _buildTextField(emailController, "Email", false, Icons.email),
                        SizedBox(height: 15),
                        _buildTextField(passwordController, "Password", true, Icons.lock),
                        SizedBox(height: 25),
                        _isLoading
                            ? Center(child: CircularProgressIndicator(color: Colors.white))
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _login,
                                  child: Text(
                                    "Login",
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ),
                              ),
                        SizedBox(height: 10),
                        Center(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white70),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              icon: Image.asset(
                                'assets/images/google_icon.png', // make sure to add this asset!
                                height: 24,
                                width: 24,
                                ),
                                onPressed: _signInWithGoogle,
                                label: Text(
                                  "Continue with Google",
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
                                  ),
                                  ),
                                ),
                        SizedBox(height: 15),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RegisterScreen()),
                              );
                            },
                            child: Text(
                              "Don't have an account? Register",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
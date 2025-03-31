import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Signup Method
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email, // ✅ Store email for easy reference
          'onboardingComplete': false,
          'createdAt': FieldValue.serverTimestamp(), // ✅ Store sign-up timestamp
        });
      }
      return user;
    } catch (e) {
      print("Signup Error: $e");
      return null;
    }
  }

  // Login Method
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        DocumentReference userRef = _firestore.collection('users').doc(user.uid);

        DocumentSnapshot userDoc = await userRef.get();
        if (!userDoc.exists) {
          await userRef.set({
            'onboardingComplete': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } 
      }
      return user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // Logout Method
  Future<void> logout() async {
    await _auth.signOut();
  }
}

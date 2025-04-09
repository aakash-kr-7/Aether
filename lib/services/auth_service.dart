import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add this inside the AuthService class
  String? get currentUserId => _auth.currentUser?.uid;
  
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
          'email': email,
          'onboardingComplete': false,
          'createdAt': FieldValue.serverTimestamp(),
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

        // ✅ Ensure `onboardingComplete` exists without overwriting data
        await userRef.set({
          'onboardingComplete': userDoc.exists && userDoc.data() != null
              ? (userDoc.data() as Map<String, dynamic>)['onboardingComplete'] ?? false
              : false,
          'createdAt': userDoc.exists ? userDoc['createdAt'] : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? get currentUserId => _auth.currentUser?.uid;

  // ✅ Register User (No Email Verification)
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

  // ✅ Login Method
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

  // ✅ Google Sign-In Method
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentReference userRef = _firestore.collection('users').doc(user.uid);
        DocumentSnapshot userDoc = await userRef.get();

        await userRef.set({
          'email': user.email,
          'onboardingComplete': userDoc.exists && userDoc.data() != null
              ? (userDoc.data() as Map<String, dynamic>)['onboardingComplete'] ?? false
              : false,
          'createdAt': userDoc.exists ? userDoc['createdAt'] : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // ✅ Logout
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}

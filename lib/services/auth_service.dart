import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of User Auth State changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current auth user
  User? get currentUser => _auth.currentUser;

  // Login
  Future<User?> login(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // Register + Setup user profile in Firestore
  Future<User?> register(String email, String password, {String username = ''}) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Use clean name parsed from email if no username provided
        final String displayName = username.isNotEmpty 
            ? username 
            : email.split('@')[0];

        // Store user details in Firestore
        final UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          username: displayName,
          profilePictureUrl: 'https://api.dicebear.com/7.x/adventurer/png?seed=$displayName',
          bio: 'مرحباً بك في HM ليبيا!',
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve user info from Firestore
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign out
  Future<void> logout() async {
    await _auth.signOut();
  }
}

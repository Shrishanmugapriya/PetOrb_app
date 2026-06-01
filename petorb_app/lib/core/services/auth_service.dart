import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import '../../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static bool _firebaseInitialized = false;
  static fb.FirebaseAuth? _firebaseAuth;

  static Future<void> init() async {
    try {
      // Attempt Firebase initialization
      await Firebase.initializeApp();
      _firebaseAuth = fb.FirebaseAuth.instance;
      _firebaseInitialized = true;
      print("Firebase Auth Initialized successfully.");
    } catch (e) {
      print("Firebase initialization bypassed: $e. Using custom API Auth.");
    }
  }

  static bool get isFirebaseAvailable => _firebaseInitialized && _firebaseAuth != null;

  // Sign Up
  static Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String role, // 'owner' or 'sitter'
    String phone = '',
  }) async {
    String uid;

    if (isFirebaseAvailable) {
      try {
        final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        uid = credential.user!.uid;
        // Optionally update display name in Firebase
        await credential.user!.updateDisplayName(name);
      } catch (e) {
        throw Exception("Firebase Sign Up Failed: $e");
      }
    } else {
      // Fallback: Generate a developer UID
      uid = 'dev_uid_${email.replaceAll('@', '_').replaceAll('.', '_')}';
    }

    // Always register user in our MongoDB backend
    final response = await ApiService.post('/auth/register', {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'photo': 'https://api.dicebear.com/7.x/adventurer/png?seed=$name',
    });

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await ApiService.setToken(data['token']);
      return UserModel.fromJson(data['user']);
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['message'] ?? 'Failed to register on backend database.');
    }
  }

  // Sign In
  static Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    String uid;

    if (isFirebaseAvailable) {
      try {
        final credential = await _firebaseAuth!.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        uid = credential.user!.uid;
      } catch (e) {
        throw Exception("Firebase Sign In Failed: $e");
      }
    } else {
      // Fallback: Generate developer UID
      uid = 'dev_uid_${email.replaceAll('@', '_').replaceAll('.', '_')}';
    }

    // Log in on backend
    final response = await ApiService.post('/auth/login', {'uid': uid});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await ApiService.setToken(data['token']);
      return UserModel.fromJson(data['user']);
    } else if (response.statusCode == 404 && !isFirebaseAvailable) {
      // For developer demo, if the user doesn't exist, we auto-register them
      return await signUp(
        name: email.split('@')[0],
        email: email,
        password: password,
        role: 'owner', // Default to owner
      );
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['message'] ?? 'Authentication failed.');
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    if (isFirebaseAvailable) {
      await _firebaseAuth!.signOut();
    }
    await ApiService.clearToken();
  }

  // Forgot Password
  static Future<void> sendPasswordReset(String email) async {
    if (isFirebaseAvailable) {
      await _firebaseAuth!.sendPasswordResetEmail(email: email);
    } else {
      // Local demo delay simulator
      await Future.delayed(const Duration(seconds: 1));
      print("Password reset email simulated for $email");
    }
  }
}

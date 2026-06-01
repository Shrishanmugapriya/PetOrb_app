import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../core/services/auth_service.dart';
import '../core/services/api_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiService.init();
      if (ApiService.isAuthenticated) {
        final res = await ApiService.get('/auth/profile');
        if (res.statusCode == 200) {
          _currentUser = UserModel.fromJson(jsonDecode(res.body));
        } else {
          await ApiService.clearToken();
        }
      }
    } catch (e) {
      print("Check session error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await AuthService.signIn(email: email, password: password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String phone = '',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await AuthService.signUp(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photo,
    String? experience,
    String? bio,
    double? rate,
  }) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (photo != null) updateData['photo'] = photo;
      
      if (_currentUser!.role == 'sitter') {
        Map<String, dynamic> sitter = {};
        if (experience != null) sitter['experience'] = experience;
        if (bio != null) sitter['bio'] = bio;
        if (rate != null) sitter['rate'] = rate;
        if (sitter.isNotEmpty) updateData['sitterProfile'] = sitter;
      }

      final res = await ApiService.put('/auth/profile', updateData);
      if (res.statusCode == 200) {
        _currentUser = UserModel.fromJson(jsonDecode(res.body));
      } else {
        throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to update profile');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Developer Helper: Switch Role on the Fly to test Sitter vs Owner
  Future<void> devSwitchRole() async {
    if (_currentUser == null) return;
    final newRole = _currentUser!.role == 'owner' ? 'sitter' : 'owner';
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.put('/auth/profile', {'role': newRole});
      if (res.statusCode == 200) {
        _currentUser = UserModel.fromJson(jsonDecode(res.body));
      } else {
        // Fallback locally
        _currentUser = UserModel(
          uid: _currentUser!.uid,
          name: _currentUser!.name,
          email: _currentUser!.email,
          role: newRole,
          phone: _currentUser!.phone,
          photo: _currentUser!.photo,
          sitterProfile: _currentUser!.sitterProfile,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

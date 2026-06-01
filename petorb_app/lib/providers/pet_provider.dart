import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/pet_model.dart';
import '../core/services/api_service.dart';

class PetProvider extends ChangeNotifier {
  List<PetModel> _pets = [];
  PetModel? _selectedPet;
  bool _isLoading = false;

  List<PetModel> get pets => _pets;
  PetModel? get selectedPet => _selectedPet;
  bool get isLoading => _isLoading;

  void selectPet(PetModel? pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  Future<void> fetchPets() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/pets');
      if (res.statusCode == 200) {
        final List parsed = jsonDecode(res.body);
        _pets = parsed.map((x) => PetModel.fromJson(x)).toList();
        
        // Auto select first pet if none selected or if selected pet is not in the list anymore
        if (_pets.isNotEmpty) {
          if (_selectedPet == null || !_pets.any((p) => p.id == _selectedPet!.id)) {
            _selectedPet = _pets.first;
          } else {
            // Refresh selected pet details
            _selectedPet = _pets.firstWhere((p) => p.id == _selectedPet!.id);
          }
        } else {
          _selectedPet = null;
        }
      } else {
        _pets = [];
        _selectedPet = null;
      }
    } catch (e) {
      print("Fetch pets error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPet(PetModel pet) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/pets', pet.toJson());
      if (res.statusCode == 201) {
        final newPet = PetModel.fromJson(jsonDecode(res.body));
        _pets.add(newPet);
        if (_selectedPet == null) _selectedPet = newPet;
      } else {
        throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to add pet');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePet(String id, PetModel pet) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.put('/pets/$id', pet.toJson());
      if (res.statusCode == 200) {
        final updated = PetModel.fromJson(jsonDecode(res.body));
        final idx = _pets.indexWhere((p) => p.id == id);
        if (idx != -1) {
          _pets[idx] = updated;
        }
        if (_selectedPet?.id == id) {
          _selectedPet = updated;
        }
      } else {
        throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to update pet');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePet(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.delete('/pets/$id');
      if (res.statusCode == 200) {
        _pets.removeWhere((p) => p.id == id);
        if (_selectedPet?.id == id) {
          _selectedPet = _pets.isNotEmpty ? _pets.first : null;
        }
      } else {
        throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to delete pet');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

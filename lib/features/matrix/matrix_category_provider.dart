import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../../models/matrix_category.dart';

final matrixCategoryListProvider = StateNotifierProvider<MatrixCategoryListNotifier, List<MatrixCategory>>((ref) {
  return MatrixCategoryListNotifier();
});

final selectedMatrixCategoryIdProvider = StateProvider<String>((ref) {
  final categories = ref.watch(matrixCategoryListProvider);
  return categories.isNotEmpty ? categories.first.id : '';
});

class MatrixCategoryListNotifier extends StateNotifier<List<MatrixCategory>> {
  MatrixCategoryListNotifier() : super([]) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString('matrix_categories');
    if (categoriesJson != null) {
      final List<dynamic> decoded = json.decode(categoriesJson);
      state = decoded.map((e) => MatrixCategory.fromJson(e)).toList();
    }
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('matrix_categories', json.encode(state.map((e) => e.toJson()).toList()));
  }

  void addCategory(String name) {
    final category = MatrixCategory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    state = [...state, category];
    _saveCategories();
  }

  void updateCategory(String id, String newName) {
    state = state.map((category) {
      if (category.id == id) {
        return category.copyWith(name: newName);
      }
      return category;
    }).toList();
    _saveCategories();
  }

  void deleteCategory(String id) {
    state = state.where((category) => category.id != id).toList();
    _saveCategories();
  }
} 
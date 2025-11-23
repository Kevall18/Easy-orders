// lib/core/providers/search_provider.dart
import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  String get searchQuery => _searchQuery;
  TextEditingController get searchController => _searchController;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
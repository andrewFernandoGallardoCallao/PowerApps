import 'package:flutter/material.dart';

class FilterState with ChangeNotifier {
  String _selectedFilter = 'NombreAZ';

  String get selectedFilter => _selectedFilter;

  void setSelectedFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
}

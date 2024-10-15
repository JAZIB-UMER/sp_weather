import 'dart:async';
import 'package:flutter/material.dart';
import 'package:country_state_city/country_state_city.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CitySuggestionProvider extends ChangeNotifier {
  List<String> _citySuggestions = [];
  bool _isLoading = false;
  Timer? _debounce;
  String _lastSearchedCity = '';

  List<String> get citySuggestions => _citySuggestions;
  bool get isLoading => _isLoading;
  String get lastSearchedCity => _lastSearchedCity;

  Future<void> loadLastSearchedCity() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSearchedCity = prefs.getString('lastSearchedCity') ?? '';

    notifyListeners();
  }

  Future<void> saveCityToLocal(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSearchedCity', city);
    _lastSearchedCity = city;

    notifyListeners();
  }

  // Fetch city suggestions using the country_state_city package
  Future<void> fetchCitySuggestions(String query) async {
    // Cancel the previous debounce timer
    _debounce?.cancel();

    if (query.isEmpty) {
      clearSuggestions(); // Clear suggestions if query is empty
      return;
    }

    _isLoading = true;
    notifyListeners();

    // Set a debounce timer
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final cities = await getAllCities(); // Get the list of cities
        _citySuggestions = cities
            .where(
                (city) => city.name.toLowerCase().contains(query.toLowerCase()))
            .map((city) => city.name)
            .toList();
      } catch (error) {
        debugPrint('Error fetching city suggestions: $error');
        _citySuggestions = [];
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // Clear suggestions when needed
  void clearSuggestions() {
    _citySuggestions = [];
    notifyListeners();
  }
}

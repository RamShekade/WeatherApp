import 'dart:io'; // <-- Import this for SocketException
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherProvider with ChangeNotifier {
  WeatherModel? _weather;
  WeatherModel? get weather => _weather;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Fetch weather by city and store the city
  Future<void> getWeather(String city) async {
    _setLoading(true);
    try {
      _weather = await WeatherService.fetchWeather(city);
      _error = null;
      await _saveLastSearchedCity(city);
    } on SocketException {
      _error = 'No Internet Connection';
    } catch (e) {
      _error = 'Failed to fetch weather: ${e.toString()}';
    }
    _setLoading(false);
  }

  // Fetch weather using current location
  Future<void> getWeatherByLocation() async {
    _setLoading(true);
    try {
      final permission = await _handleLocationPermission();
      if (!permission) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _weather = await WeatherService.fetchWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      _error = null;
    } on SocketException {
      _error = 'No Internet Connection';
    } catch (e) {
      _error = 'Failed to fetch weather: ${e.toString()}';
    }
    _setLoading(false);
  }

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error = 'Location permission denied';
        _setLoading(false);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _error =
          'Location permission permanently denied. Please enable it in settings.';
      _setLoading(false);
      return false;
    }

    return true;
  }

  Future<void> _saveLastSearchedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_city', city);
  }

  Future<void> loadLastSearchedCityWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString('last_city');
    if (city != null && city.isNotEmpty) {
      await getWeather(city);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}

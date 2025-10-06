import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  final ApiService _apiService = ApiService();

  bool get isAuthenticated => _token != null && !JwtDecoder.isExpired(_token!);
  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null && !JwtDecoder.isExpired(_token!)) {
      _user = JwtDecoder.decode(_token!);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      _token = response['token'];
      _user = response['user'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    try {
      await _apiService.signup(email, password, name);
      return await login(email, password);
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
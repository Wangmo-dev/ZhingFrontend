import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role;
  String? _cid; // 👈 Add this

  /* GETTERS */
  String get token => _token ?? '';
  String get role => _role ?? 'user';
  String get cid => _cid ?? '';
  bool get isLoggedIn => _token != null;

  /* SETTERS */
  void setAuth({required String token, required String role, required String cid}) {
    _token = token;
    _role = role;
    _cid = cid;
    notifyListeners();
  }

  void clear() {
    _token = null;
    _role = null;
    _cid = null;
    notifyListeners();
  }
}

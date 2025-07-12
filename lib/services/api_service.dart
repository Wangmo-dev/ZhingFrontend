import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart'; // gives us XFile

class ApiService {
  // ─── Endpoints ──────────────────────────────────────────────────────────
  final String baseUrl = 'https://zhingscanserver.onrender.com'; // Node
  final String modelUrl =
      'https://dechok-zhingscan-model.hf.space'; // ML / HuggingFace

  /* ─────────────── AUTH ─────────────── */

  Future<Map<String, dynamic>> login({
    required String cid,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cid': cid, 'password': password}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return {
        'token': data['token'],
        'cid': data['user']['cid'],
        'userRole': data['user']['role'],
        'name': data['user']['name'],
      };
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<void> signup({
    required String cid,
    required String password,
    required String email,
    required String contact,
    required String dzongkhag,
    required String gewog,
    required String dob,
    required String role,
    required String name,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cid': cid,
        'name': name,
        'password': password,
        'email': email,
        'contact': contact,
        'dzongkhag': dzongkhag,
        'gewog': gewog,
        'dob': dob,
        'role': role,
      }),
    );

    if (res.statusCode != 201) {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Signup failed');
    }
  }

  /* ─────────────── PASSWORD / OTP ─────────────── */

  Future<void> sendOTP({required String email}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['error'] ?? 'Failed to send OTP');
    }
  }

  Future<void> verifyOTP({required String email, required String otp}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/verify-otp/$email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'otp': otp}),
    );

    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['error'] ?? 'OTP verification failed');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/reset-password/$email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['error'] ?? 'Password reset failed');
    }
  }

  /* ─────────────── PREDICT DISEASE ─────────────── */

  Future<Map<String, dynamic>> predictDisease(XFile image) async {
    final uri = Uri.parse('$modelUrl/predict');
    final req = http.MultipartRequest('POST', uri);

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      req.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: image.name,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else {
      req.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final res = await http.Response.fromStream(await req.send());

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      final data = jsonDecode(res.body);
      throw Exception(data['error'] ?? 'Prediction failed');
    }
  }

  /* ─────────────── UPLOAD SCAN ─────────────── */

  Future<Map<String, dynamic>> uploadScan({
    required XFile image,
    required String disease,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/api/scan');
    final req =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['disease'] = disease;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      req.files.add(
        http.MultipartFile.fromBytes(
          'plantImage',
          bytes,
          filename: image.name,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else {
      req.files.add(
        await http.MultipartFile.fromPath(
          'plantImage',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final res = await http.Response.fromStream(await req.send());

    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Upload failed: ${res.body}');
    }
  }

  /* ─────────────── FORWARD / GET SCANS ─────────────── */

  Future<Map<String, dynamic>> forwardScanToAdmin({
    required String scanId,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/api/scans/$scanId/forward');
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Forwarding failed: ${res.body}');
    }
  }

  Future<List<dynamic>> getForwardedScans({required String token}) async {
    final uri = Uri.parse('$baseUrl/api/scans?status=sent_to_admin');
    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to fetch forwarded scans');
    }
  }

  /* ─────────────── CURRENT USER ─────────────── */

  Future<Map<String, dynamic>> getCurrentUser({required String token}) async {
    final uri = Uri.parse('$baseUrl/api/auth/me');
    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to fetch current user');
    }
  }
}

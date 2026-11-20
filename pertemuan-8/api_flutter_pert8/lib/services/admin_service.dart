import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/assignment_config.dart';
import '../models/admin.dart';

// Service Admin dipisah dari ApiService khusus User.
class AdminService {
  static const String _storageKey = 'admins_json';
  static const String _fileName = 'admins.json';

  // Data awal untuk demonstrasi GET, GET by ID, dan DELETE.
  static List<Admin> _initialAdmins() => [
    Admin(
      id: AssignmentConfig.adminId,
      name: 'Admin Praktikum',
      email: 'admin.praktikum@example.com',
      department: 'Teknologi Informasi',
    ),
  ];

  // Ambil lokasi file untuk perangkat selain Web.
  static Future<io.File> _localFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return io.File('${directory.path}/$_fileName');
  }

  // Simpan JSON di browser atau file lokal perangkat.
  static Future<void> _saveAdmins(List<Admin> admins) async {
    final encoded = jsonEncode(admins.map((a) => a.toJson()).toList());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, encoded);

    if (!kIsWeb) {
      final file = await _localFile();
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(
          admins.map((a) => a.toJson()).toList(),
        ),
      );
    }
  }

  // Membaca data admin yang terakhir disimpan; membuat data awal jika belum ada.
  static Future<List<Admin>> _readAdmins() async {
    final prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(_storageKey);

    if (!kIsWeb) {
      final file = await _localFile();
      if (await file.exists()) {
        final fileContent = await file.readAsString();
        if (fileContent.trim().isNotEmpty) raw = fileContent;
      }
    }

    if (raw == null) {
      final initial = _initialAdmins();
      await _saveAdmins(initial);
      return initial;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Admin.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  // GET: ambil seluruh data Admin.
  static Future<List<Admin>> getAdmins() async {
    return _readAdmins();
  }

  // GET by ID: mencari satu Admin berdasarkan ID.
  static Future<Admin> getAdmin(int id) async {
    final admins = await _readAdmins();
    for (final admin in admins) {
      if (admin.id == id) return admin;
    }
    throw Exception('Admin dengan ID $id tidak ditemukan.');
  }

  // DELETE: menghapus Admin berdasarkan ID dan menyimpan perubahan.
  static Future<bool> deleteAdmin(int id) async {
    final admins = await _readAdmins();
    final before = admins.length;
    admins.removeWhere((admin) => admin.id == id);
    if (admins.length == before) return false;
    await _saveAdmins(admins);
    return true;
  }

  // Khusus demonstrasi: kembalikan Admin agar bisa diuji ulang.
  static Future<void> resetAdmins() async {
    await _saveAdmins(_initialAdmins());
  }
}
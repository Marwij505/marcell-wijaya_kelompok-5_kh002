import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

// Halaman GET by ID: menampilkan informasi User yang dipilih.
class UserDetailScreen extends StatelessWidget {
  final int userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail User'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        // GET satu User berdasarkan ID yang dipilih.
        future: ApiService.getUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat User: ${snapshot.error}'));
          }
          final data = snapshot.data;
          if (data == null) return const Center(child: Text('Data User kosong'));

          // JSON diubah ke Model User agar akses properti lebih mudah.
          final user = User.fromJson(data);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${user.id}'),
                      const SizedBox(height: 8),
                      Text('Nama: ${user.name}'),
                      const SizedBox(height: 8),
                      Text('Email: ${user.email}'),
                      const SizedBox(height: 8),
                      Text('Kota: ${user.city}'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../config/assignment_config.dart';
import '../models/admin.dart';
import '../services/admin_service.dart';

// Halaman untuk menampilkan daftar dan detail Admin.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<List<Admin>> _futureAdmins;

  @override
  void initState() {
    super.initState();
    _futureAdmins = AdminService.getAdmins();
  }

  // Muat ulang daftar sesudah menghapus atau mereset data.
  void _reload() {
    setState(() {
      _futureAdmins = AdminService.getAdmins();
    });
  }

  // GET by ID: ambil Admin pilihan dan tampilkan detailnya.
  Future<void> _showDetail(int id) async {
    try {
      final admin = await AdminService.getAdmin(id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Detail Admin (GET by ID)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText('ID: ${admin.id}'),
              SelectableText('Nama: ${admin.name}'),
              SelectableText('Email: ${admin.email}'),
              SelectableText('Departemen: ${admin.department}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(error.toString());
    }
  }

  // DELETE: meminta konfirmasi sebelum menghapus data.
  Future<void> _deleteAdmin(Admin admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Admin?'),
        content: Text('Yakin ingin menghapus ${admin.name} (ID ${admin.id})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      final success = await AdminService.deleteAdmin(admin.id);
      if (!mounted) return;
      _reload();
      _showSnackBar(success ? 'Admin berhasil dihapus' : 'ID Admin tidak ditemukan');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(error.toString());
    }
  }

  // Mengembalikan data Admin untuk percobaan berikutnya.
  Future<void> _resetAdmins() async {
    try {
      await AdminService.resetAdmins();
      if (!mounted) return;
      _reload();
      _showSnackBar('Data Admin dikembalikan untuk praktikum');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(error.toString());
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Admin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Reset data Admin',
            icon: const Icon(Icons.restore),
            onPressed: _resetAdmins,
          ),
        ],
      ),
      body: FutureBuilder<List<Admin>>(
        future: _futureAdmins,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Gagal mengambil Admin: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _reload, child: const Text('Coba Lagi')),
                ],
              ),
            );
          }

          final admins = snapshot.data ?? [];
          if (admins.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Data Admin kosong setelah dihapus.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _resetAdmins,
                    child: const Text('Pulihkan Data Admin'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Nilai N: ${AssignmentConfig.n} | '
                  'ID Admin: ${AssignmentConfig.adminId}'),
              const SizedBox(height: 12),
              for (final admin in admins)
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.admin_panel_settings)),
                    title: Text(admin.name),
                    subtitle: Text('ID ${admin.id} • ${admin.department}'),
                    onTap: () => _showDetail(admin.id),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Hapus Admin',
                      onPressed: () => _deleteAdmin(admin),
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Ketuk Admin untuk GET by ID. '
                    'Ketuk ikon sampah untuk DELETE berdasarkan ID.'),
              ),
            ],
          );
        },
      ),
    );
  }
}
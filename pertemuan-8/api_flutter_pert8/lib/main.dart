import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'services/api_service.dart';
import 'config/assignment_config.dart';
import 'models/user_model.dart';
import 'screens/admin_screen.dart';
import 'screens/user_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

// ==========================================
// MAIN APP
// ==========================================

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale locale = const Locale('id');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API Method Tester',
      locale: locale,

      supportedLocales: const [
        Locale('id'),
        Locale('en'),
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),

      home: HomeScreen(
        onLanguageChanged: (value) {
          setState(() {
            locale = Locale(value);
          });
        },
      ),
    );
  }
}

// ==========================================
// PAGE 1 - USER LIST
// ==========================================

class HomeScreen extends StatefulWidget {
  final Function(String) onLanguageChanged;

  const HomeScreen({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = ApiService.getUsers();
  }

  void refreshData() {
    setState(() {
      futureUsers = ApiService.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Method Tester'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        actions: [
          // Buka halaman Admin tanpa mengubah fitur User lama.
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Daftar Admin',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Lokasi File JSON',
            onPressed: () async {
              final path = await ApiService.getJsonFilePath();
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Penyimpanan File JSON'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data tersimpan secara permanen di file JSON lokal:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          path,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Setiap operasi Tambah (POST), Ubah (PUT/PATCH), dan Hapus (DELETE) langsung memperbarui file JSON ini.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset Data JSON ke Awal',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset Data JSON?'),
                  content: const Text(
                    'Apakah Anda yakin ingin mengembalikan data ke daftar awal?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ApiService.resetToDefault();
                refreshData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data JSON berhasil di-reset ke data awal'),
                    ),
                  );
                }
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: widget.onLanguageChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'id',
                child: Text('Bahasa Indonesia'),
              ),
              const PopupMenuItem(
                value: 'en',
                child: Text('English'),
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ApiTesterScreen(),
            ),
          ).then((_) => refreshData());
        },
        icon: const Icon(Icons.api),
        label: const Text('Test API'),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: futureUsers,

        builder: (context, snapshot) {

          // LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERROR
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),
                  const SizedBox(height: 12),
                  Text(language.errorMessage),
                  ElevatedButton(
                    onPressed: refreshData,
                    child: Text(language.retry),
                  ),
                ],
              ),
            );
          }

          // Data JSON diubah menjadi objek User melalui Model User.
          final users = (snapshot.data ?? [])
              .map((item) => User.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();

          if (users.isEmpty) {
            return Center(
              child: Text(language.noData),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              refreshData();
            },

            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,

              itemBuilder: (context, index) {
                final user = users[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0] : '?',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    title: Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(user.email),

                    // Detail User via GET by ID, sementara ketuk kartu
                    // tetap membuka halaman API Tester seperti sebelumnya.
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'Lihat detail User',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetailScreen(userId: user.id),
                        ),
                      ),
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApiTesterScreen(
                            initialId: user.id,
                          ),
                        ),
                      ).then((_) => refreshData());
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// PAGE 2 - API METHOD TESTER
// ==========================================

class ApiTesterScreen extends StatefulWidget {
  final int? initialId;

  const ApiTesterScreen({
    super.key,
    this.initialId,
  });

  @override
  State<ApiTesterScreen> createState() =>
      _ApiTesterScreenState();
}

class _ApiTesterScreenState extends State<ApiTesterScreen> {

  String selectedMethod = 'GET';

  final idController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = false;

  dynamic result;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    if (widget.initialId != null) {
      idController.text = widget.initialId.toString();
    }
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // ==========================================
  // SEND REQUEST
  // ==========================================

  Future<void> sendRequest() async {

    final id = int.tryParse(idController.text);

    // Validasi ID
    if (selectedMethod != 'POST' && id == null) {
      showMessage('Masukkan ID pengguna yang valid');
      return;
    }

    // Validasi nama (hanya untuk POST, PUT, dan PATCH)
    if (selectedMethod != 'GET' &&
        selectedMethod != 'DELETE' &&
        nameController.text.trim().isEmpty) {
      showMessage('Nama tidak boleh kosong');
      return;
    }

    // Validasi email untuk POST dan PUT
    if ((selectedMethod == 'POST' ||
        selectedMethod == 'PUT') &&
        emailController.text.trim().isEmpty) {
      showMessage('Email tidak boleh kosong');
      return;
    }

    setState(() {
      isLoading = true;
      result = null;
      errorMessage = null;
    });

    try {
      dynamic response;

      switch (selectedMethod) {

      // GET
        case 'GET':
          response = await ApiService.getUser(id!);
          break;

      // POST
        case 'POST':
          response = await ApiService.createUser(
            nameController.text.trim(),
            emailController.text.trim(),
          );
          break;

      // PUT
        case 'PUT':
          response = await ApiService.updateUser(
            id!,
            nameController.text.trim(),
            emailController.text.trim(),
          );
          break;

      // PATCH
        case 'PATCH':
          response = await ApiService.patchUser(
            id!,
            nameController.text.trim(),
          );
          break;

      // DELETE
        case 'DELETE':
          final success = await ApiService.deleteUser(id!);

          response = {
            'success': success,
            'message': success
                ? 'Pengguna berhasil dihapus'
                : 'Gagal menghapus pengguna',
          };
          break;
      }

      setState(() {
        result = response;
      });

    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });

    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ==========================================
  // SNACKBAR
  // ==========================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ==========================================
  // UI
  // ==========================================

  @override
  Widget build(BuildContext context) {

    final isGet = selectedMethod == 'GET';
    final isPost = selectedMethod == 'POST';
    final isPut = selectedMethod == 'PUT';
    final isPatch = selectedMethod == 'PATCH';
    final isDelete = selectedMethod == 'DELETE';

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Method Tester'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // HEADER
            const Text(
              'Request Configuration',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Pilih HTTP method dan masukkan data '
                  'yang ingin dikirim.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            // METHOD DROPDOWN
            const Text(
              'HTTP Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedMethod,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.api),
              ),

              items: const [
                DropdownMenuItem(
                  value: 'GET',
                  child: Text('GET - Retrieve Data'),
                ),
                DropdownMenuItem(
                  value: 'POST',
                  child: Text('POST - Create Data'),
                ),
                DropdownMenuItem(
                  value: 'PUT',
                  child: Text('PUT - Replace Data'),
                ),
                DropdownMenuItem(
                  value: 'PATCH',
                  child: Text('PATCH - Update Data'),
                ),
                DropdownMenuItem(
                  value: 'DELETE',
                  child: Text('DELETE - Remove Data'),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  selectedMethod = value!;
                  result = null;
                  errorMessage = null;
                });
              },
            ),

            const SizedBox(height: 20),

            // ID INPUT
            if (!isPost) ...[
              const Text(
                'User ID',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: 1',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),

              const SizedBox(height: 20),
            ],

            // NAME INPUT
            if (!isGet && !isDelete) ...[
              const Text(
                'Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan nama pengguna',
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 20),
            ],

            // EMAIL INPUT
            if (isPost || isPut) ...[
              const Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan email pengguna',
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 20),
            ],

            // INFORMATION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                isGet
                    ? 'GET: Mengambil data pengguna berdasarkan ID.'
                    : isPost
                    ? 'POST: Menambah User dengan ID ${AssignmentConfig.userId} (N = ${AssignmentConfig.n}).'
                    : isPut
                    ? 'PUT: Mengganti nama dan email pengguna.'
                    : isPatch
                    ? 'PATCH: Menambahkan teks - Flutter Developer ke nama User.'
                    : 'DELETE: Mengirim permintaan penghapusan pengguna.',
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // SEND BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed: isLoading ? null : sendRequest,

                icon: isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send),

                label: Text(
                  isLoading
                      ? 'Sending Request...'
                      : 'Send Request',
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // RESPONSE RESULT
            if (result != null || errorMessage != null) ...[
              const Text(
                'Response Result',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: errorMessage != null
                      ? Colors.red.withOpacity(0.08)
                      : Colors.green.withOpacity(0.08),

                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: errorMessage != null
                        ? Colors.red
                        : Colors.green,
                  ),
                ),

                child: SelectableText(
                  errorMessage != null
                      ? errorMessage!
                      : const JsonEncoder.withIndent('  ')
                      .convert(result),

                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'profile_card.dart';

void main() {
  // Menjalankan aplikasi Flutter.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget { // 7. statelesswidget
  const MyApp({super.key});

  // NIM mahasiswa.
  static const String nim = '20240801050';

  @override
  Widget build(BuildContext context) {
    // Mengambil digit terakhir dari NIM.
    final int digitTerakhir =
        int.parse(nim[nim.length - 1]);

    // Mengecek apakah digit terakhir ganjil atau genap.
    final bool nimGenap = digitTerakhir % 2 == 0;

    return MaterialApp(
      // Menghilangkan banner DEBUG.
      debugShowCheckedModeBanner: true,

      title: 'Profile Layout',

      // ========================================================
      // THEME APLIKASI
      // ========================================================
      theme: ThemeData(
        useMaterial3: true,

        // Jika digit terakhir NIM genap:
        // menggunakan warna Amber muda.
        //
        // Jika ganjil:
        // menggunakan warna Teal/Toska muda.
        scaffoldBackgroundColor: nimGenap
            ? Colors.amber.shade100 // 6. Warna Latar (Scaffold.BackgroundColor)
            : Colors.tealAccent.shade100,
      ),

      // Menampilkan halaman utama.
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget { // 7. statelesswidget
  const HomePage({super.key});

  // NIM digunakan sebagai dasar seluruh perhitungan.
  static const String nim = '20240801050';

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // PERHITUNGAN SKOR AKTIVITAS
    // ==========================================================

    // Mengambil 2 digit terakhir NIM.
    //
    // 20240801050 -> "50"
    final int duaDigitTerakhir =
        int.parse(nim.substring(nim.length - 2));

    // Rumus skor aktivitas:
    // 2 digit terakhir NIM + 50.
    //
    // 50 + 50 = 100.
    final int skorAktivitas =
        duaDigitTerakhir + 50; // 5. Skor Aktivitas (dua digit terakhir NIM + 50)

    return Scaffold(
      body: Center(
        // ProfileCard ditempatkan tepat
        // di tengah layar menggunakan Center.
        child: ProfileCard(
          nama: 'Marcell Juniar Wijaya',
          nim: nim,

          // Silakan ubah sesuai hobi kamu.
          hobi: 'Terbang, Gaming, Billiard, dan Makan',

          // Nilainya tidak ditulis hardcoded.
          // Skor dihitung berdasarkan NIM.
          skorAktivitas: skorAktivitas,
        ),
      ),
    );
  }
}
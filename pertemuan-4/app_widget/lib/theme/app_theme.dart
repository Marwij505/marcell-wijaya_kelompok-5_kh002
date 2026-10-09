
import 'package:flutter/material.dart';

// Class ini digunakan untuk mengatur tema atau tampilan aplikasi.
// Dengan memisahkan tema, kita tidak perlu mengatur warna satu per satu
// di setiap halaman aplikasi.
class AppTheme {

  // Tema utama yang akan digunakan oleh aplikasi.
  static final ThemeData light = ThemeData(

    // Menggunakan sistem tampilan Material Design 3.
    useMaterial3: true,

    // Mengatur warna utama aplikasi menjadi biru.
    // Warna ini juga digunakan pada tombol GitHub.
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
    ),

    // Mengatur warna latar belakang aplikasi.
    scaffoldBackgroundColor: const Color(0xFFF0F4F8),

    // Mengatur tampilan bagian atas aplikasi (AppBar).
    appBarTheme: const AppBarTheme(

      // Warna latar belakang AppBar.
      backgroundColor: Color(0xFF2563EB),

      // Warna teks dan ikon pada AppBar.
      foregroundColor: Colors.white,

      // Menempatkan judul AppBar di tengah.
      centerTitle: true,
    ),
  );
}

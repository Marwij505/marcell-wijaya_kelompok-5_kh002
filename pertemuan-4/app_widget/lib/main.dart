
import 'package:flutter/material.dart';

// Mengambil pengaturan warna dari file app_theme.dart.
import 'theme/app_theme.dart';

// Mengambil komponen tombol dari file app_button.dart.
import 'widgets/app_button.dart';

// Fungsi utama yang pertama kali dijalankan oleh Flutter.
void main() {

  // Menjalankan aplikasi melalui class MyApp.
  runApp(const MyApp());
}

// MyApp merupakan class utama aplikasi.
// StatelessWidget digunakan karena pengaturan aplikasi
// tidak membutuhkan perubahan data secara langsung.
class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // MaterialApp digunakan sebagai wadah utama aplikasi.
    return MaterialApp(

      // Menghilangkan tulisan DEBUG pada pojok aplikasi.
      debugShowCheckedModeBanner: false,

      // Judul aplikasi.
      title: 'Personal Profile Card',

      // Menggunakan tema yang sudah dibuat pada app_theme.dart.
      theme: AppTheme.light,

      // Menentukan halaman yang pertama kali ditampilkan.
      home: const HomePage(),
    );
  }
}

// HomePage merupakan halaman yang menampilkan kartu profil.
// StatelessWidget cocok karena data profil bersifat tetap.
class HomePage extends StatelessWidget {

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    // ============================================
    // BAGIAN 1: DATA MAHASISWA
    // ============================================

    // Menyimpan NIM dalam bentuk String.
    // String digunakan agar angka 0 tidak hilang.
    const String nim = '20240801050';

    // Mengambil satu digit terakhir dari NIM.
    // NIM berakhir dengan angka 0, sehingga ddd = 0.
    final int ddd = int.parse(
      nim.substring(nim.length - 1),
    );

    // ============================================
    // BAGIAN 2: PERHITUNGAN UKURAN BERDASARKAN NIM
    // ============================================

    // Padding card = 16 + ddd.
    // Hasil: 16 + 0 = 16.
    final double paddingCard = (16 + ddd).toDouble();

    // Rounded card = 8 + ddd.
    // Hasil: 8 + 0 = 8.
    final double roundedCard = (8 + ddd).toDouble();

    // Tinggi tombol = 40 + ddd.
    // Hasil: 40 + 0 = 40.
    final double tinggiTombol = (40 + ddd).toDouble();

    // Rounded tombol = 4 + ddd.
    // Hasil: 4 + 0 = 4.
    final double roundedTombol = (4 + ddd).toDouble();

    // Ukuran avatar = 40 + (2 * ddd).
    // Hasil: 40 + (2 * 0) = 40.
    final double ukuranAvatar = (40 + (2 * ddd)).toDouble();

    // Jarak nama dan NIM = 8 + ddd.
    // Hasil: 8 + 0 = 8.
    final double jarakNamaNim = (8 + ddd).toDouble();

    // ============================================
    // BAGIAN 3: TAMPILAN HALAMAN
    // ============================================

    // Scaffold merupakan kerangka utama halaman Flutter.
    return Scaffold(

      // Menampilkan bagian atas aplikasi.
      appBar: AppBar(

        // Menampilkan judul menggunakan font default.
        title: const Text('Personal Profile Card'),
      ),

      // SingleChildScrollView memungkinkan halaman digulir.
      // Tujuannya agar teks panjang tidak terpotong
      // saat aplikasi dibuka pada layar HP yang kecil.
      body: SingleChildScrollView(

        // Memberikan jarak antara card dengan tepi layar.
        child: Padding(
          padding: const EdgeInsets.all(16),

          // Center menempatkan kartu di tengah secara horizontal.
          child: Center(

            // Membatasi lebar kartu agar tidak terlalu besar
            // saat ditampilkan pada tablet atau komputer.
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),

              // Card digunakan sebagai wadah seluruh data profil.
              child: Card(

                // Menghilangkan margin bawaan Card.
                margin: EdgeInsets.zero,

                // Mengatur kelengkungan Card berdasarkan NIM.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(roundedCard),
                ),

                // Memberikan sedikit bayangan pada kartu.
                elevation: 2,

                // Padding bagian dalam Card mengikuti rumus NIM.
                child: Padding(
                  padding: EdgeInsets.all(paddingCard),

                  // Column menyusun semua komponen secara vertikal.
                  child: Column(

                    // Ukuran Column menyesuaikan isi.
                    mainAxisSize: MainAxisSize.min,

                    // Semua tulisan dimulai dari sisi kiri.
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      // ============================================
                      // BAGIAN 4: FOTO PROFIL
                      // ============================================

                      // Align digunakan agar foto berada di tengah.
                      Align(
                        alignment: Alignment.center,

                        // CircleAvatar membuat foto berbentuk lingkaran.
                        child: CircleAvatar(

                          // Radius adalah setengah dari ukuran avatar.
                          // Ukuran avatar 40, maka radius 20.
                          radius: ukuranAvatar / 2,

                          // Mengambil foto dari folder assets/images.
                          backgroundImage: const AssetImage(
                            'assets/images/foto_profil.jpeg',
                          ),
                        ),
                      ),

                      // Memberikan jarak setelah foto.
                      const SizedBox(height: 16),

                      // ============================================
                      // BAGIAN 5: NAMA LENGKAP
                      // ============================================

                      // Menampilkan nama menggunakan font default.
                      // Tidak menggunakan fontSize atau fontWeight.
                      const Text('MARCELL JUNIAR WIJAYA'),

                      // Jarak nama dan NIM mengikuti rumus.
                      // Hasilnya adalah 8.
                      SizedBox(height: jarakNamaNim),

                      // ============================================
                      // BAGIAN 6: NIM MAHASISWA
                      // ============================================

                      // Menampilkan NIM yang sudah disimpan.
                      Text('NIM: $nim'),

                      // Memberikan jarak setelah NIM.
                      const SizedBox(height: 12),

                      // ============================================
                      // BAGIAN 7: PROGRAM STUDI
                      // ============================================

                      // Menampilkan program studi mahasiswa.
                      const Text(
                        'Program Studi: TEKNIK INFORMATIKA',
                      ),

                      // Memberikan jarak sebelum deskripsi.
                      const SizedBox(height: 16),

                      // ============================================
                      // BAGIAN 8: DESKRIPSI DIRI
                      // ============================================

                      // Menampilkan judul bagian deskripsi.
                      const Text('Deskripsi Diri:'),

                      // Memberikan jarak antara judul dan isi.
                      const SizedBox(height: 8),

                      // Menampilkan deskripsi tentang diri sendiri.
                      // Semua teks menggunakan font default Flutter.
                      // Teks panjang akan otomatis turun ke baris baru.
                      const Text(
                        'SAYA SUKA TERBANG, PESAWAT JET PRIBADI '
                        'YANG SAYA SUKA GLOBAL 5000, HELIKOPTER '
                        'YANG SAYA SUKA SIKORSKY UH-60M BLACK-HAWK, '
                        'JET TEMPUR YANG SAYA SUKA F22 A10 F15EX '
                        'EAGLE 2 DAN F35, JET COMMERCIAL YANG SAYA '
                        'SUKA A320, A380, DAN A350',
                      ),

                      // Memberikan jarak sebelum tombol GitHub.
                      const SizedBox(height: 24),

                      // ============================================
                      // BAGIAN 9: TOMBOL GITHUB
                      // ============================================

                      // Menggunakan komponen AppButton yang
                      // sudah dibuat pada app_button.dart.
                      AppButton(

                        // Tulisan pada tombol.
                        label: 'Kunjungi GitHub Saya',

                        // Ikon yang ditampilkan pada tombol.
                        icon: Icons.code,

                        // Link GitHub pribadi mahasiswa.
                        url: 'https://github.com/Marwij505',

                        // Tinggi tombol mengikuti rumus NIM.
                        // Hasilnya adalah 40.
                        height: tinggiTombol,

                        // Sudut tombol mengikuti rumus NIM.
                        // Hasilnya adalah 4.
                        borderRadius: roundedTombol,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

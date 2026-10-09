
import 'package:flutter/material.dart';

// Package ini digunakan untuk membuka link ke aplikasi luar,
// misalnya browser yang membuka halaman GitHub.
import 'package:url_launcher/url_launcher.dart';

// AppButton adalah komponen tombol yang bisa digunakan berulang kali.
// Karena tidak menyimpan data yang berubah, kita menggunakan StatelessWidget.
class AppButton extends StatelessWidget {

  // label digunakan untuk menentukan tulisan pada tombol.
  final String label;

  // icon digunakan untuk menentukan gambar ikon pada tombol.
  final IconData icon;

  // url digunakan untuk menentukan alamat website tujuan.
  final String url;

  // height digunakan untuk menentukan tinggi tombol.
  final double height;

  // borderRadius digunakan untuk menentukan kelengkungan sudut tombol.
  final double borderRadius;

  // Constructor untuk menerima data dari main.dart.
  const AppButton({
    super.key,
    required this.label,
    required this.icon,
    required this.url,
    required this.height,
    required this.borderRadius,
  });

  // Fungsi ini dijalankan ketika tombol ditekan.
  // Future<void> digunakan karena membuka URL membutuhkan proses async.
  Future<void> _bukaUrl(BuildContext context) async {

    // Mengubah alamat website berbentuk String menjadi Uri.
    // Uri merupakan format alamat yang dipahami url_launcher.
    final Uri? alamat = Uri.tryParse(url);

    // Memeriksa apakah alamat yang diberikan valid.
    if (alamat == null || !alamat.hasScheme) {

      // Menampilkan pesan jika alamat tidak valid.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat URL tidak valid.'),
        ),
      );

      // Menghentikan proses apabila URL salah.
      return;
    }

    try {

      // Membuka alamat URL melalui aplikasi eksternal.
      // Contohnya adalah browser Chrome di HP atau komputer.
      final bool berhasil = await launchUrl(
        alamat,
        mode: LaunchMode.externalApplication,
      );

      // Memeriksa apakah halaman gagal dibuka.
      if (!berhasil && context.mounted) {

        // Memberikan pesan kepada pengguna jika gagal.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka halaman GitHub.'),
          ),
        );
      }

    } catch (error) {

      // Bagian ini menangani kesalahan saat membuka URL.
      // Contohnya ketika perangkat tidak memiliki aplikasi
      // yang dapat menangani alamat website tersebut.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat membuka URL.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    // SizedBox digunakan untuk mengatur ukuran tombol.
    return SizedBox(

      // Membuat tombol mengikuti lebar ruang yang tersedia.
      width: double.infinity,

      // Tinggi tombol mengikuti nilai dari main.dart.
      height: height,

      // ElevatedButton.icon membuat tombol dengan ikon dan tulisan.
      child: ElevatedButton.icon(

        // Ketika tombol ditekan, fungsi _bukaUrl dijalankan.
        onPressed: () => _bukaUrl(context),

        // Menampilkan ikon sesuai parameter yang diterima.
        icon: Icon(icon),

        // Menampilkan teks tombol menggunakan font default Flutter.
        // Tidak ada TextStyle karena dilarang dalam tugas.
        label: Text(label),

        // Mengatur warna dan bentuk tombol.
        style: ElevatedButton.styleFrom(

          // Mengambil warna utama dari AppTheme.
          backgroundColor: Theme.of(context).colorScheme.primary,

          // Mengambil warna yang cocok untuk teks dan ikon tombol.
          foregroundColor: Theme.of(context).colorScheme.onPrimary,

          // Memberikan jarak horizontal pada isi tombol.
          padding: const EdgeInsets.symmetric(horizontal: 8),

          // Mengatur sudut tombol berdasarkan parameter borderRadius.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

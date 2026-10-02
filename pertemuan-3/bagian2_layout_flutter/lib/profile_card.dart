import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget { // 7. statelesswidget
  // Data mahasiswa yang wajib diterima melalui constructor.
  final String nama;
  final String nim;
  final String hobi;
  final int skorAktivitas;

  const ProfileCard({
    super.key,
    required this.nama,
    required this.nim,
    required this.hobi,
    required this.skorAktivitas,
  });

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // PERHITUNGAN BERDASARKAN NIM
    // ==========================================================

    // Mengambil digit terakhir NIM.
    // Contoh NIM 20240801050 -> digit terakhir = 0.
    final int digitTerakhir =
        int.parse(nim[nim.length - 1]);

    // Mengambil digit ke-2 dari belakang.
    // Contoh NIM 20240801050 -> digit ke-2 = 5.
    final int digitKeduaDariBelakang =
        int.parse(nim[nim.length - 2]);

    // Rumus lebar kartu:
    // 320 + (digit ke-2 dari belakang × 5)
    final double lebarKartu =
        320.0 + (digitKeduaDariBelakang * 5);

    // Rumus sudut melengkung:
    // 12 + (digit terakhir × 1.5)
    final double sudutMelengkung =
        12.0 + (digitTerakhir * 1.5);

    // Rumus ukuran FlutterLogo:
    // 60 + (digit terakhir × 2)
    final double ukuranLogo =
        60.0 + (digitTerakhir * 2);

    // Rumus jarak pemisah horizontal:
    // 15 + digit terakhir
    final double jarakPemisah =
        15.0 + digitTerakhir;

    return Container(
      // Lebar kartu dihitung berdasarkan NIM.
      width: lebarKartu, // 1. Lebar Kartu (Container.Width)

      // Memberikan ruang di dalam kartu.
      padding: const EdgeInsets.all(24),

      // Dekorasi utama kartu.
      decoration: BoxDecoration(
        color: Colors.white,

        // Border radius dihitung berdasarkan NIM.
        borderRadius: BorderRadius.circular(
          sudutMelengkung, // 2. Sudut Melengkung (BorderRadius.circular)
        ),

        // Bayangan hitam transparan.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // HEADER KARTU
          // ======================================================
          Row(
            children: [
              // Bagian kiri berisi FlutterLogo.
              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),

                  // Membuat bingkai logo berbentuk lingkaran.
                  borderRadius: BorderRadius.circular(100),

                  border: Border.all(
                    color:
                        Colors.blue.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),

                // Ukuran logo dihitung berdasarkan NIM.
                child: FlutterLogo(
                  size: ukuranLogo, // 3. Ukuran Logo (FlutterLogo.Size)
                ),
              ),

              // Jarak antara logo dengan teks.
              // Nilainya juga dihitung berdasarkan NIM.
              SizedBox(
                width: jarakPemisah, // 4. Jarak Pemisah (SizedBox.Width)
              ),

              // Expanded digunakan agar teks tidak overflow.
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kartu Praktikan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Menampilkan nama mahasiswa.
                    Text(
                      nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF20242A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ======================================================
          // GARIS PEMISAH
          // ======================================================
          const Divider(
            thickness: 1.5,
            height: 1,
          ),

          const SizedBox(height: 20),

          // ======================================================
          // DETAIL IDENTITAS
          // ======================================================

          _buildDetailRow(
            icon: Icons.badge_outlined,
            label: 'NIM',
            value: nim,
          ),

          const SizedBox(height: 14),

          _buildDetailRow(
            icon: Icons.favorite_border,
            label: 'Hobi',
            value: hobi,
          ),

          const SizedBox(height: 14),

          _buildDetailRow(
            icon: Icons.stars_outlined,
            label: 'Skor Aktivitas',
            value: skorAktivitas.toString(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FUNGSI UNTUK MEMBUAT BARIS DETAIL IDENTITAS
  // ============================================================
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 21,
          color: Colors.blueGrey.shade600,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label seperti NIM, Hobi, atau Skor Aktivitas.
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 3),

              // Nilai dari masing-masing informasi.
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF30343B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
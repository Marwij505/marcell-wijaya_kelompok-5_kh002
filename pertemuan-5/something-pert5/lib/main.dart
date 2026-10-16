import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Firebase Core digunakan untuk menginisialisasi Firebase.
import 'package:firebase_core/firebase_core.dart';

// Cloud Firestore digunakan untuk menyimpan data stok barang.
import 'package:cloud_firestore/cloud_firestore.dart';

// Konfigurasi Firebase otomatis dari FlutterFire CLI.
import 'firebase_options.dart';

// ============================================================
// BAGIAN 1: FUNGSI UTAMA APLIKASI
// ============================================================

Future<void> main() async {
  // Memastikan Flutter siap sebelum menjalankan operasi async.
  WidgetsFlutterBinding.ensureInitialized();

  // Menghubungkan aplikasi ke proyek Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Menjalankan aplikasi setelah inisialisasi selesai.
  runApp(const MyApp());
}

// ============================================================
// BAGIAN 2: KONFIGURASI APLIKASI
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Nama aplikasi yang ditampilkan pada sistem.
      title: 'Pencatatan Stok Barang',

      // Menghilangkan banner DEBUG.
      debugShowCheckedModeBanner: false,

      // Mengatur warna dan tampilan global.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),

      // Menampilkan halaman utama yang sudah ada.
      home: const HomePage(),
    );
  }
}

// ============================================================
// BAGIAN 3: HALAMAN UTAMA
// ============================================================

// StatefulWidget diperlukan karena status input,
// validasi, dan proses penyimpanan dapat berubah.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ==========================================================
  // A. KONSTANTA VALIDASI BERDASARKAN IDENTITAS MAHASISWA
  // ==========================================================

  // Nama depan mahasiswa adalah Marcell.
  // Maka nama barang harus diawali huruf M.
  static const String _inisialNama = 'M';

  // NIM 20240801050 berakhiran angka 0 (genap).
  // Dua digit terakhir NIM adalah 50.
  // Kode barang harus memiliki akhiran 50.
  static const String _akhiranKodeBarang = '50';

  // Panjang minimal kode barang sesuai instruksi dosen.
  static const int _minimalDigitKode = 6;

  // ==========================================================
  // B. FORM KEY
  // ==========================================================

  // Menyimpan state form sehingga seluruh input
  // dapat divalidasi secara bersamaan.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ==========================================================
  // C. CONTROLLER UNTUK LIMA INPUT PENGGUNA
  // ==========================================================

  // Mengambil nilai Nama Barang.
  final TextEditingController _namaBarangController = TextEditingController();

  // Mengambil nilai Tanggal Masuk Barang.
  final TextEditingController _tanggalMasukController = TextEditingController();

  // Mengambil nilai Tanggal Keluar Barang.
  final TextEditingController _tanggalKeluarController =
      TextEditingController();

  // Mengambil nilai Kode Barang.
  final TextEditingController _kodeBarangController = TextEditingController();

  // Mengambil nilai Jumlah Stok.
  final TextEditingController _jumlahStokController = TextEditingController();

  // ==========================================================
  // D. STATUS PENYIMPANAN DATA
  // ==========================================================

  // false: tidak sedang menyimpan.
  // true : sedang mengirim data ke Firestore.
  bool _isSaving = false;

  // ==========================================================
  // E. MEMBERSIHKAN CONTROLLER
  // ==========================================================

  @override
  void dispose() {
    // Semua controller dilepaskan ketika widget dihentikan
    // agar penggunaan memori lebih efisien.
    _namaBarangController.dispose();
    _tanggalMasukController.dispose();
    _tanggalKeluarController.dispose();
    _kodeBarangController.dispose();
    _jumlahStokController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BAGIAN 4: VALIDASI NAMA BARANG
  // ==========================================================

  String? _validasiNamaBarang(String? value) {
    // Menghapus spasi di awal dan akhir.
    final String nama = value?.trim() ?? '';

    // Memastikan Nama Barang tidak kosong.
    if (nama.isEmpty) {
      return 'Nama Barang wajib diisi.';
    }

    // Memastikan nama dimulai dengan inisial M.
    // Menggunakan uppercase supaya M dan m diterima.
    if (!nama.toUpperCase().startsWith(_inisialNama)) {
      return 'Nama Barang harus diawali huruf M.';
    }

    // null berarti nilai input sudah valid.
    return null;
  }

  // ==========================================================
  // BAGIAN 5: VALIDASI TANGGAL MASUK BARANG
  // ==========================================================

  String? _validasiTanggalMasuk(String? value) {
    // Mengambil teks tanggal yang dimasukkan pengguna.
    final String tanggal = value?.trim() ?? '';

    // Tanggal Masuk Barang wajib diisi.
    if (tanggal.isEmpty) {
      return 'Tanggal Masuk Barang wajib diisi.';
    }

    // Berdasarkan soal, tanggal disimpan sebagai teks.
    // Karena format tanggal tidak ditentukan dosen,
    // validasi di sini hanya memeriksa field kosong.
    return null;
  }

  // ==========================================================
  // BAGIAN 6: VALIDASI TANGGAL KELUAR BARANG
  // ==========================================================

  String? _validasiTanggalKeluar(String? value) {
    // Mengambil teks tanggal dari input pengguna.
    final String tanggal = value?.trim() ?? '';

    // Tanggal Keluar Barang wajib diisi.
    if (tanggal.isEmpty) {
      return 'Tanggal Keluar Barang wajib diisi.';
    }

    // Nilai valid akan dikirim sebagai String ke Firestore.
    return null;
  }

  // ==========================================================
  // BAGIAN 7: VALIDASI KODE BARANG
  // ==========================================================

  String? _validasiKodeBarang(String? value) {
    // Kode Barang awalnya berbentuk String.
    final String kode = value?.trim() ?? '';

    // Validasi pertama: tidak boleh kosong.
    if (kode.isEmpty) {
      return 'Kode Barang wajib diisi.';
    }

    // Validasi kedua: hanya boleh berisi bilangan bulat.
    // tryParse() akan menghasilkan null jika konversi gagal.
    final int? kodeInteger = int.tryParse(kode);

    if (kodeInteger == null) {
      return 'Kode Barang harus berupa angka bulat.';
    }

    // Validasi ketiga: minimal enam angka.
    if (kode.length < _minimalDigitKode) {
      return 'Kode Barang minimal 6 angka.';
    }

    // Karena kode disimpan sebagai Integer,
    // angka nol di depan akan hilang saat dikonversi.
    // Maka kode tidak boleh diawali angka nol.
    if (kode.startsWith('0')) {
      return 'Kode Barang tidak boleh diawali angka 0.';
    }

    // Validasi keempat: kode wajib berakhiran 50.
    // Ketentuan ini berasal dari dua digit terakhir
    // NIM mahasiswa yang genap.
    if (!kode.endsWith(_akhiranKodeBarang)) {
      return 'Kode Barang harus berakhiran 50.';
    }

    // Semua aturan kode barang sudah terpenuhi.
    return null;
  }

  // ==========================================================
  // BAGIAN 8: VALIDASI JUMLAH STOK
  // ==========================================================

  String? _validasiJumlahStok(String? value) {
    // Mengambil data stok yang awalnya berbentuk String.
    final String stok = value?.trim() ?? '';

    // Jumlah Stok wajib diisi.
    if (stok.isEmpty) {
      return 'Jumlah Stok wajib diisi.';
    }

    // Memastikan nilai dapat diubah menjadi integer.
    final int? stokInteger = int.tryParse(stok);

    if (stokInteger == null) {
      return 'Jumlah Stok harus berupa angka bulat.';
    }

    // Menolak stok negatif.
    if (stokInteger < 0) {
      return 'Jumlah Stok tidak boleh negatif.';
    }

    // Stok bernilai nol tetap diperbolehkan.
    return null;
  }

  // ==========================================================
  // BAGIAN 9: MENAMPILKAN PESAN NOTIFIKASI
  // ==========================================================

  void _tampilkanPesan(String pesan, {required bool berhasil}) {
    // Menggunakan warna hijau untuk sukses
    // dan warna merah untuk kegagalan.
    final Color warna = berhasil ? Colors.green.shade700 : Colors.red.shade700;

    // Menghilangkan notifikasi sebelumnya.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Menampilkan hasil penyimpanan kepada pengguna.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: warna,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==========================================================
  // BAGIAN 10: FUNGSI MENYIMPAN DATA KE FIRESTORE
  // ==========================================================

  Future<void> _simpanBarang() async {
    // Menutup keyboard yang sedang terbuka.
    FocusScope.of(context).unfocus();

    // Mencegah pengguna menekan tombol Simpan berulang kali.
    if (_isSaving) {
      return;
    }

    // Memvalidasi kelima TextFormField.
    // Jika ada satu saja input tidak valid,
    // proses penyimpanan langsung dibatalkan.
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // --------------------------------------------------------
    // A. MENGAMBIL DATA LANGSUNG DARI INPUT PENGGUNA
    // --------------------------------------------------------

    // Field Nama Barang sebagai String.
    final String namaBarang = _namaBarangController.text.trim();

    // Field Tanggal Masuk sebagai String.
    final String tanggalMasuk = _tanggalMasukController.text.trim();

    // Field Tanggal Keluar sebagai String.
    final String tanggalKeluar = _tanggalKeluarController.text.trim();

    // Field Kode Barang dikonversi String menjadi int.
    // Aman karena sebelumnya sudah divalidasi.
    final int kodeBarang = int.parse(_kodeBarangController.text.trim());

    // Field Jumlah Stok dikonversi String menjadi int.
    final int jumlahStok = int.parse(_jumlahStokController.text.trim());

    // --------------------------------------------------------
    // B. MENGAKTIFKAN STATUS LOADING
    // --------------------------------------------------------

    setState(() {
      _isSaving = true;
    });

    try {
      // ------------------------------------------------------
      // C. MENGAKSES FIREBASE CLOUD FIRESTORE
      // ------------------------------------------------------

      // Mengambil instance Firestore yang aktif.
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Menyimpan dokumen baru ke collection stok_barang.
      // add() akan menghasilkan ID dokumen secara otomatis.
      await firestore.collection('stok_barang').add({
        // Data teks Nama Barang.
        'nama_barang': namaBarang,

        // Dua tanggal disimpan sebagai String.
        'tanggal_masuk_barang': tanggalMasuk,
        'tanggal_keluar_barang': tanggalKeluar,

        // Dua nilai angka disimpan sebagai Integer.
        'kode_barang': kodeBarang,
        'jumlah_stok': jumlahStok,

        // Timestamp dibuat oleh server Firebase.
        // Tidak menggunakan DateTime.now() dari perangkat.
        'waktu': FieldValue.serverTimestamp(),
      });

      // ------------------------------------------------------
      // D. JIKA PENYIMPANAN BERHASIL
      // ------------------------------------------------------

      // Memastikan halaman masih aktif sebelum mengakses UI.
      if (!mounted) return;

      // Mengosongkan semua input yang telah disimpan.
      _namaBarangController.clear();
      _tanggalMasukController.clear();
      _tanggalKeluarController.clear();
      _kodeBarangController.clear();
      _jumlahStokController.clear();

      // Mengembalikan status validasi form ke kondisi awal.
      _formKey.currentState?.reset();

      // Menampilkan pemberitahuan keberhasilan.
      _tampilkanPesan('Data stok barang berhasil disimpan!', berhasil: true);
    } on FirebaseException catch (error) {
      // ------------------------------------------------------
      // E. JIKA TERJADI ERROR DARI FIREBASE
      // ------------------------------------------------------

      if (!mounted) return;

      // Membuat pesan kesalahan dari Firebase.
      String pesan = 'Gagal menyimpan: ${error.message ?? error.code}';

      // Memberikan pesan khusus untuk akses yang ditolak.
      if (error.code == 'permission-denied') {
        pesan = 'Akses Firestore ditolak. Periksa Security Rules.';
      }

      // Menampilkan pesan tanpa menghapus data form.
      _tampilkanPesan(pesan, berhasil: false);
    } catch (error) {
      // ------------------------------------------------------
      // F. JIKA TERJADI ERROR LAINNYA
      // ------------------------------------------------------

      if (!mounted) return;

      _tampilkanPesan('Terjadi kesalahan: $error', berhasil: false);
    } finally {
      // ------------------------------------------------------
      // G. MENGEMBALIKAN KONDISI TOMBOL
      // ------------------------------------------------------

      // Menghilangkan loading setelah proses selesai.
      // Berlaku baik penyimpanan sukses maupun gagal.
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ==========================================================
  // BAGIAN 11: TAMPILAN ANTARMUKA APLIKASI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -------------------------------------------------------
      // A. APP BAR
      // -------------------------------------------------------

      appBar: AppBar(
        title: const Text('Pencatatan Stok Barang'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      // -------------------------------------------------------
      // B. BODY UTAMA
      // -------------------------------------------------------
      body: SafeArea(
        // Mencegah overflow ketika keyboard terbuka.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Center(
            child: ConstrainedBox(
              // Membatasi lebar form agar tetap responsif.
              constraints: const BoxConstraints(maxWidth: 600),

              child: Card(
                elevation: 2,

                child: Padding(
                  padding: const EdgeInsets.all(24),

                  // Mengelompokkan kelima TextFormField.
                  child: Form(
                    key: _formKey,

                    // Menampilkan validasi setelah interaksi.
                    autovalidateMode: AutovalidateMode.onUserInteraction,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,

                      children: [
                        // ------------------------------------
                        // C. HEADER FORM
                        // ------------------------------------

                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 55,
                          color: Colors.indigo,
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Form Input Stok Barang',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Masukkan informasi barang '
                          'untuk disimpan ke Firebase.',
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        // ------------------------------------
                        // FIELD 1: NAMA BARANG
                        // ------------------------------------
                        TextFormField(
                          // Menghubungkan input ke controller.
                          controller: _namaBarangController,

                          // Keyboard teks biasa.
                          keyboardType: TextInputType.text,

                          // Berpindah ke field berikutnya.
                          textInputAction: TextInputAction.next,

                          // Label dan tampilan input.
                          decoration: const InputDecoration(
                            labelText: 'Nama Barang',
                            hintText: 'Contoh: Mouse Wireless',
                            helperText: 'Harus diawali huruf M',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                            border: OutlineInputBorder(),
                          ),

                          // Memanggil validasi inisial nama.
                          validator: _validasiNamaBarang,
                        ),

                        const SizedBox(height: 20),

                        // ------------------------------------
                        // FIELD 2: TANGGAL MASUK BARANG
                        // ------------------------------------
                        TextFormField(
                          controller: _tanggalMasukController,

                          // Tanggal sesuai instruksi berupa teks.
                          keyboardType: TextInputType.text,

                          textInputAction: TextInputAction.next,

                          decoration: const InputDecoration(
                            labelText: 'Tanggal Masuk Barang',
                            hintText: 'Contoh: 16/10/2026',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                            border: OutlineInputBorder(),
                          ),

                          // Memastikan tanggal masuk terisi.
                          validator: _validasiTanggalMasuk,
                        ),

                        const SizedBox(height: 20),

                        // ------------------------------------
                        // FIELD 3: TANGGAL KELUAR BARANG
                        // ------------------------------------
                        TextFormField(
                          controller: _tanggalKeluarController,

                          // Tanggal disimpan sebagai String.
                          keyboardType: TextInputType.text,

                          textInputAction: TextInputAction.next,

                          decoration: const InputDecoration(
                            labelText: 'Tanggal Keluar Barang',
                            hintText: 'Contoh: 20/10/2026',
                            prefixIcon: Icon(Icons.event_outlined),
                            border: OutlineInputBorder(),
                          ),

                          // Memastikan tanggal keluar terisi.
                          validator: _validasiTanggalKeluar,
                        ),

                        const SizedBox(height: 20),

                        // ------------------------------------
                        // FIELD 4: KODE BARANG
                        // ------------------------------------
                        TextFormField(
                          controller: _kodeBarangController,

                          // Mengaktifkan keyboard numerik.
                          keyboardType: TextInputType.number,

                          textInputAction: TextInputAction.next,

                          // Hanya angka 0-9 yang diizinkan.
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],

                          decoration: const InputDecoration(
                            labelText: 'Kode Barang',
                            hintText: 'Contoh: 123450',
                            helperText: 'Minimal 6 digit, akhiran 50',
                            prefixIcon: Icon(Icons.qr_code_outlined),
                            border: OutlineInputBorder(),
                          ),

                          // Validasi integer, panjang, dan NIM.
                          validator: _validasiKodeBarang,
                        ),

                        const SizedBox(height: 20),

                        // ------------------------------------
                        // FIELD 5: JUMLAH STOK
                        // ------------------------------------
                        TextFormField(
                          controller: _jumlahStokController,

                          // Menampilkan keyboard angka.
                          keyboardType: TextInputType.number,

                          textInputAction: TextInputAction.done,

                          // Hanya mengizinkan angka.
                          // Tanda minus tidak dapat dimasukkan.
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],

                          decoration: const InputDecoration(
                            labelText: 'Jumlah Stok',
                            hintText: 'Contoh: 25',
                            helperText: 'Stok tidak boleh negatif',
                            prefixIcon: Icon(Icons.numbers_outlined),
                            border: OutlineInputBorder(),
                          ),

                          // Memastikan nilai integer >= 0.
                          validator: _validasiJumlahStok,
                        ),

                        const SizedBox(height: 30),

                        // ------------------------------------
                        // D. TOMBOL SIMPAN BARANG
                        // ------------------------------------
                        SizedBox(
                          height: 52,

                          child: ElevatedButton.icon(
                            // Tombol akan nonaktif saat loading.
                            onPressed: _isSaving ? null : _simpanBarang,

                            // Loading tampil selama penyimpanan.
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),

                            // Label berubah sesuai proses.
                            label: Text(
                              _isSaving ? 'Menyimpan...' : 'Simpan Barang',
                            ),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.indigo.shade200,
                              disabledForegroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ------------------------------------
                        // E. INFORMASI PENYIMPANAN
                        // ------------------------------------
                        const Text(
                          'Seluruh data akan disimpan ke '
                          'collection stok_barang di '
                          'Firebase Cloud Firestore.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
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

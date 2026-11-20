
class AssignmentConfig {
  // Ganti dengan 3 digit terakhir NIM kamu.
  static const String nimLastThree = '050';

  // Menggeser angka tengah ke belakang.
  // Contoh: 345 menjadi 050.
  static int get n {
    if (!RegExp(r'^\d{3}$').hasMatch(nimLastThree)) {
      throw const FormatException(
        'Masukkan tepat 3 digit terakhir NIM.',
      );
    }

    final number =
        '${nimLastThree[0]}${nimLastThree[2]}${nimLastThree[1]}';

    return int.parse(number);
  }

  // Menghitung ID User dan Admin.
  static int get userId => 1499 + n;
  static int get adminId => 792 + n;
}

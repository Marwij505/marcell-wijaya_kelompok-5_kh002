// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Direktori Mahasiswa';

  @override
  String get detailTitle => 'Detail Pengguna';

  @override
  String get email => 'Email';

  @override
  String get city => 'Kota';

  @override
  String get language => 'Bahasa';

  @override
  String get errorMessage => 'Gagal Mengambil Data';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get noData => 'Tidak Ada Data User Ditemukan';
}

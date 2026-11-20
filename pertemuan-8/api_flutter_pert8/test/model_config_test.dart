import 'package:flutter_test/flutter_test.dart';
import 'package:api_flutter_pert8/config/assignment_config.dart';
import 'package:api_flutter_pert8/models/admin.dart';
import 'package:api_flutter_pert8/models/user_model.dart';

void main() {
  // Uji rumus ID berdasarkan contoh angka yang masih dipasang.
  test('ID menggunakan nilai N hasil pergeseran digit', () {
    final raw = AssignmentConfig.nimLastThree;
    final expectedN = int.parse('${raw[0]}${raw[2]}${raw[1]}');
    expect(AssignmentConfig.n, expectedN);
    expect(AssignmentConfig.userId, 1499 + expectedN);
    expect(AssignmentConfig.adminId, 792 + expectedN);
  });

  // Uji konversi JSON menjadi objek Admin.
  test('Admin.fromJson mengambil semua properti', () {
    final admin = Admin.fromJson({
      'id': 1001,
      'name': 'Admin Contoh',
      'email': 'admin@example.com',
      'department': 'TI',
    });
    expect(admin.id, 1001);
    expect(admin.department, 'TI');
    expect(admin.toJson()['name'], 'Admin Contoh');
  });

  // Uji konversi kota dari JSONPlaceholder.
  test('User.fromJson membaca city dari address', () {
    final user = User.fromJson({
      'id': 7,
      'name': 'Mahasiswa Contoh',
      'email': 'user@example.com',
      'address': {'city': 'Bekasi'},
    });
    expect(user.id, 7);
    expect(user.city, 'Bekasi');
  });
}
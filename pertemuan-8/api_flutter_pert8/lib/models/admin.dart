// Model Admin: mewakili satu baris data admin.
class Admin {
  final int id;
  final String name;
  final String email;
  final String department;

  const Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
  });

  // Konversi JSON ke objek Admin.
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
    );
  }

  // Konversi objek Admin ke JSON untuk disimpan.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'department': department,
  };
}
// Model User: mengubah JSON menjadi objek Dart yang terstruktur.
class User {
  final int id;
  final String name;
  final String email;
  final String city;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
  });

  // Membaca field dari JSONPlaceholder atau JSON lokal.
  factory User.fromJson(Map<String, dynamic> json) {
    final address = json['address'];
    final city = address is Map
        ? address['city']?.toString() ?? ''
        : json['city']?.toString() ?? '';

    return User(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      city: city,
    );
  }

  // Menyiapkan objek User agar dapat disimpan sebagai JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'address': {'city': city},
  };
}
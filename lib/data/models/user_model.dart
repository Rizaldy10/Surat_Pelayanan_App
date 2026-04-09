class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String role;
  final String nik;
  final String noHp;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.role,
    required this.nik,
    required this.noHp,
  });

  // Konversi ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'email': email,
      'role': role,
      'nik': nik,
    };
  }

  // Konversi dari Map Firestore ke Object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'USER',
      nik: map['nik'] ?? '', 
      noHp: map['noHp'] ??'',
    );
  }
}
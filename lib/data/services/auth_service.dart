import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:surat_pelayanan/data/models/surat_model.dart';
import '../models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. DAFTAR & LOGIN
  Future<void> registerWarga({
    required String email,
    required String password,
    required String nama,
    required String nik,
    required String noHp, // Tambahkan noHp agar bisa dihubungi WA
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel newUser = UserModel(
        uid: result.user!.uid,
        nama: nama,
        email: email,
        role: 'warga',
        nik: nik,
        noHp: noHp,
      );

      await _db.collection('users').doc(result.user!.uid).set(newUser.toMap());
      await _auth.signOut();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  // 2. DATA USER
  Future<UserModel?> getCurrentUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot doc = await _db
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Di dalam AuthService atau SuratService
  Future<void> ajukanSurat(SuratModel suratBaru) async {
    // 1. Ambil UID warga yang sedang login saat ini
    final String currentUid = _auth.currentUser!.uid;

    await _db.collection('surat').add({
      'uidPemohon': currentUid, // HARUS DIISI DI SINI (SAAT PENGAJUAN)
      'namaPemohon': suratBaru.namaPemohon,
      'nikPemohon': suratBaru.nikPemohon,
      'jenisSurat': suratBaru.jenisSurat,
      'alasan': suratBaru.alasan,
      'status': 'pending', // Status awal
      'tanggalPengajuan': DateTime.now(), // Waktu saat ini
      'urlBerkas': suratBaru.urlBerkas,
      // Field di bawah ini dikosongkan dulu, nanti diisi oleh Admin
      'nomorSurat': null,
      'pesanAdmin': null,
      'tanggalSelesai': null,
    });
  }

  Stream<List<SuratModel>> getSuratByUser(String uid) {
    if (uid.isEmpty) {
      return Stream.value([]); // Return list kosong jika UID tidak valid
    }

    return _db
        .collection('surat')
        .where('uidPemohon', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SuratModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // 4. LAYANAN ADMIN
  // Di dalam class AuthService
  Stream<List<SuratModel>> getAllSurat() {
    return _db
        .collection('surat')
        .orderBy('tanggalPengajuan', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SuratModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // FUNGSI VERIFIKASI (TOLAK)
  Future<void> verifikasiSurat(
    String idSurat,
    String status,
    String pesan,
  ) async {
    try {
      await _db.collection('surat').doc(idSurat).update({
        'status': status,
        'pesanAdmin': pesan,
        'tanggalVerifikasi': DateTime.now(),
      });
    } catch (e) {
      throw "Gagal verifikasi: $e";
    }
  }

  // Di dalam class AuthService
  Future<void> setujuiDenganNomorManual(
    String idSurat,
    String nomorSuratManual,
    String pesan,
  ) async {
    try {
      await _db.collection('surat').doc(idSurat).update({
        'status':
            'disetujui', // Pastikan huruf kecil agar sinkron dengan filter di halaman lain
        'nomorSurat': nomorSuratManual, // Nomor yang diketik admin
        'pesanAdmin': pesan,
        'tanggalSelesai': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw "Gagal menyetujui surat: $e";
    }
  }

  // 5. FITUR WHATSAPP BRIDGE
  Future<void> bukaWhatsAppWarga(
    String namaPemohon,
    String jenisSurat,
    String? nomorWarga,
  ) async {
    if (nomorWarga == null || nomorWarga.isEmpty) return;

    String phone = nomorWarga;
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    }

    String pesan =
        "Halo Bapak/Ibu $namaPemohon,\n\n"
        "Terkait pengajuan surat *$jenisSurat* Anda di aplikasi Pelayanan Desa. "
        "Mohon kirimkan foto berkas persyaratannya di sini untuk kami verifikasi.";

    var whatsappUrl = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(pesan)}",
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }

  // 6. STORAGE & LAINNYA
  Future<String> uploadBerkas(File imageFile, String folderName) async {
    try {
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = _storage.ref().child(folderName).child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw "Gagal upload: $e";
    }
  }

  Future<void> updateDataSuratManual(
    String idSurat,
    Map<String, dynamic> dataBaru,
  ) async {
    try {
      await _db.collection('surat').doc(idSurat).update(dataBaru);
    } catch (e) {
      throw "Gagal memperbarui data: $e";
    }
  }

  Future<void> hapusSurat(String idSurat) async {
    await _db.collection('surat').doc(idSurat).delete();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

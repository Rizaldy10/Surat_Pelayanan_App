import 'package:cloud_firestore/cloud_firestore.dart';

class SuratModel {
  final String id;
  final String uidPemohon;
  final String namaPemohon;
  final String nikPemohon;
  final String jenisSurat;
  final String alasan;
  final String status; 
  final DateTime tanggalPengajuan;
  final DateTime? tanggalSelesai; // Tambahkan ini untuk mencatat waktu persetujuan
  final String? nomorSurat;
  final String? urlBerkas; 
  final String? pesanAdmin; 

  SuratModel({
    required this.id,
    required this.uidPemohon,
    required this.namaPemohon,
    required this.nikPemohon,
    required this.jenisSurat,
    required this.alasan,
    required this.status,
    required this.tanggalPengajuan,
    this.tanggalSelesai, // Tambahkan di constructor
    this.nomorSurat,
    this.urlBerkas,
    this.pesanAdmin,
  });

  factory SuratModel.fromMap(Map<String, dynamic> data, String documentId) {
    return SuratModel(
      id: documentId,
      uidPemohon: data['uidPemohon'] ?? '',
      namaPemohon: data['namaPemohon'] ?? '',
      nikPemohon: data['nikPemohon'] ?? '',
      jenisSurat: data['jenisSurat'] ?? '',
      // PERBAIKAN: Jangan paksa jadi string kosong agar pengecekan ?? '-' di PDF jalan
      nomorSurat: data['nomorSurat'], 
      alasan: data['alasan'] ?? '',
      status: data['status'] ?? 'pending',
      tanggalPengajuan: data['tanggalPengajuan'] != null 
          ? (data['tanggalPengajuan'] as Timestamp).toDate() 
          : DateTime.now(),
      // Tambahkan konversi tanggalSelesai
      tanggalSelesai: data['tanggalSelesai'] != null 
          ? (data['tanggalSelesai'] as Timestamp).toDate() 
          : null,
      urlBerkas: data['urlBerkas'],
      pesanAdmin: data['pesanAdmin'],
    );
  }

  get createdAt => null;

  Map<String, dynamic> toMap() {
    return {
      'uidPemohon': uidPemohon,
      'namaPemohon': namaPemohon,
      'nikPemohon': nikPemohon,
      'nomorSurat': nomorSurat,
      'jenisSurat': jenisSurat,
      'alasan': alasan,
      'status': status,
      'tanggalPengajuan': Timestamp.fromDate(tanggalPengajuan),
      // Tambahkan ke Map agar tersimpan di Firestore
      'tanggalSelesai': tanggalSelesai != null ? Timestamp.fromDate(tanggalSelesai!) : null,
      'urlBerkas': urlBerkas,
      'pesanAdmin': pesanAdmin,
    };
  }
}
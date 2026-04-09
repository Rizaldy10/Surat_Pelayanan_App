import 'package:flutter/material.dart';
import 'package:surat_pelayanan/ui/surat/form_pengajuan_page.dart';
import '../../data/models/user_model.dart';

class PanduanLayananPage extends StatelessWidget {
  final UserModel user;
  PanduanLayananPage({super.key, required this.user});

  final Map<String, List<String>> daftarSyarat = {
    "Surat Rekomendasi Pembelian BBM": [
      "Surat pengantar RT/RW",
      "Kartu keluarga",
      "KTP",
    ],
    "Surat penghasilan orang tua": [
      "Surat pengantar RT/RW",
      "Kartu keluarga",
      "KTP",
    ],
    "Surat pengenal kelahiran": [
      "Surat pengantar RT/RW",
      "Kartu keluarga",
      "KTP",
      "Buku nikah orang tua",
    ],
    "Surat Keterangan kehilangan": [
      "Surat pengantar RT/RW",
      "Kartu keluarga",
      "KTP",
      "Pelaporan kehilangan dari polsek",
    ],
    "Surat Keterangan bepergian sementara": [
      "Surat pengantar RT/RW",
      "Kartu keluarga",
      "KTP",
      "Pas photo terbaru 4x6",
    ],
    "Pengantar SKCK": [
      "Surat pengantar RT/RW",
      "Kartu keluarga",
      "KTP",
      "Akta kelahiran",
      "Ijazah terakhir",
      "Pas photo terbaru 4x6 background merah",
    ],
    "Surat keterangan domisili": [
      "Surat pengantar RT/RW",
      "Kartu keluarga",
      "KTP",
    ],
    "Surat keterangan usaha": [
      "Surat pengantar RT/RW",
      "Kartu keluarga",
      "KTP",
    ],
    "Surat Keterangan status": [
      "Surat pengantar RT/RW",
      "Kartu keluarga",
      "KTP",
    ],
    "Surat keterangan Harga tanah": [
      "Surat pengantar RT/RW",
      "Kartu keluarga",
      "KTP",
      "Sertifikat tanah",
      "SPPT terbaru",
    ],
    "Keterangan pemilikan tanah": [
      "Surat pengantar RT/RW",
      "Kartu keluarga",
      "KTP",
      "Sertifikat tanah",
      "SPPT terbaru",
    ],
    "Keterangan kematian": [
      "Surat pengantar RT/RW",
      "Kartu keluarga",
      "KTP",
      "Akta kelahiran",
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Panduan Persyaratan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.blue, size: 40),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo, ${user.nama}!",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "Pastikan dokumen di bawah ini siap sebelum mengajukan surat.",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List Panduan
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daftarSyarat.length,
              itemBuilder: (context, index) {
                String judul = daftarSyarat.keys.elementAt(index);
                List<String> syarat = daftarSyarat[judul]!;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: Colors.blue,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        judul,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      children: [
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Persyaratan Dokumen:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...syarat
                                  .map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FormPengajuanPage(user: user),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Ajukan Sekarang",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/surat_model.dart';
import '../../data/services/auth_service.dart';

class AdminVerifikasiPage extends StatelessWidget {
  final _authService = AuthService();

  AdminVerifikasiPage({super.key});

  Future<void> _cekBerkasWA(SuratModel surat) async {
    String pesan =
        "Halo, saya Admin Desa. Terkait pengajuan *${surat.jenisSurat}* Anda, saya ingin memverifikasi berkas yang dikirimkan.";
    var whatsappUrl = Uri.parse(
      "https://wa.me/?text=${Uri.encodeComponent(pesan)}",
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text(
          "Verifikasi Pengajuan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE67E22),
                Color(0xFFF39C12),
              ], // Gradasi Jingga untuk Verifikasi
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<SuratModel>>(
        stream: _authService.getAllSurat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final listPending =
              snapshot.data
                  ?.where((s) => s.status.toLowerCase() == "pending")
                  .toList() ??
              [];

          if (listPending.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Semua tugas selesai!",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    "Tidak ada pengajuan pending saat ini.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listPending.length,
            itemBuilder: (context, index) {
              final surat = listPending[index];
              return _buildVerifikasiCard(context, surat);
            },
          );
        },
      ),
    );
  }

  Widget _buildVerifikasiCard(BuildContext context, SuratModel surat) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          // Header Kartu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFDF2E9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.pending_actions,
                  color: Color(0xFFE67E22),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    surat.jenisSurat,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA04000),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blueGrey.shade100,
                      child: Text(
                        surat.namaPemohon[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surat.namaPemohon,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "NIK: ${surat.nikPemohon}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),
                const Text(
                  "Alasan Pengajuan:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  surat.alasan,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 15),

                // Tombol Cek WhatsApp
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _cekBerkasWA(surat),
                    icon: const Icon(Icons.image, size: 20),
                    label: const Text("LIHAT DOKUMEN DI WA"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade700,
                      side: BorderSide(color: Colors.green.shade700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Row Tombol Aksi
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showDialogProses(context, surat, "ditolak"),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text("TOLAK"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red.shade700,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.red.shade100),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showDialogProses(context, surat, "disetujui"),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text("SETUJUI"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDialogProses(
    BuildContext context,
    SuratModel surat,
    String status,
  ) {
    final pesanController = TextEditingController();
    final nomorController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              status == "disetujui" ? Icons.check_circle : Icons.cancel,
              color: status == "disetujui" ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Text(
              status == "disetujui" ? "Setujui" : "Tolak",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          // Tentukan lebar dan tinggi tetap agar dialog tidak berubah ukuran
          width: MediaQuery.of(context).size.width * 0.8,
          height: status == "disetujui"
              ? 280
              : 180, // Kunci tinggi berdasarkan status
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Tetap gunakan min agar tidak memaksa full screen
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (status == "disetujui") ...[
                const Text(
                  "Masukkan Nomor Surat:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nomorController,
                  decoration: InputDecoration(
                    hintText: "Contoh: 400/012/SKU/2026",
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                "Catatan / Pesan untuk Warga:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              // Gunakan Expanded atau tetap di dalam SizedBox agar TextField tidak 'mendorong' layout
              TextField(
                controller: pesanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: status == "disetujui"
                      ? "Surat sudah dapat diambil..."
                      : "Maaf, foto KTP kurang jelas...",
                  hintStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: status == "disetujui"
                  ? Colors.green
                  : Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (status == "disetujui" && nomorController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nomor surat wajib diisi!")),
                );
                return;
              }

              if (status == "disetujui") {
                await _authService.setujuiDenganNomorManual(
                  surat.id,
                  nomorController.text,
                  pesanController.text,
                );
              } else {
                await _authService.verifikasiSurat(
                  surat.id,
                  "ditolak",
                  pesanController.text,
                );
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("KONFIRMASI"),
          ),
        ],
      ),
    );
  }
}

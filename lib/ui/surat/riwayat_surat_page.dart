import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/surat_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../data/services/pdf_service.dart';

class RiwayatSuratPage extends StatelessWidget {
  final UserModel user;
  RiwayatSuratPage({super.key, required this.user});

  final _authService = AuthService();
  final _pdfService = PdfService();

  Future<void> _downloadSurat(BuildContext context, SuratModel surat) async {
    try {
      await _pdfService.cetakSurat(surat);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Riwayat Pengajuan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<SuratModel>>(
        stream: _authService.getSuratByUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          final listSurat = snapshot.data;

          if (listSurat == null || listSurat.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada riwayat pengajuan",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: listSurat.length,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemBuilder: (context, index) {
              final surat = listSurat[index];

              bool isDone =
                  surat.status.toLowerCase() == 'disetujui' ||
                  surat.status.toLowerCase() == 'selesai';

              bool isExpired = false;
              if (isDone && surat.tanggalSelesai != null) {
                final selisihHari = DateTime.now()
                    .difference(surat.tanggalSelesai!)
                    .inDays;
                if (selisihHari >= 7) isExpired = true;
              }

              bool showNotification = isDone && !isExpired;

              String tanggalTampil = DateFormat('dd MMM yyyy', 'id_ID').format(
                isDone && surat.tanggalSelesai != null
                    ? surat.tanggalSelesai!
                    : surat.tanggalPengajuan,
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: _buildLeadingIcon(
                        surat.status,
                        showNotification,
                      ),
                      title: Text(
                        surat.jenisSurat,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        "${isDone ? 'Selesai' : 'Diajukan'}: $tanggalTampil",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: _buildStatusChip(surat.status),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 1),
                              const SizedBox(height: 15),

                              // 1. MENAMPILKAN NOMOR SURAT
                              _buildInfoRow(
                                "Nomor Surat",
                                // Jika statusnya pending, tampilkan "Menunggu Verifikasi"
                                // Jika ditolak, tampilkan "-"
                                // Jika disetujui, tampilkan nomor suratnya
                                surat.status.toLowerCase() == 'pending'
                                    ? "Menunggu Verifikasi"
                                    : (surat.status.toLowerCase() == 'ditolak'
                                          ? "-"
                                          : (surat.nomorSurat ?? "-")),
                              ),

                              // 2. MENAMPILKAN TANGGAL PENGAJUAN (FORMAT AMAN)
                              _buildInfoRow(
                                "Tanggal Pengajuan",
                                DateFormat(
                                  'dd/MM/yyyy',
                                  'id_ID',
                                ).format(surat.tanggalPengajuan),
                              ),

                              const SizedBox(height: 15),

                              // Tombol Aksi
                              if (isDone && !isExpired)
                                _buildActionButton(
                                  onPressed: () =>
                                      _downloadSurat(context, surat),
                                  icon: Icons.picture_as_pdf,
                                  label: "Cetak Surat PDF",
                                  color: Colors.green,
                                )
                              else if (isDone && isExpired)
                                _buildStatusMessage(
                                  Icons.history,
                                  "Masa unduh berakhir (Batas 7 hari)",
                                  Colors.orange,
                                )
                              else if (surat.status.toLowerCase() == 'ditolak')
                                _buildStatusMessage(
                                  Icons.cancel_outlined,
                                  "Alasan: ${surat.pesanAdmin ?? 'Data tidak valid'}",
                                  Colors.red,
                                )
                              else
                                _buildStatusMessage(
                                  Icons.hourglass_bottom_rounded,
                                  "Sedang ditinjau oleh petugas",
                                  Colors.blueGrey,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildLeadingIcon(String status, bool notify) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
        color = Colors.green;
        icon = Icons.task_alt;
        break;
      case 'ditolak':
        color = Colors.red;
        icon = Icons.unpublished_outlined;
        break;
      default:
        color = Colors.orange;
        icon = Icons.sync;
    }

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        if (notify)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color =
        status.toLowerCase() == 'disetujui' || status.toLowerCase() == 'selesai'
        ? Colors.green
        : (status.toLowerCase() == 'ditolak' ? Colors.red : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage(IconData icon, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

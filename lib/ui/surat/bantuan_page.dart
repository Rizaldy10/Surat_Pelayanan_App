import 'package:flutter/material.dart';
import 'package:surat_pelayanan/data/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BantuanPage extends StatelessWidget {
  final UserModel user;
  const BantuanPage({super.key,required this.user});

  // Fungsi untuk membuka WhatsApp
  void _hubungiAdmin() async {
    const phone = "082146586030"; // Ganti dengan nomor kantor desa
    final url = Uri.parse("https://wa.me/$phone?text=Halo%20Admin%20Desa,%20saya%20butuh%20bantuan%20terkait%20layanan...");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Pusat Bantuan", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF3498DB), Color(0xFF2980B9)]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER - BANNER BANTUAN
            _buildHeaderBanner(),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text("Pertanyaan Populer (FAQ)", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            ),

            // LIST FAQ
            _buildFAQItem("Berapa lama proses verifikasi surat?", 
              "Proses verifikasi oleh admin biasanya memakan waktu 1x24 jam pada hari kerja."),
            _buildFAQItem("Bagaimana jika data NIK saya salah?", 
              "Silakan hubungi Admin melalui tombol WhatsApp di bawah untuk perbaikan data profil."),
            _buildFAQItem("Apakah saya harus datang ke kantor desa?", 
              "Jika status surat sudah 'Disetujui', Anda bisa mengunduh PDF-nya langsung. Namun untuk beberapa surat tertentu, Anda tetap perlu mengambil fisik di kantor."),
            _buildFAQItem("Kenapa pengajuan saya ditolak?", 
              "Periksa bagian 'Komentar Admin' pada riwayat pengajuan Anda. Biasanya karena foto dokumen kurang jelas atau syarat tidak lengkap."),

            const SizedBox(height: 30),

            // BUTTON HUBUNGI KAMI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildContactCard(
                    icon: Icons.chat_rounded,
                    color: Colors.green,
                    title: "Hubungi Admin via WhatsApp",
                    subtitle: "Respon cepat pada jam kerja (08:00 - 15:00)",
                    onTap: _hubungiAdmin,
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    icon: Icons.location_on_rounded,
                    color: Colors.redAccent,
                    title: "Lokasi Kantor Desa",
                    subtitle: "Jl. Balai Desa No. 01, Kec. Digital, Indonesia",
                    onTap: () {
                      // Bisa ditambah fungsi buka Google Maps
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
            child: const Icon(Icons.support_agent_rounded, size: 50, color: Colors.blue),
          ),
          const SizedBox(height: 15),
          const Text("Ada Kendala?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Kami siap membantu mempermudah urusan administrasi Anda.", 
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
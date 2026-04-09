import 'package:flutter/material.dart';
import 'package:surat_pelayanan/ui/admin/admin_laporan_page.dart';
import 'package:surat_pelayanan/ui/surat/bantuan_page.dart';
import 'package:surat_pelayanan/ui/surat/form_pengajuan_page.dart';
import 'package:surat_pelayanan/ui/surat/panduan_layanan_page.dart';
import 'package:surat_pelayanan/ui/surat/riwayat_surat_page.dart';
import '../admin/admin_tambah_surat_page.dart';
import '../admin/admin_verifikasi_page.dart';
import '../admin/admin_selesai_page.dart';
import '../admin/admin_dashboard_page.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/surat_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _authService = AuthService();

  bool _isNotifActive(SuratModel surat) {
    bool isDone = surat.status.toLowerCase() == 'disetujui' ||
                  surat.status.toLowerCase() == 'selesai';
    if (isDone && surat.tanggalSelesai != null) {
      final selisihHari = DateTime.now().difference(surat.tanggalSelesai!).inDays;
      return selisihHari < 7; 
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background profesional (Off-white)
      body: FutureBuilder<UserModel?>(
        future: _authService.getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Gagal memuat data user"));
          }

          final user = snapshot.data!;
          bool isAdmin = user.role == 'admin';

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, user, isAdmin),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Notifikasi naik sedikit ke area header
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: _buildNotificationBanner(user, isAdmin),
                      ),
                      const Text(
                        "Layanan Utama",
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436)
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: isAdmin 
                            ? _buildAdminMenu(user) 
                            : _buildWargaMenu(user),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- 1. HEADER MODERN DENGAN GRADIENT & LOGOUT ---
  Widget _buildHeader(BuildContext context, UserModel user, bool isAdmin) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAdmin 
            ? [Color.fromARGB(255, 88, 17, 17), Color.fromARGB(255, 196, 82, 82)] // Gradient Merah (Admin)
            : [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)], // Gradient Blue-Grey (Warga)
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAdmin ? "Mode Administrator" : "Halo, Selamat Datang ",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                user.nama,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                "NIK: ${user.nik}",
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          IconButton(
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          )
        ],
      ),
    );
  }

  // --- 2. BANNER NOTIFIKASI DINAMIS ---
  Widget _buildNotificationBanner(UserModel user, bool isAdmin) {
    return StreamBuilder<List<SuratModel>>(
      stream: isAdmin ? _authService.getAllSurat() : _authService.getSuratByUser(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int count = 0;
          String pesan = "";
          Color warnaTema = isAdmin ? Colors.orange : Colors.green;

          if (isAdmin) {
            count = snapshot.data!.where((s) => s.status.toLowerCase() == 'pending').length;
            pesan = "Ada $count surat baru yang butuh verifikasi.";
          } else {
            count = snapshot.data!.where((s) => _isNotifActive(s)).length;
            pesan = "Ada $count surat kamu yang sudah selesai.";
          }
          
          if (count > 0) {
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, spreadRadius: 2),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: warnaTema.withOpacity(0.1),
                    child: Icon(Icons.notifications_active, color: warnaTema, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pesan,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }
        }
        return const SizedBox(height: 50); // Spacer jika tidak ada notif
      },
    );
  }

  // --- 3. MENU LISTS ---
  List<Widget> _buildWargaMenu(UserModel user) {
    return [
      _menuItem(Icons.description, "Ajukan Surat", Colors.blue, user),
      _menuItem(Icons.history, "Riwayat Saya", Colors.orange, user),
      _menuItem(Icons.info_outline, "Panduan", Colors.green, user),
      _menuItem(Icons.help_center_rounded, "Bantuan", Colors.purple, user),
    ];
  }

  List<Widget> _buildAdminMenu(UserModel user) {
    return [
      _menuItem(Icons.assignment_late, "Perlu Verifikasi", Colors.orange, user),
      _menuItem(Icons.edit_document, "Layanan Kantor", Colors.teal, user),
      _menuItem(Icons.done_all, "Surat Selesai", Colors.green, user),
      _menuItem(Icons.people, "Data Warga", Colors.purple, user),
_menuItem(Icons.analytics_rounded, "Laporan Analitik", Colors.blueAccent, user),
    ];
  }

  // --- 4. WIDGET ITEM MENU (PROFESSIONAL LOOK) ---
  Widget _menuItem(IconData icon, String label, Color color, UserModel user) {
    return InkWell(
      onTap: () {
        if (label == "Ajukan Surat") Navigator.push(context, MaterialPageRoute(builder: (context) => FormPengajuanPage(user: user)));
        else if (label == "Riwayat Saya") Navigator.push(context, MaterialPageRoute(builder: (context) => RiwayatSuratPage(user: user)));
        else if (label == "Panduan") Navigator.push(context, MaterialPageRoute(builder: (context) => PanduanLayananPage(user: user))); 
        else if (label == "Bantuan") Navigator.push(context, MaterialPageRoute(builder: (context) => BantuanPage(user: user))); 
        else if (label == "Perlu Verifikasi") Navigator.push(context, MaterialPageRoute(builder: (context) => AdminVerifikasiPage()));
        else if (label == "Layanan Kantor") Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminTambahSuratPage()));
        else if (label == "Surat Selesai") Navigator.push(context, MaterialPageRoute(builder: (context) => AdminSelesaiPage()));
        else if (label == "Data Warga") Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage()));
        else if (label == "Laporan Analitik") Navigator.push(context, MaterialPageRoute(builder: (context) => AdminLaporanPage()));
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  label, 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436), fontSize: 13), 
                  textAlign: TextAlign.center
                ),
              ],
            ),
          ),
          
          // Badge Logic
          if (label == "Riwayat Saya" || label == "Perlu Verifikasi")
            Positioned(
              right: 15,
              top: 15,
              child: StreamBuilder<List<SuratModel>>(
                stream: label == "Riwayat Saya" 
                    ? _authService.getSuratByUser(user.uid) 
                    : _authService.getAllSurat(),
                builder: (context, snapshot) {
                  int count = 0;
                  if (label == "Riwayat Saya") {
                    count = snapshot.data?.where((s) => _isNotifActive(s)).length ?? 0;
                  } else {
                    count = snapshot.data?.where((s) => s.status.toLowerCase() == 'pending').length ?? 0;
                  }
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      "$count", 
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
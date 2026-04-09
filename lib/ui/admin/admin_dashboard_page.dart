import 'package:flutter/material.dart';
import '../../data/models/surat_model.dart';
import '../../data/services/auth_service.dart';
import 'admin_tambah_surat_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _authService = AuthService();
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Database Warga", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: "Cari Nama atau NIK Warga...",
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(Icons.person_search, color: Color(0xFF2C3E50)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<SuratModel>>(
        stream: _authService.getAllSurat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final filteredList = snapshot.data!.where((s) {
            return s.namaPemohon.toLowerCase().contains(_searchQuery) ||
                s.nikPemohon.contains(_searchQuery);
          }).toList();

          return ListView.builder(
            itemCount: filteredList.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final surat = filteredList[index];
              return _buildWargaCard(context, surat);
            },
          );
        },
      ),
    );
  }

  Widget _buildWargaCard(BuildContext context, SuratModel surat) {
    bool isOffline = surat.uidPemohon == "OFFLINE";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOptions(context, surat),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: isOffline ? Colors.teal.shade50 : Colors.blue.shade50,
                      child: Icon(Icons.person, color: isOffline ? Colors.teal : Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(surat.namaPemohon, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50))),
                          Text("NIK: ${surat.nikPemohon}", 
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOffline ? Colors.teal.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOffline ? "OFFLINE" : "ONLINE",
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold, 
                          color: isOffline ? Colors.teal : Colors.blue
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildInfoRow(Icons.description_outlined, "Layanan", surat.jenisSurat),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.confirmation_number_outlined, "No. Surat", surat.nomorSurat ?? "Belum Terbit"),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.info_outline, "Alasan", surat.alasan, isItalic: true),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.more_horiz, color: Colors.grey),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isItalic = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12, 
              color: Colors.black87,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Data warga masih kosong", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, SuratModel surat) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Wrap(
          children: [
            const Center(
              child: Text("MANAJEMEN DATA", 
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.edit_rounded, color: Colors.blue),
              ),
              title: const Text("Update / Edit Data", style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminTambahSuratPage(editSurat: surat)));
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.delete_forever_rounded, color: Colors.red),
              ),
              title: const Text("Hapus Data Permanen", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, surat);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SuratModel surat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Konfirmasi Hapus"),
        content: Text("Data warga atas nama ${surat.namaPemohon} akan dihapus permanen. Lanjutkan?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("BATAL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              await _authService.hapusSurat(surat.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("YA, HAPUS"),
          ),
        ],
      ),
    );
  }
}
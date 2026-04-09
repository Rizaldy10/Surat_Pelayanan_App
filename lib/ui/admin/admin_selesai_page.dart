import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/surat_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/pdf_service.dart';
import 'package:collection/collection.dart';

class AdminSelesaiPage extends StatefulWidget {
  const AdminSelesaiPage({super.key});

  @override
  State<AdminSelesaiPage> createState() => _AdminSelesaiPageState();
}

class _AdminSelesaiPageState extends State<AdminSelesaiPage> {
  final _authService = AuthService();
  final _pdfService = PdfService();
  String _searchQuery = ""; 
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Arsip Pelayanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                  hintText: "Cari Nama atau Nomor Surat...",
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF2C3E50)),
                  suffixIcon: _searchQuery.isNotEmpty 
                    ? IconButton(icon: const Icon(Icons.cancel, size: 20), onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      }) 
                    : null,
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

          var listSelesai = snapshot.data
                  ?.where((s) => s.status.toLowerCase() != "pending")
                  .toList() ?? [];

          if (_searchQuery.isNotEmpty) {
            listSelesai = listSelesai.where((surat) {
              return surat.namaPemohon.toLowerCase().contains(_searchQuery) || 
                     (surat.nomorSurat ?? "").toLowerCase().contains(_searchQuery);
            }).toList();
          }

          if (listSelesai.isEmpty) {
            return _buildEmptyState();
          }

          listSelesai.sort((a, b) => (b.tanggalSelesai ?? b.tanggalPengajuan)
              .compareTo(a.tanggalSelesai ?? a.tanggalPengajuan));

          final groupedSurat = groupBy(listSelesai, (SuratModel s) {
            return DateFormat('yyyy-MM-dd').format(s.tanggalSelesai ?? s.tanggalPengajuan);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedSurat.keys.length,
            itemBuilder: (context, index) {
              String dateKey = groupedSurat.keys.elementAt(index);
              List<SuratModel> items = groupedSurat[dateKey]!;
              return _buildGroupSection(dateKey, items);
            },
          );
        },
      ),
    );
  }

  Widget _buildGroupSection(String dateKey, List<SuratModel> items) {
    DateTime date = DateTime.parse(dateKey);
    String label = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
          child: Row(
            children: [
              Container(width: 4, height: 16, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF566573), fontSize: 13)),
            ],
          ),
        ),
        ...items.map((surat) => _buildSuratItem(surat)).toList(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSuratItem(SuratModel surat) {
    bool isApprove = surat.status.toLowerCase() == "disetujui";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Indikator Warna Samping
              Container(width: 6, color: isApprove ? Colors.green : Colors.red),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Icon Status
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isApprove ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(isApprove ? Icons.check_circle_rounded : Icons.cancel_rounded, 
                                   color: isApprove ? Colors.green : Colors.red, size: 24),
                      ),
                      const SizedBox(width: 12),
                      // Konten Teks
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(surat.namaPemohon, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(surat.jenisSurat, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            if (surat.nomorSurat != null) ...[
                              const SizedBox(height: 4),
                              Text("Nomor Surat: ${surat.nomorSurat}", 
                                style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 11, fontWeight: FontWeight.bold)),
                            ]
                          ],
                        ),
                      ),
                      // Tombol Aksi
                      if (isApprove)
                        IconButton(
                          onPressed: () => _pdfService.cetakSurat(surat),
                          icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.blueAccent),
                          tooltip: "Cetak PDF",
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.info_outline, color: Colors.grey, size: 20),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Arsip tidak ditemukan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}
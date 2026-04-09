import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/surat_model.dart';
import '../../data/services/auth_service.dart';

class AdminLaporanPage extends StatelessWidget {
  final _authService = AuthService();

  AdminLaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: StreamBuilder<List<SuratModel>>(
        stream: _authService.getAllSurat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data tidak tersedia"));
          }

          final data = snapshot.data!;
          int total = data.length;
          int disetujui = data.where((s) => s.status.toLowerCase() == "disetujui").length;
          int ditolak = data.where((s) => s.status.toLowerCase() == "ditolak").length;
          int pending = data.where((s) => s.status.toLowerCase() == "pending").length;

          return CustomScrollView(
            slivers: [
              // --- APPBAR ---
              SliverAppBar(
                elevation: 0,
                pinned: true,
                centerTitle: true,
                backgroundColor: const Color(0xFF2C3E50),
                toolbarHeight: kToolbarHeight, 
                title: const Text(
                  "Analitik Pelayanan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // --- 1. RINGKASAN ANGKA (STAT CARDS) ---
                    Row(
                      children: [
                        _buildStatCard("Total", total.toString(), Colors.blue),
                        _buildStatCard("Pending", pending.toString(), Colors.orange),
                        _buildStatCard("Selesai", disetujui.toString(), Colors.green),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- 2. GRAFIK PIE ---
                    _buildSectionTitle("Komposisi Status Surat"),
                    _buildChartCard(
                      child: Row(
                        children: [
                          SizedBox(
                            height: 140, width: 140,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 30,
                                sections: [
                                  PieChartSectionData(value: disetujui.toDouble(), color: Colors.green, radius: 35, showTitle: false),
                                  PieChartSectionData(value: ditolak.toDouble(), color: Colors.red, radius: 35, showTitle: false),
                                  PieChartSectionData(value: pending.toDouble(), color: Colors.orange, radius: 35, showTitle: false),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(child: _buildSimpleLegend(disetujui, ditolak, pending)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // --- 3. GRAFIK BATANG ---
                    _buildSectionTitle("Tren Pengajuan Bulanan"),
                    _buildChartCard(
                      child: SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) => Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'][val.toInt() % 6],
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            barGroups: _generateBarGroups(data),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    
                    // --- 4. LIST AKTIVITAS TERBARU ---
                    _buildSectionTitle("Aktivitas Terbaru"),
                    ...data.reversed.take(5).map((s) => _buildRecentActivityItem(s)).toList(),
                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08), // Aksen warna tipis di background card
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
    );
  }

  Widget _buildChartCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: child,
    );
  }

  Widget _buildSimpleLegend(int ok, int no, int wait) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendRow("Selesai", ok, Colors.green),
        _legendRow("Ditolak", no, Colors.red),
        _legendRow("Pending", wait, Colors.orange),
      ],
    );
  }

  Widget _legendRow(String label, int val, Color col) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87))),
          Text(val.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRecentActivityItem(SuratModel surat) {
    // Logika warna dinamis berdasarkan status
    Color statusColor;
    switch (surat.status.toLowerCase()) {
      case 'disetujui': statusColor = Colors.green; break;
      case 'ditolak': statusColor = Colors.red; break;
      default: statusColor = Colors.orange; // pending
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.description_outlined, size: 20, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(surat.jenisSurat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(surat.namaPemohon, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          // --- BADGE STATUS DENGAN WARNA ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              surat.status.toUpperCase(),
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<SuratModel> data) {
    return List.generate(6, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: (i * 1.5 + 4).toDouble(),
            color: const Color(0xFF4CA1AF),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(show: true, toY: 15, color: Colors.grey[50]),
          ),
        ],
      );
    });
  }
}
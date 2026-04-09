import 'package:flutter/material.dart';
import '../../data/models/surat_model.dart';
import '../../data/services/auth_service.dart';

class AdminTambahSuratPage extends StatefulWidget {
  final SuratModel? editSurat;

  const AdminTambahSuratPage({super.key, this.editSurat});

  @override
  State<AdminTambahSuratPage> createState() => _AdminTambahSuratPageState();
}

class _AdminTambahSuratPageState extends State<AdminTambahSuratPage> {
  final _authService = AuthService();
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _alasanController = TextEditingController();

  String? _selectedSurat;
  bool _isLoading = false;

  final Map<String, List<String>> _jenisSurat = {
    "Surat Rekomendasi Pembelian BBM": ["Surat pengantar RT/RW", "Kartu keluarga", "KTP"],
    "Surat penghasilan orang tua": ["Surat pengantar RT/RW", "Kartu keluarga", "KTP"],
    "Surat pengenal kelahiran": ["Surat pengantar RT/RW", "Kartu keluarga", "KTP", "Buku nikah orang tua"],
    "Surat Keterangan kehilangan": ["Surat pengantar RT/RW", "Kartu keluarga", "KTP", "Pelaporan kehilangan dari polsek"],
    "Surat Keterangan bepergian sementara": ["Surat pengantar RT/RW", "Kartu keluarga", "KTP", "Pas photo terbaru 4x6"],
    "Pengantar SKCK": ["Surat pengantar RT/RW", "Kartu keluarga", "KTP", "Akta kelahiran", "Ijazah terakhir", "Pas photo 4x6 background merah"],
    "Surat keterangan domisili": ["Surat pengantar RT/RW", "Kartu keluarga", "KTP"],
    "Surat keterangan usaha": ["Surat pengantar RT/RW", "Kartu keluarga", "KTP"],
    "Surat Keterangan status": ["Surat pengantar RT/RW", "Kartu keluarga", "KTP"],
    "Surat keterangan Harga tanah": ["Surat pengantar RT/RW", "Kartu keluarga", "KTP", "Sertifikat tanah", "SPPT terbaru"],
    "Keterangan pemilikan tanah": ["Surat pengantar RT/RW", "Kartu keluarga", "KTP", "Sertifikat tanah", "SPPT terbaru"],
    "Keterangan kematian": ["Surat pengantar RT/RW", "Kartu keluarga", "KTP", "Akta kelahiran"],
  };

  @override
  void initState() {
    super.initState();
    if (widget.editSurat != null) {
      _namaController.text = widget.editSurat!.namaPemohon;
      _nikController.text = widget.editSurat!.nikPemohon;
      _alasanController.text = widget.editSurat!.alasan;
      _selectedSurat = widget.editSurat!.jenisSurat;
    }
  }

  void _simpanData() async {
    if (_namaController.text.isEmpty || _nikController.text.isEmpty || _selectedSurat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi Nama, NIK, dan Jenis Surat!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.editSurat == null) {
        final suratBaru = SuratModel(
          id: '',
          uidPemohon: "OFFLINE",
          namaPemohon: _namaController.text,
          nikPemohon: _nikController.text,
          jenisSurat: _selectedSurat!,
          alasan: _alasanController.text,
          status: 'disetujui',
          tanggalPengajuan: DateTime.now(),
          pesanAdmin: "Input manual oleh Admin",
        );
        await _authService.ajukanSurat(suratBaru);
      } else {
        await _authService.updateDataSuratManual(widget.editSurat!.id, {
          'namaPemohon': _namaController.text,
          'nikPemohon': _nikController.text,
          'jenisSurat': _selectedSurat,
          'alasan': _alasanController.text,
        });
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.editSurat == null ? "Data Berhasil Ditambah" : "Data Berhasil Diperbarui")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.editSurat != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        elevation: 0,
        title: Text(isEdit ? "Edit Data" : "Input Manual", 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: isEdit ? Colors.orange.shade800 : const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(isEdit),
                  const SizedBox(height: 20),
                  
                  // Card Informasi Warga
                  _buildFormCard(
                    title: "Informasi Warga",
                    icon: Icons.person_search_rounded,
                    children: [
                      _buildTextField(
                        controller: _namaController,
                        label: "Nama Lengkap Warga",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _nikController,
                        label: "NIK Warga",
                        icon: Icons.badge_outlined,
                        isNumber: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // Card Detail Surat
                  _buildFormCard(
                    title: "Detail Pelayanan",
                    icon: Icons.description_outlined,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedSurat,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Jenis Surat",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.list_alt),
                        ),
                        items: _jenisSurat.keys.map((e) => DropdownMenuItem(
                          value: e, 
                          child: Text(e, style: const TextStyle(fontSize: 12))
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedSurat = val),
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _alasanController,
                        label: "Keterangan Tambahan",
                        icon: Icons.notes,
                        maxLines: 3,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  
                  // Tombol Aksi
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _simpanData,
                      icon: Icon(isEdit ? Icons.save : Icons.add_task),
                      label: Text(isEdit ? "PERBARUI DATA" : "SIMPAN PELAYANAN", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEdit ? Colors.orange.shade800 : const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection(bool isEdit) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isEdit ? Colors.orange.withOpacity(0.1) : Colors.blueGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isEdit ? Colors.orange.withOpacity(0.3) : Colors.blueGrey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: isEdit ? Colors.orange.shade900 : Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isEdit 
                ? "Pastikan data yang diubah sudah sesuai dengan dokumen fisik warga." 
                : "Menu ini digunakan untuk mencatat warga yang datang langsung ke kantor (Layanan Offline).",
              style: TextStyle(fontSize: 12, color: isEdit ? Colors.orange.shade900 : Colors.blueGrey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2C3E50)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50))),
            ],
          ),
          const Divider(height: 30),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
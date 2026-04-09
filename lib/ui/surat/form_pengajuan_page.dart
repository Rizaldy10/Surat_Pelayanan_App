import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/user_model.dart';
import '../../data/models/surat_model.dart';
import '../../data/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FormPengajuanPage extends StatefulWidget {
  final UserModel user;
  const FormPengajuanPage({super.key, required this.user});

  @override
  State<FormPengajuanPage> createState() => _FormPengajuanPageState();
}

class _FormPengajuanPageState extends State<FormPengajuanPage> {
  final _authService = AuthService();
  final _alasanController = TextEditingController();

  String? _selectedSurat;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  int _currentStep = 0;

  final Map<String, List<String>> _syaratSurat = {
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

  Future<void> _ambilGambar(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _submitPengajuan() async {
    if (_selectedSurat == null || _alasanController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data dan dokumen!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final suratBaru = SuratModel(
        id: '',
        uidPemohon: widget.user.uid,
        namaPemohon: widget.user.nama,
        nikPemohon: widget.user.nik,
        jenisSurat: _selectedSurat!,
        alasan: _alasanController.text,
        status: 'pending',
        tanggalPengajuan: DateTime.now(),
        urlBerkas: 'Kirim via WhatsApp',
      );

      await _authService.ajukanSurat(suratBaru);

      String nomorAdmin = "628123456789"; 
      String isiPesan = "Halo Admin Desa, saya telah mengajukan surat.\n\n"
          "*Data Pengajuan:*\n"
          "Nama: ${widget.user.nama}\n"
          "Jenis: $_selectedSurat\n"
          "Alasan: ${_alasanController.text}";

      var whatsappUrl = Uri.parse("https://wa.me/$nomorAdmin?text=${Uri.encodeComponent(isiPesan)}");
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil! Silakan kirim berkas di WhatsApp.")),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Pengajuan Surat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF2C3E50)),
            ),
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 2) {
                  setState(() => _currentStep += 1);
                } else {
                  _submitPengajuan();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) setState(() => _currentStep -= 1);
              },
              controlsBuilder: (context, controls) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controls.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CA1AF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(_currentStep == 2 ? "KIRIM SEKARANG" : "LANJUT"),
                        ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: controls.onStepCancel,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("KEMBALI"),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                // LANGKAH 1: PILIH SURAT
                Step(
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                  title: const Text("Pilih Jenis Surat", style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Column(
                    children: [
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.mail_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        hint: const Text("--- Pilih Surat ---"),
                        items: _syaratSurat.keys.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (val) => setState(() => _selectedSurat = val),
                      ),
                      if (_selectedSurat != null) _buildSyaratBox(),
                    ],
                  ),
                ),
                // LANGKAH 2: ALASAN
                Step(
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                  title: const Text("Detail Alasan", style: TextStyle(fontWeight: FontWeight.bold)),
                  content: TextField(
                    controller: _alasanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Contoh: Untuk keperluan beasiswa perkuliahan...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                // LANGKAH 3: UNGGAH
                Step(
                  isActive: _currentStep >= 2,
                  title: const Text("Unggah Dokumen", style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Column(
                    children: [
                      const Text("Pastikan semua dokumen asli difoto dengan jelas dalam satu frame atau digabung.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 15),
                      _imageFile != null
                          ? _buildImagePreview()
                          : _buildUploadButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSyaratBox() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text("Syarat yang harus disiapkan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const Divider(),
          ..._syaratSurat[_selectedSurat]!.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("• $s", style: const TextStyle(fontSize: 12)),
              )),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return InkWell(
      onTap: () => _showPickerOptions(),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 10),
            Text("Ketuk untuk Unggah Foto", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
        ),
        TextButton.icon(
          onPressed: () => _showPickerOptions(),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text("Ganti Foto"),
        ),
      ],
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galeri'), onTap: () { _ambilGambar(ImageSource.gallery); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Kamera'), onTap: () { _ambilGambar(ImageSource.camera); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }
}
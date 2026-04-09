import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/surat_model.dart';

class PdfService {
  Future<void> cetakSurat(SuratModel surat) async {
    final pdf = pw.Document();
    
    // Pastikan format tanggal aman jika intl belum inisialisasi
    String tanggalHariIni = "";
    try {
      tanggalHariIni = DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now());
    } catch (e) {
      tanggalHariIni = DateFormat('dd-MM-yyyy').format(DateTime.now());
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // KOP SURAT
                pw.Text("PEMERINTAH KABUPATEN CONTOH",
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text("KECAMATAN PELAYANAN DIGITAL",
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text("KANTOR KEPALA DESA MAJU JAYA",
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text("Alamat: Jl. Poros Desa No. 01, Kode Pos 12345",
                    style: const pw.TextStyle(fontSize: 10)),
                pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 5),
                  height: 1.5,
                  color: PdfColors.black,
                ),
                pw.SizedBox(height: 20),

                // JUDUL SURAT
                pw.Text(
                  surat.jenisSurat.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
                // PERBAIKAN: Pastikan memanggil properti yang benar dari model
                pw.Text(
                  "Nomor: ${surat.nomorSurat ?? '-'}",
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 30),

                // ISI SURAT
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Yang bertanda tangan di bawah ini, Kepala Desa Maju Jaya menerangkan bahwa:"),
                      pw.SizedBox(height: 15),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 20),
                        child: pw.Column(
                          children: [
                            _rowData("Nama", ": ${surat.namaPemohon}"),
                            _rowData("NIK", ": ${surat.nikPemohon}"),
                            _rowData("Keperluan", ": ${surat.alasan}"),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Text("Demikian surat keterangan ini dibuat untuk dapat dipergunakan sebagaimana mestinya."),
                    ],
                  ),
                ),

                pw.SizedBox(height: 50),

                // TANDA TANGAN
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    children: [
                      pw.Text("Maju Jaya, $tanggalHariIni"),
                      pw.Text("Kepala Desa Maju Jaya"),
                      pw.SizedBox(height: 60),
                      pw.Text(
                        "( ____________________ )",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Surat_${surat.namaPemohon}.pdf',
    );
  }

  pw.Widget _rowData(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 100, child: pw.Text(label)),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}
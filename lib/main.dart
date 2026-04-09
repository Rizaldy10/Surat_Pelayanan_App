import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ui/auth/login_page.dart';
import 'ui/dashboard/dashboard_page.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  // 1. Wajib: Pastikan Flutter Engine sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Wajib: Inisialisasi Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3. Wajib: Inisialisasi Format Tanggal untuk PDF (yang tadi kita tambahkan)
    await initializeDateFormatting('id_ID', null);

    print("Firebase & Intl Berhasil Diinisialisasi");
  } catch (e) {
    print("Gagal Inisialisasi: $e");
  }

  // 4. Jalankan Aplikasi
  runApp(const MyApp());
}

class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform => null;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Di dalam class MyApp, ubah home: menjadi seperti ini:
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Jika user sudah login, tampilkan Dashboard
          if (snapshot.hasData) {
            return const DashboardPage();
          }
          // Jika belum login, tampilkan halaman Login
          return const LoginPage();
        },
      ),
    );
  }
}

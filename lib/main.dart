import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import halaman-halaman Anda (Sesuaikan path jika berbeda)
import 'auth/get_started_page.dart'; 
import 'screens/main_nav.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Wajib await
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MeetYourFoods',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      
      // --- PENTING: JANGAN GUNAKAN 'routes' ATAU 'initialRoute' DI SINI ---
      // Biarkan 'home' yang mengatur logika navigasi awal
      home: const AuthGate(), 
    );
  }
}

// Widget Khusus untuk Mengecek Status Login (Gatekeeper)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Saat aplikasi baru buka dan sedang cek ke Firebase (Loading)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00C853)),
            ),
          );
        }

        // 2. Jika User DITEMUKAN (Sudah Login) -> Masuk Home
        if (snapshot.hasData) {
          return const MainNavWrapper(); 
        }

        // 3. Jika User TIDAK DITEMUKAN (Belum Login) -> Masuk Get Started
        return const GetStartedPage(); 
      },
    );
  }
}
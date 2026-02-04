import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              // --- 1. HEADER LOGO SENDIRI ---
              Row(
                children: [
                  // Ganti Icon dengan Image.asset untuk Logo
                  Image.asset(
                    'assets/Logo MeetYourFoods.png', 
                    height: 24, // Sesuaikan ukuran logo
                    width: 24,
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.fastfood, color: Color(0xFF00C853)), // Fallback jika gagal
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "MeetYourFoods", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ],
              ),
              
              const Spacer(), // Dorong ilustrasi ke tengah
              
              // --- 2. ILUSTRASI GAMBAR ---
              // Pastikan file 'assets/illustration.png' sudah ada
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset(
                  'assets/Food_Illustration.png',
                  height: 250, // Atur tinggi sesuai kebutuhan
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(), // Dorong teks ke bawah
              
              // --- 3. JUDUL BESAR (CENTERED) ---
              RichText(
                textAlign: TextAlign.center, // Rata tengah sesuai desain
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32, // Ukuran font disesuaikan agar muat
                    fontWeight: FontWeight.w900, 
                    color: Colors.black, 
                    height: 1.2,
                    fontFamily: 'Inter', // Jika pakai custom font
                  ),
                  children: [
                    TextSpan(text: "Find Your "),
                    TextSpan(text: "Perfect\n", style: TextStyle(color: Color(0xFF00C853))),
                    TextSpan(text: "Meal", style: TextStyle(color: Color(0xFF00C853))),
                    TextSpan(text: " Matches"),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Button Get Started
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Lebih bulat
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Get Started", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_outward, size: 18)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login Link
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                },
                child: RichText(
                  text: const TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    children: [
                      // Warna Merah/Pink sesuai gambar referensi, atau Hijau jika ingin konsisten
                      TextSpan(
                        text: "Login", 
                        style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold) // Merah muda seperti gambar
                      ), 
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
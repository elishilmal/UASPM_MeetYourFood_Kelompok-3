import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // --- DATA ANGGOTA KELOMPOK ---
  final List<Map<String, String>> members = const [
    {'name': 'Challik Ruben', 'npm': '23552011333'},
    {'name': 'Elis Hilmal Muhibah Syawalah', 'npm': '23552011313'},
    {'name': 'Helmi Ahmad Fauzan', 'npm': '23552011433'},
    {'name': 'Hilmy Muhamad Dzakwan', 'npm': '23552011368'},
    {'name': 'Muhammad Fahmi Abdul Majiid', 'npm': '23552011423'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("About App", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              
              // --- 1. LOGO BUATAN SENDIRI ---
              // Pastikan file 'assets/logo.png' sudah ada dan didaftarkan di pubspec.yaml
              Container(
                width: 140, 
                height: 140,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(255, 249, 255, 250),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: ClipOval(
                  // Ganti Icon dengan Image.asset
                  child: Image.asset(
                    'assets/Logo MeetYourFoods.png', 
                    fit: BoxFit.contain, // Agar gambar pas di dalam lingkaran
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback jika gambar belum ada/error: Tampilkan Icon
                      return const Icon(Icons.fastfood, size: 60, color: Color(0xFF00C853));
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 25),
              
              // Nama Aplikasi
              const Text(
                "MeetYourFoods", 
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF00C853))
              ),
              const Text(
                "v1.0.0", 
                style: TextStyle(fontSize: 12, color: Colors.grey)
              ),

              const SizedBox(height: 15),

              // --- 2. DESKRIPSI LEBIH MENARIK ---
              const Text(
                "Stop Drama 'Terserah Mau Makan Apa'!",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "MeetYourFoods hadir sebagai matchmaker kuliner pribadimu. Kami membantumu menemukan 'jodoh' makanan & minuman terbaik sesuai selera dan suasana hati.\n\nSwipe, Match, & Eat!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], height: 1.5),
              ),
              
              const SizedBox(height: 40),

              // --- KOTAK COPYRIGHT (Team Members) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00C853).withOpacity(0.5), 
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C853).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5)
                    )
                  ]
                ),
                child: Column(
                  children: [
                    const Text(
                      "Developed by Team",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 14,
                        color: Colors.black54,
                        letterSpacing: 1.0
                      ),
                    ),
                    const Divider(height: 30, thickness: 1, indent: 50, endIndent: 50),
                    
                    // Generate List Nama Anggota
                    ...members.map((member) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              member['name']!,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              member['npm']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C853), fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Footer kecil
              const Text(
                "MeetYourFoods © 2026",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
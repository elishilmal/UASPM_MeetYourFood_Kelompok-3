import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _handleResetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan email Anda terlebih dahulu")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // --- FUNGSI UTAMA FIREBASE ---
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        // Tampilkan Dialog Sukses
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Email Terkirim"),
            content: Text("Link reset password telah dikirim ke $email. Silakan cek inbox atau folder spam Anda."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup Dialog
                  Navigator.pop(context); // Kembali ke Halaman Login
                },
                child: const Text("OK", style: TextStyle(color: Color(0xFF00C853))),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan.";
      if (e.code == 'user-not-found') {
        message = "Email tidak terdaftar.";
      } else if (e.code == 'invalid-email') {
        message = "Format email salah.";
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Forgot Password?",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00C853)),
            ),
            const SizedBox(height: 10),
            const Text(
              "Don't worry! It happens. Please enter the address associated with your account.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Input Email
            const Text("Email ID", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Enter your email",
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.alternate_email, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 30),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoading ? null : _handleResetPassword,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../screens/main_nav.dart';
import '../screens/components/custom_popup.dart'; // Import Custom Popup
import 'login_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  // Style Input Field (Reusable)
  final inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.grey[100], // Abu muda
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), // Sudut melengkung
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  );

  void _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showCustomPopup(context, "Incomplete Data", "Semua field harus diisi.", isError: true);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showCustomPopup(context, "Password Mismatch", "Password dan konfirmasi tidak cocok.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().register(
        _emailController.text.trim(), 
        _passwordController.text.trim()
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (user != null) {
          // Sukses -> Masuk ke MainNav
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (context) => const MainNavWrapper()), 
            (route) => false
          );
        } else {
          showCustomPopup(context, "Registration Failed", "Gagal mendaftar. Silakan coba lagi.", isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showCustomPopup(context, "Error", "Terjadi kesalahan: ${e.toString()}", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Kembali ke Login Page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                
                // JUDUL BESAR
                const Text(
                  "Register", 
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.w800, 
                    color: Color(0xFF00C853) // Hijau Branding
                  )
                ),
                
                const SizedBox(height: 30),

                // INPUT NAMA
                _buildLabel("Name"),
                TextField(
                  controller: _nameController,
                  decoration: inputDecoration.copyWith(hintText: "Enter Your Name"),
                ),
                const SizedBox(height: 20),

                // INPUT EMAIL
                _buildLabel("Email"),
                TextField(
                  controller: _emailController,
                  decoration: inputDecoration.copyWith(hintText: "Enter Email"),
                ),
                const SizedBox(height: 20),
                
                // INPUT PASSWORD
                _buildLabel("Password"),
                TextField(
                  controller: _passwordController,
                  obscureText: _isPasswordHidden,
                  decoration: inputDecoration.copyWith(
                    hintText: "********",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // INPUT CONFIRM PASSWORD
                _buildLabel("Confirm Password"),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordHidden,
                  decoration: inputDecoration.copyWith(
                    hintText: "********",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordHidden ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _isConfirmPasswordHidden = !_isConfirmPasswordHidden),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // TOMBOL REGISTER HITAM
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Hitam Pekat
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Bulat Kapsul
                      elevation: 5,
                    ),
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                      : const Text("Register", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 130),

                // FOOTER LOGIN LINK
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
                    child: RichText(
                      text: const TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              color: Color(0xFF00C853), // Hijau Branding
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper Label Kecil di atas Input
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
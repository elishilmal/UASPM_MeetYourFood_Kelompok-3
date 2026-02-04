import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../screens/main_nav.dart';
import '../screens/components/custom_popup.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'get_started_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordHidden = true;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    final user = await AuthService().login(
      _emailController.text.trim(), 
      _passwordController.text.trim()
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const MainNavWrapper()), 
          (route) => false
        );
      } else {
        showCustomPopup(context, "Login Failed", "Email atau Password salah.", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Pakai pushAndRemoveUntil agar tidak bisa back lagi ke login
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const GetStartedPage()),
              (route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
        // PERBAIKAN UTAMA: Tambahkan LayoutBuilder + SingleChildScrollView
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      const Text(
                        "Login", 
                        style: TextStyle(
                          fontSize: 32, 
                          fontWeight: FontWeight.w800, 
                          color: Color(0xFF00C853)
                        )
                      ),
                      
                      const SizedBox(height: 40),

                      const Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: inputDecoration.copyWith(hintText: "Enter Email"),
                      ),
                      
                      const SizedBox(height: 20),

                      const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
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

                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
                          },
                          child: const Text(
                            "Forgot Password?", 
                            style: TextStyle(
                              color: Color(0xFF00C853), 
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                            )
                  ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 5,
                          ),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                            : const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      
                      const SizedBox(height: 290),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                          child: RichText(
                            text: const TextSpan(
                              text: "Don't have an account yet? ",
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: "Register",
                                  style: TextStyle(
                                    color: Colors.red,
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
            );
          },
        ),
      ),
    );
  }
}
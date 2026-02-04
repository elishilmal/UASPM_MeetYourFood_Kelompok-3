import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../auth/get_started_page.dart';
import '../image_helper.dart';
import 'components/custom_popup.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<String> _allCategories = [
    'Halal', 'Spicy', 'Sweet', 'Dessert', 
    'Seafood', 'Vegetarian', 'Fast Food', 
    'Traditional', 'Exotic', 'Street Food', 'Beverages'
  ];
  List<String> _selectedPreferences = [];
  String _profileImageBase64 = "";
  String _displayName = "User"; // Variabel lokal untuk nama
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Set nama awal dari Firebase Auth
      setState(() {
        _displayName = user.displayName ?? "User";
      });

      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            if (data.containsKey('food_preferences')) {
              _selectedPreferences = List<String>.from(data['food_preferences']);
            }
            if (data.containsKey('profile_image')) {
              _profileImageBase64 = data['profile_image'] ?? "";
            }
            // Jika ada nama tersimpan di Firestore, gunakan itu (opsional, untuk sinkronisasi)
            if (data.containsKey('name')) {
              _displayName = data['name'];
            }
          });
        }
      } catch (e) {
        debugPrint("Error loading user data: $e");
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // --- FUNGSI UBAH NAMA ---
  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(text: _displayName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Edit Name"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: "Enter your new name",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              String newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(context); // Tutup dialog
                await _updateName(newName); // Proses update
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateName(String newName) async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // 1. Update di Firebase Auth (User Profile)
        await user.updateDisplayName(newName);
        await user.reload(); // Refresh data user lokal

        // 2. Update di Firestore (Database Users)
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': newName
        }, SetOptions(merge: true));

        // 3. Update State Lokal
        setState(() {
          _displayName = newName;
        });

        if (mounted) {
          showCustomPopup(context, "Success", "Name updated successfully!");
        }
      } catch (e) {
        if (mounted) {
          showCustomPopup(context, "Error", "Failed to update name: $e", isError: true);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
      maxWidth: 500,
    );

    if (returnedImage != null) {
      setState(() => _isLoading = true);

      final imageFile = File(returnedImage.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes);

      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'profile_image': base64String
        }, SetOptions(merge: true));

        setState(() {
          _profileImageBase64 = base64String;
        });

        if (mounted) {
          showCustomPopup(context, "Success", "Profile photo updated successfully!");
        }
      } catch (e) {
        if (mounted) {
          showCustomPopup(context, "Error", "Failed to upload: $e", isError: true);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _togglePreference(String category) async {
    setState(() {
      if (_selectedPreferences.contains(category)) {
        _selectedPreferences.remove(category);
      } else {
        _selectedPreferences.add(category);
      }
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'food_preferences': _selectedPreferences
      }, SetOptions(merge: true));
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: const Text("Cancel", style: TextStyle(color: Colors.grey))
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); 
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (context) => const GetStartedPage()), 
                    (route) => false
                  );
                }
              },
              child: const Text("Yes, Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
        centerTitle: true, 
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.white, 
        elevation: 0
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // --- AVATAR ---
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF00C853), width: 2),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: ClipOval(
                          child: _profileImageBase64.isNotEmpty
                              ? ImageHelper(imageString: _profileImageBase64, fit: BoxFit.cover)
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.person, size: 60, color: Colors.grey),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00C853),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // --- NAMA & EDIT ICON ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _displayName, // Menggunakan variabel lokal yang bisa diupdate
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)
                  ),
                  const SizedBox(width: 8),
                  // Tombol Edit Nama
                  InkWell(
                    onTap: _showEditNameDialog,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle
                      ),
                      child: const Icon(Icons.edit, size: 16, color: Colors.grey),
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 4),
              Text(
                user?.email ?? "email@example.com", 
                style: const TextStyle(color: Colors.grey, fontSize: 14)
              ),
              
              const SizedBox(height: 30),
              
              // --- CARD PREFERENSI ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Food Preference", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Select what you want to see in Swipe", 
                      style: TextStyle(fontSize: 12, color: Colors.grey)
                    ),
                    const SizedBox(height: 20),
                    
                    _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allCategories.map((category) {
                          final isSelected = _selectedPreferences.contains(category);
                          return InkWell(
                            onTap: () => _togglePreference(category),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF00C853).withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF00C853) : Colors.grey.shade300
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF00C853) : Colors.grey[700],
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // --- TOMBOL LOGOUT ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutConfirmation(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF5252)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    foregroundColor: const Color(0xFFFF5252),
                  ),
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_popup.dart'; // <--- IMPORT HELPER

class AddFoodPage extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final String? docId;

  const AddFoodPage({super.key, this.existingData, this.docId});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _mapUrlController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<String> _selectedCategories = []; 
  final List<String> _categories = ['Halal', 'Non-Halal', 'Spicy', 'Sweet', 'Dessert', 'Seafood', 'Vegetarian', 'Fast Food', 'Traditional', 'Exotic', 'Street Food', 'Beverages', 'Snacks', 'Healthy'];

  File? _selectedImage;
  String _base64Image = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['name'] ?? '';
      _descController.text = widget.existingData!['description'] ?? '';
      _priceController.text = widget.existingData!['price'] ?? '';
      _mapUrlController.text = widget.existingData!['map_url'] ?? '';
      _locationController.text = widget.existingData!['location'] ?? '';
      _base64Image = widget.existingData!['image_url'] ?? '';
      
      var categoryData = widget.existingData!['category'];
      
      if (categoryData is List) {
        _selectedCategories = List<String>.from(categoryData);
      } else if (categoryData is String) {
        _selectedCategories = [categoryData];
      }
    }
  }

  Future<void> _pickImage() async {
    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
      maxWidth: 600,
    );

    if (returnedImage != null) {
      final imageFile = File(returnedImage.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes);

      setState(() {
        _selectedImage = imageFile;
        _base64Image = base64String;
      });
    }
  }

  void _submitData() async {
    // --- UPDATE VALIDASI ---
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      showCustomPopup(context, "Incomplete Data", "Nama & Harga wajib diisi!", isError: true);
      return;
    }

    if (_selectedCategories.isEmpty) {
      showCustomPopup(context, "Category Missing", "Pilih minimal satu kategori!", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      String uploaderName = user?.displayName ?? "Anonymous";

      String finalImage = _base64Image.isNotEmpty
          ? _base64Image
          : 'https://source.unsplash.com/random/?food';

      Map<String, dynamic> dataToSave = {
        'name': _nameController.text,
        'description': _descController.text,
        'price': _priceController.text,
        'map_url': _mapUrlController.text,
        'location': _locationController.text,
        'category': _selectedCategories,
        'image_url': finalImage,
        'added_by': uploaderName,
        if (widget.docId == null) 'created_at': Timestamp.now(),
      };

      if (widget.docId != null) {
        await FirebaseFirestore.instance.collection('foods').doc(widget.docId).update(dataToSave);
      } else {
        await FirebaseFirestore.instance.collection('foods').add(dataToSave);
      }

      if (mounted) {
        // --- UPDATE SUKSES POPUP ---
        showCustomPopup(
          context, 
          "Success", 
          widget.docId != null ? "Data berhasil diupdate!" : "Data berhasil disimpan!",
          onOk: () {
            Navigator.pop(context); // Tutup halaman AddFoodPage setelah klik OK
          }
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomPopup(context, "Error", "Gagal menyimpan: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... (Kode build UI widget AddFoodPage sama persis dengan yang sebelumnya, hanya fungsi _submitData yang berubah) ...
  // Silakan lanjutkan dari kode AddFoodPage sebelumnya.
  @override
  Widget build(BuildContext context) {
    String pageTitle = widget.docId != null ? "Edit Food Spot" : "Add New Food Spot";
    
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(pageTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Name"),
            TextField(controller: _nameController, decoration: inputDecoration.copyWith(hintText: "Enter food or restaurant name")),
            const SizedBox(height: 15),

            _buildLabel("Category (Select multiple)"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _categories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    checkmarkColor: Colors.white,
                    selectedColor: const Color(0xFF00C853),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 15),

            _buildLabel("Price"),
            TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: inputDecoration.copyWith(hintText: "e.g 25000")),
            const SizedBox(height: 15),

            _buildLabel("City/Location"),
            TextField(controller: _locationController, decoration: inputDecoration.copyWith(hintText: "e.g Bandung")),
            const SizedBox(height: 15),

            _buildLabel("Desc"),
            TextField(controller: _descController, maxLines: 2, decoration: inputDecoration.copyWith(hintText: "Description about the food")),
            const SizedBox(height: 15),

            _buildLabel("Map Link"),
            TextField(controller: _mapUrlController, decoration: inputDecoration.copyWith(hintText: "Google Maps URL")),
            const SizedBox(height: 25),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImage != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_selectedImage!, fit: BoxFit.cover))
                    : (_base64Image.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: _base64Image.startsWith('http')
                                ? Image.network(_base64Image, fit: BoxFit.cover)
                                : Image.memory(base64Decode(_base64Image), fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 50, color: Colors.black54),
                              SizedBox(height: 10),
                              Text("Tap to add photo", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                            ],
                          ),
              ),
            ),
            
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 120,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
      ),
    );
  }
}
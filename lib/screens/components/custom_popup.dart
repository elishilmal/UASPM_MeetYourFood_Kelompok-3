import 'package:flutter/material.dart';

void showCustomPopup(BuildContext context, String title, String message, {bool isError = false, VoidCallback? onOk}) {
  showDialog(
    context: context,
    barrierDismissible: false, // User wajib klik OK
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Indikator
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isError ? Colors.red.withOpacity(0.1) : const Color(0xFF00C853).withOpacity(0.1),
              ),
              child: Icon(
                isError ? Icons.error_outline : Icons.check_circle,
                color: isError ? Colors.red : const Color(0xFF00C853),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            
            // Button OK
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isError ? Colors.red : const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context); // Tutup Dialog
                  if (onOk != null) onOk(); // Jalankan aksi tambahan jika ada (misal tutup halaman)
                },
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
import 'dart:convert';
import 'package:flutter/material.dart';

class ImageHelper extends StatelessWidget {
  final String imageString;
  final BoxFit fit;

  const ImageHelper({super.key, required this.imageString, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    // 1. Cek apakah ini URL Internet (http)
    if (imageString.startsWith('http')) {
      return Image.network(
        imageString,
        fit: fit,
        errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
      );
    } 
    // 2. Jika bukan URL, berarti ini Base64 (Data Lokal)
    else {
      try {
        return Image.memory(
          base64Decode(imageString), // Decode teks menjadi gambar
          fit: fit,
          errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[300], child: const Icon(Icons.error)),
        );
      } catch (e) {
        return Container(color: Colors.grey[300]); // Jika datanya rusak
      }
    }
  }
}
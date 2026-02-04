import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../image_helper.dart'; 
import 'components/custom_popup.dart'; 

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  String _searchQuery = "";

  Future<void> _unlikeFood(String docId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('matches').doc(docId).delete();
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('swipes').doc(docId).delete();

      if (mounted) {
        showCustomPopup(context, "Unliked!", "Food removed from matches.\nIt will appear in Swipe again.");
      }
    } catch (e) {
      if (mounted) showCustomPopup(context, "Error", "Failed to unlike: $e", isError: true);
    }
  }

  void _showDeleteConfirmation(BuildContext context, String docId, String foodName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Unlike Food?"),
        content: Text("Are you sure you want to remove '$foodName'? It will reappear in your swipe deck."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              _unlikeFood(docId); 
              Navigator.pop(context);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI FORMAT TANGGAL ---
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown Date";
    DateTime date = timestamp.toDate();
    // Format: DD/MM/YYYY
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  // --- DETAIL VIEW LENGKAP (Updated) ---
  void _showDetail(BuildContext context, Map<String, dynamic> data) {
    // Logic Kategori
    var rawCategory = data['category'];
    String categoryText = "Omnivore";
    
    if (rawCategory is List) {
      categoryText = rawCategory.join(", ");
    } else if (rawCategory is String) {
      categoryText = rawCategory;
    }

    // Ambil Info User & Tanggal
    final String addedBy = data['added_by'] ?? 'Unknown User';
    final String dateString = _formatDate(data['created_at']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          children: [
            // Handle Bar
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            
            // Gambar Besar
            Expanded(
              flex: 5, 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), 
                child: SizedBox(
                  width: double.infinity, 
                  child: ImageHelper(imageString: data['image_url'] ?? '', fit: BoxFit.cover)
                )
              )
            ),
            
            const SizedBox(height: 20),
            
            // Nama & Harga
            Text(data['name'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text(data['price'] ?? '', style: const TextStyle(fontSize: 18, color: Color(0xFF00C853), fontWeight: FontWeight.w600)),
            
            const SizedBox(height: 10),

            // --- INFO TAMBAHAN (User & Tanggal) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text("By $addedBy", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                
                const SizedBox(width: 15), 
                
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(dateString, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 15),

            // Chips Info (Kategori & Lokasi)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDetailChip(Icons.restaurant_menu, categoryText, Colors.orange),
                const SizedBox(width: 10),
                _buildDetailChip(Icons.location_on, data['location'] ?? 'Unknown', Colors.blue),
              ],
            ),

            const SizedBox(height: 20),
            
            // Deskripsi
            const Align(alignment: Alignment.centerLeft, child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 8),
            Expanded(
              flex: 3, 
              child: SingleChildScrollView(
                child: Text(
                  data['description'] ?? 'No description provided.', 
                  style: const TextStyle(color: Colors.black54, height: 1.5, fontSize: 14), 
                  textAlign: TextAlign.justify
                ),
              )
            ),
            
            const SizedBox(height: 15),
            
            // Tombol Map
            SizedBox(
              width: double.infinity, 
              height: 55, 
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853), 
                  foregroundColor: Colors.white, 
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ), 
                icon: const Icon(Icons.map_outlined), 
                label: const Text("Open in Maps", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                onPressed: () async { 
                  final String? mapLink = data['map_url']; 
                  if (mapLink != null && mapLink.isNotEmpty) { 
                    launchUrl(Uri.parse(mapLink), mode: LaunchMode.externalApplication); 
                  } else { 
                    showCustomPopup(context, "No Map", "Link peta tidak tersedia.", isError: true); 
                  } 
                },
              )
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Food Matches", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search your matches...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true, fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('matches').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.favorite_border, size: 60, color: Colors.grey), SizedBox(height: 10), Text("No matches yet", style: TextStyle(color: Colors.grey, fontSize: 16))]));
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase(); 
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();

                if (docs.isEmpty) return const Center(child: Text("Food not found."));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String matchDocId = doc.id; 
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _showDetail(context, data),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                SizedBox(width: 80, height: 80, child: ClipRRect(borderRadius: BorderRadius.circular(15), child: ImageHelper(imageString: data['image_url'] ?? '', fit: BoxFit.cover))),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(data['name'] ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 6),
                                      Text(data['price'] ?? '-', style: TextStyle(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(50),
                                    onTap: () => _showDeleteConfirmation(context, matchDocId, data['name'] ?? 'Food'),
                                    child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFF8A80).withOpacity(0.1)), child: const Icon(Icons.favorite, color: Color(0xFFFF8A80), size: 24)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
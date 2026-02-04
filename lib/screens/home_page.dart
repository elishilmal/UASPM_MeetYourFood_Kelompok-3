import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'components/add_food_page.dart';
import 'components/custom_popup.dart'; 
import '../image_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 0 = All, 1 = My Uploads
  int _selectedFilter = 0; 
  
  // --- SEARCH STATE ---
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _showInputForm() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFoodPage()));
  }

  void _showEditForm(String docId, Map<String, dynamic> data) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddFoodPage(existingData: data, docId: docId)));
  }

  Future<void> _deleteFood(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('foods').doc(docId).delete();
      if (mounted) showCustomPopup(context, "Deleted", "Berhasil menghapus data makanan.");
    } catch (e) {
      if (mounted) showCustomPopup(context, "Error", "Gagal menghapus: $e", isError: true);
    }
  }

  void _confirmDelete(String docId, String foodName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Hapus Makanan?"),
        content: Text("Apakah kamu yakin ingin menghapus '$foodName'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () { Navigator.pop(context); _deleteFood(docId); }, child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> data) {
    var rawCategory = data['category'];
    String categoryText = rawCategory is List ? rawCategory.join(", ") : (rawCategory is String ? rawCategory : "Omnivore");
    final String addedBy = data['added_by'] ?? 'Unknown User';
    final String dateString = _formatDate(data['created_at']);

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85, 
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            Expanded(flex: 5, child: ClipRRect(borderRadius: BorderRadius.circular(20), child: SizedBox(width: double.infinity, child: ImageHelper(imageString: data['image_url'] ?? '', fit: BoxFit.cover)))),
            const SizedBox(height: 20),
            Text(data['name'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text(data['price'] ?? '', style: const TextStyle(fontSize: 18, color: Color(0xFF00C853), fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.person_outline, size: 14, color: Colors.grey), const SizedBox(width: 4), Text("By $addedBy", style: const TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(width: 15), const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(dateString, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
            const SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDetailChip(Icons.restaurant_menu, categoryText, Colors.orange), const SizedBox(width: 10), _buildDetailChip(Icons.location_on, data['location'] ?? 'Unknown', Colors.blue)]),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 8),
            Expanded(flex: 3, child: SingleChildScrollView(child: Text(data['description'] ?? 'No description provided.', style: const TextStyle(color: Colors.black54, height: 1.5, fontSize: 14), textAlign: TextAlign.justify))),
            const SizedBox(height: 15),
            SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), icon: const Icon(Icons.map_outlined), label: const Text("Open in Maps", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), onPressed: () async { final String? mapLink = data['map_url']; if (mapLink != null && mapLink.isNotEmpty) { launchUrl(Uri.parse(mapLink), mode: LaunchMode.externalApplication); } else { showCustomPopup(context, "No Map", "Link peta tidak tersedia.", isError: true); } }))
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: color), const SizedBox(width: 6), Flexible(child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]));
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown";
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? "";
    final String defaultName = user?.displayName ?? "Foodie";

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, snapshot) {
            String profileImage = "";
            String displayName = defaultName;
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              profileImage = data['profile_image'] ?? "";
            }
            return Row(
              children: [
                Container(width: 45, height: 45, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200), color: const Color(0xFFE8F5E9)), child: ClipOval(child: profileImage.isNotEmpty ? ImageHelper(imageString: profileImage, fit: BoxFit.cover) : const Icon(Icons.person, color: Color(0xFF00C853)))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Hello,", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.normal)), Text(displayName, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800))]),
              ],
            );
          },
        ),
        actions: [
          Container(margin: const EdgeInsets.only(right: 20), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)), child: IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 24), onPressed: () {}))
        ],
      ),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                
                // --- BANNER UTAMA ---
                // Jika sedang searching, sembunyikan banner agar fokus ke hasil search
                if (!_isSearching)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 5))], border: Border.all(color: Colors.grey.shade100)),
                    child: Row(children: [Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.restaurant, color: Color(0xFF00C853), size: 32)), const SizedBox(width: 20), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Find Your Craving", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), SizedBox(height: 4), Text("Explore your favorite foods here", style: TextStyle(color: Colors.grey, fontSize: 13))])]),
                  ),
                
                if (!_isSearching) const SizedBox(height: 25),
                if (!_isSearching) const Text("Contribute", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                if (!_isSearching) const SizedBox(height: 10),
                
                // --- TOMBOL CONTRIBUTE ---
                if (!_isSearching)
                  InkWell(onTap: _showInputForm, borderRadius: BorderRadius.circular(20), child: Container(height: 55, decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_circle_outline, color: Color(0xFF00C853)), SizedBox(width: 10), Text("Add New Food Spot", style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 16))]))),
                
                const SizedBox(height: 25),
                
                // --- HEADER SECTION (TITLE + SEARCH + FILTER) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Jika mode search, tampilkan input field
                    if (_isSearching)
                      Expanded(
                        child: Container(
                          height: 45,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: "Search foods...",
                              border: InputBorder.none,
                              icon: const Icon(Icons.search, color: Colors.grey),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _isSearching = false;
                                    _searchController.clear();
                                    _searchQuery = "";
                                  });
                                },
                              )
                            ),
                            onChanged: (val) => setState(() => _searchQuery = val),
                          ),
                        ),
                      )
                    else ...[
                      // Jika mode normal, tampilkan teks dan tombol search
                      const Text("Recently Added", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      
                      const Spacer(), // Dorong ke kanan
                      
                      // TOMBOL SEARCH
                      InkWell(
                        onTap: () => setState(() => _isSearching = true),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                          child: const Icon(Icons.search, size: 20, color: Colors.black54),
                        ),
                      ),
                      
                      const SizedBox(width: 10),
                      
                      // FILTER TABS (All / My Uploads)
                      // Kita bungkus row ini agar tidak error overflow jika layar sempit
                      Row(
                        children: [
                          _buildFilterTab("All", 0),
                          const SizedBox(width: 10),
                          _buildFilterTab("My Uploads", 1),
                        ],
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),

          // --- LIST DATA ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('foods').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.no_meals, size: 50, color: Colors.grey), SizedBox(height: 10), Text("No foods added yet.", style: TextStyle(color: Colors.grey))]));

                var docs = snapshot.data!.docs;
                
                // 1. Filter Search Query
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery.toLowerCase());
                  }).toList();
                }

                // 2. Filter Tab (All / My Uploads)
                if (_selectedFilter == 1) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['added_by'] == user?.displayName; 
                  }).toList();
                }

                if (docs.isEmpty) return const Center(child: Text("No items found.", style: TextStyle(color: Colors.grey)));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String docId = doc.id;
                    final bool isMyFood = (data['added_by'] ?? '') == user?.displayName;
                    final String dateString = _formatDate(data['created_at']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))], border: Border.all(color: Colors.grey.shade100)),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _showDetail(context, data),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 90, height: 90, child: ClipRRect(borderRadius: BorderRadius.circular(15), child: ImageHelper(imageString: data['image_url'] ?? '', fit: BoxFit.cover))),
                                const SizedBox(width: 15),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data['name'] ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text(data['price'] ?? '-', style: TextStyle(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 6), Row(children: [const Icon(Icons.location_on, size: 12, color: Colors.grey), const SizedBox(width: 2), Expanded(child: Text(data['location'] ?? 'Unknown', style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 4), Row(children: [const Icon(Icons.person_outline, size: 12, color: Colors.grey), const SizedBox(width: 2), Expanded(child: Text(data['added_by'] ?? 'User', style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)), Text("• $dateString", style: const TextStyle(fontSize: 11, color: Colors.grey))])])),
                                if (isMyFood) Column(children: [InkWell(onTap: () => _showEditForm(docId, data), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.edit, size: 16, color: Colors.blue))), const SizedBox(height: 8), InkWell(onTap: () => _confirmDelete(docId, data['name']), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.delete_outline, size: 16, color: Colors.red)))]) else const Padding(padding: EdgeInsets.only(top: 30), child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey)),
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

  Widget _buildFilterTab(String title, int index) {
    bool isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.transparent, borderRadius: BorderRadius.circular(20), border: isSelected ? null : Border.all(color: Colors.grey.shade300)),
        child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey)),
      ),
    );
  }
}
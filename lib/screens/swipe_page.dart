import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../image_helper.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final CardSwiperController controller = CardSwiperController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction, List<DocumentSnapshot> docs, String uid) {
    if (previousIndex < docs.length) {
      final foodDoc = docs[previousIndex];
      final foodData = foodDoc.data() as Map<String, dynamic>;
      final String foodId = foodDoc.id; 

      // 1. Simpan ke history swipes
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('swipes')
          .doc(foodId) 
          .set({
        'swiped_at': Timestamp.now(),
        'action': direction == CardSwiperDirection.right ? 'like' : 'pass',
      });

      // 2. Jika Like, Simpan ke Matches (Pakai ID yang SAMA)
      if (direction == CardSwiperDirection.right) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('matches')
            .doc(foodId) 
            .set(foodData);
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String uid = user!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Find Your Match", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      
      // STREAM 1: AMBIL DATA USER (PREFERENCES)
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          List<dynamic> rawPrefs = (userSnapshot.data?.data() as Map<String, dynamic>?)?['food_preferences'] ?? [];
          List<String> userPreferences = rawPrefs.cast<String>();

          // STREAM 2: AMBIL HISTORY SWIPES
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('swipes').snapshots(),
            builder: (context, swipeSnapshot) {
              if (swipeSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              List<String> swipedFoodIds = swipeSnapshot.data!.docs.map((doc) => doc.id).toList();

              // STREAM 3: AMBIL SEMUA MAKANAN
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('foods').snapshots(),
                builder: (context, foodSnapshot) {
                  if (foodSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!foodSnapshot.hasData || foodSnapshot.data!.docs.isEmpty) return const Center(child: Text("No foods available."));

                  final allDocs = foodSnapshot.data!.docs;
                  
                  // --- LOGIC FILTERING ---
                  final filteredDocs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    
                    // 1. Handling Type Error (String vs List)
                    var rawCategory = data['category'];
                    List<String> foodCategories = [];

                    if (rawCategory is String) {
                      foodCategories = [rawCategory];
                    } else if (rawCategory is List) {
                      foodCategories = List<String>.from(rawCategory);
                    } else {
                      foodCategories = ['Omnivore'];
                    }
                    
                    // 2. Cek apakah sudah diswipe
                    bool alreadySwiped = swipedFoodIds.contains(doc.id);
                    
                    // 3. Cek Preference
                    bool matchPreference = userPreferences.isEmpty || 
                        foodCategories.any((cat) => userPreferences.contains(cat));

                    return !alreadySwiped && matchPreference;
                  }).toList();

                  // --- UI JIKA KOSONG ---
                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(userPreferences.isEmpty ? Icons.settings : Icons.check_circle_outline, size: 60, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            userPreferences.isEmpty 
                            ? "Set your preferences in Profile\nto see recommendations!" 
                            : "No more foods match your taste!", 
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey)
                          ),
                        ],
                      ),
                    );
                  }

                  // --- TAMPILAN SWIPE ---
                  return Column(
                    children: [
                      Expanded(
                        child: CardSwiper(
                          controller: controller,
                          cardsCount: filteredDocs.length,
                          numberOfCardsDisplayed: filteredDocs.length < 3 ? filteredDocs.length : 3,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                          
                          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                            final data = filteredDocs[index].data() as Map<String, dynamic>;
                            
                            // LOGIC TAMPILAN KATEGORI (Sama seperti Home & Matches)
                            var rawCategory = data['category'];
                            String displayCategory = "Omnivore";
                            
                            if (rawCategory is List) {
                              displayCategory = rawCategory.join(", "); 
                            } else if (rawCategory is String) {
                              displayCategory = rawCategory;
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white, 
                                borderRadius: BorderRadius.circular(20), 
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15), 
                                    blurRadius: 20, 
                                    spreadRadius: 2, 
                                    offset: const Offset(0, 10)
                                  )
                                ]
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Gambar Full
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), 
                                      child: ImageHelper(imageString: data['image_url'] ?? '', fit: BoxFit.cover)
                                    )
                                  ),
                                  
                                  // Info Detail di Bawah Gambar
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Label Kategori (Chip Hijau Muda)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00C853).withOpacity(0.1), 
                                            borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Text(
                                            displayCategory, 
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF00C853), fontWeight: FontWeight.bold),
                                            maxLines: 1, 
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 10),
                                        
                                        // Nama Makanan
                                        Text(
                                          data['name'] ?? 'Unknown', 
                                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        
                                        const SizedBox(height: 5),
                                        
                                        // Harga & Lokasi
                                        Row(
                                          children: [
                                            Text(
                                              data['price'] ?? '-', 
                                              style: const TextStyle(color: Color(0xFF00C853), fontSize: 18, fontWeight: FontWeight.w600)
                                            ),
                                            const Spacer(),
                                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                data['location'] ?? 'Unknown', 
                                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onSwipe: (previousIndex, currentIndex, direction) => _onSwipe(previousIndex, currentIndex, direction, filteredDocs, uid),
                        ),
                      ),
                      
                      // Tombol Kontrol (X dan Love)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildControlButton(icon: Icons.close, color: Colors.blueAccent, bgColor: const Color(0xFFE3F2FD), onTap: () => controller.swipe(CardSwiperDirection.left)),
                            const SizedBox(width: 40),
                            _buildControlButton(icon: Icons.favorite, color: const Color(0xFFFF8A80), bgColor: const Color(0xFFFFEBEE), onTap: () => controller.swipe(CardSwiperDirection.right)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required Color color, required Color bgColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle, 
          color: Colors.white, 
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 5))
          ]
        ),
        child: Container(
          margin: const EdgeInsets.all(12), 
          decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor), 
          child: Icon(icon, color: color, size: 30)
        ),
      ),
    );
  }
}
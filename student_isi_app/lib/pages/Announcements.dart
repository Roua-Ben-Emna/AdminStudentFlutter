import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  late List<Map<String, dynamic>> _announcements = [];
  late List<Map<String, dynamic>> _filteredAnnouncements = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchUserCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserCategories() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userEmail = prefs.getString('email') ?? '';

      QuerySnapshot userSnapshot = await _firestore
          .collection('students')
          .where('email', isEqualTo: userEmail)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        List<dynamic> userCategories = userSnapshot.docs.first['categories'];
        await _fetchAnnouncements(userCategories);
      }
    } catch (error) {
      print('Error fetching user categories: $error');
    }
  }

  Future<void> _fetchAnnouncements(List<dynamic> userCategories) async {
    try {
      QuerySnapshot announcementsSnapshot = await _firestore
          .collection('posts')
          .where('categories', arrayContainsAny: userCategories)
          .get();

      _announcements = announcementsSnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      _filteredAnnouncements = List.from(_announcements);

      setState(() {});

    } catch (error) {
      print('Error fetching announcements: $error');
    }
  }

  void _filterAnnouncements(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _filteredAnnouncements = _announcements.where((announcement) {
          return announcement['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
              announcement['description'].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        _filteredAnnouncements = List.from(_announcements);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  hintText: 'Search...',
                  filled: true,
                  fillColor: const Color.fromRGBO(44, 44, 182, 0.10196078431372549),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _filterAnnouncements,
              ),
            ),
            Expanded(
              child: _buildAnnouncementsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    if (_filteredAnnouncements.isEmpty) {
      return const Center(
        child: Text(
          'No announcements available.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _filteredAnnouncements.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> announcement = _filteredAnnouncements[index];
          String imageUrl = announcement['image'] as String? ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(color: Colors.black, width: 1.0),
              ),
              child: Column(
                children: [
                  imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    height: 200,
                    child: const Center(child: Icon(Icons.image, size: 100, color: Colors.grey)),
                  ),
                  ListTile(
                    title: Text(
                      announcement['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      announcement['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

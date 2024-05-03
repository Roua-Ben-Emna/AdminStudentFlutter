import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _postStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _postStream = FirebaseFirestore.instance.collection("posts").snapshots();
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
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  hintText: 'Search...',
                  filled: true,
                  fillColor: Color.fromRGBO(44, 44, 182, 0.10196078431372549),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _onSearchTextChanged,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _postStream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  User? user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    return Center(
                      child: Text('User not authenticated'),
                    );
                  }
                  List<DocumentSnapshot> posts = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (BuildContext context, int index) {
                      var post = posts[index];
                      Map<String, dynamic>? postData = post.data() as Map<String, dynamic>?;
                      String title = postData != null && postData.containsKey('title') ? postData['title'] : 'No Title'; // Check title safely
                      String imageUrl = postData != null && postData.containsKey('image') ? postData['image'] : ''; // Check image safely

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Card(
                          color: Colors.white,
                          elevation:5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.black, width: 1.0),
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
                                  : SizedBox(height: 200, child: Center(child: Text('No image available'))),
                              ListTile(
                                leading: Icon(Icons.school,
                                  color: Colors.black,
                                ),
                                title: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(context, post);
                                  },
                                ),
                              ),
                            ],
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
      ),

    floatingActionButton: FloatingActionButton(
      onPressed: () {
        _showAddPostDialog(context);
      },
      backgroundColor: Colors.blue,
      child: Icon(Icons.add, color: Colors.white),
    ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _postStream = FirebaseFirestore.instance
          .collection("posts")
          .where('title', isGreaterThanOrEqualTo: text)
          .where('title', isLessThan: text + 'z')
          .snapshots();
    });
  }


  void _showAddPostDialog(BuildContext context) {
    TextEditingController _titleController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();
    List<String> _selectedCategories = [];
    List<String> _categories = [];
    File? _image;
    final ImagePicker _picker = ImagePicker();

    Future pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    }
    Future<String?> uploadImage(File image) async {
      String fileName = basename(image.path);
      firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref().child('post_images/$fileName');
      firebase_storage.UploadTask task = ref.putFile(image);
      return await (await task).ref.getDownloadURL();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Post Title'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Post Description'),
                      maxLines: 5,
                    ),
                    SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("categories")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Text('Error loading categories');
                        }

                        // Extract category names from snapshot
                        _categories.clear();
                        for (DocumentSnapshot doc in snapshot.data!.docs) {
                          _categories.add(doc['name']);
                        }

                        return DropdownButtonFormField<String>(
                          value: null,
                          hint: Text('Select category'),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              if (value != null) {
                                _selectedCategories
                                    .add(value); // Add selected category
                              }
                            });
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => pickImage(),
                      child: Text('Pick Image',style: TextStyle(
                        color: Colors.blue,
                      ),),
                    ),
                    // Add StreamBuilder for categories if needed here
                  ],
                ),
              ),

              actions: <Widget>[
                TextButton(
                  child: Text('Cancel',style: TextStyle(
            color: Colors.blue,
            ),),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Add',style: TextStyle(
                    color: Colors.blue,
                  ),),
                  onPressed: () async {
                    if (_image != null) {
                      String? imageUrl = await uploadImage(_image!);
                      if (imageUrl != null) {
                        String title = _titleController.text.trim();
                        String description = _descriptionController.text.trim();
                        FirebaseFirestore.instance.collection('posts').add({
                          'title': title,
                          'description': description,
                          'categories': _selectedCategories,
                          'image': imageUrl,
                        }).then((value) => Navigator.of(context).pop());
                      }
                    } else {
                      print('No image selected');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, DocumentSnapshot post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${post['title']}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',style: TextStyle(
                color: Colors.blue,
              ),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete',style: TextStyle(
                color: Colors.blue,
              ),),
              onPressed: () {
                _deletepost(context, post);
              },
            ),
          ],
        );
      },
    );
  }

  void _deletepost(BuildContext context, DocumentSnapshot post) {
    FirebaseFirestore.instance
        .collection("posts")
        .doc(post.id)
        .delete()
        .then((value) {
      Navigator.of(context).pop();
    }).catchError((error) {
      print("Error deleting post: $error");
    });
  }
}

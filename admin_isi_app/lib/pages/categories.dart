import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _categoriesStream =
        FirebaseFirestore.instance.collection("categories").snapshots();
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
                stream: _categoriesStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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

                  List<DocumentSnapshot> categories = snapshot.data!.docs;

                  return GridView.count(
                    crossAxisCount: 2, // Adjust as needed for the number of columns
                    children: categories.map((category) {
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.black, width: 1.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.school, color: Colors.black),
                              SizedBox(height: 8),
                              Text(
                                category['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      _showUpdateCategoryDialog(
                                          context, category);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                          context, category);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog(context);
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _categoriesStream = FirebaseFirestore.instance
          .collection("categories")
          .where('name', isGreaterThanOrEqualTo: text)
          .where('name', isLessThanOrEqualTo: text + '\uf8ff')
          .snapshots();
    });
  }

  void _showAddCategoryDialog(BuildContext context) {
    TextEditingController _categoryNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            controller: _categoryNameController,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Add',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onPressed: () {
                String categoryName = _categoryNameController.text;
                if (categoryName.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('categories')
                      .add({
                    'name': categoryName,
                  }).then((value) {
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print("Error adding category: $error");
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateCategoryDialog(
      BuildContext context, DocumentSnapshot category) {
    TextEditingController _updatedCategoryNameController =
    TextEditingController(text: category['name']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Category'),
          content: TextField(
            controller: _updatedCategoryNameController,
            decoration: InputDecoration(labelText: 'New Category Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Update',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onPressed: () {
                String updatedCategoryName =
                    _updatedCategoryNameController.text;
                if (updatedCategoryName.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('categories')
                      .doc(category.id)
                      .update({
                    'name': updatedCategoryName,
                  }).then((value) {
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print("Error updating category: $error");
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, DocumentSnapshot category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${category['name']}?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection("categories")
                    .doc(category.id)
                    .delete()
                    .then((value) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  print("Error deleting category: $error");
                });
              },
            ),
          ],
        );
      },
    );
  }
}

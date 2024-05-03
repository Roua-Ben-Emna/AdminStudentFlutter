import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/pages/dynamicForm.dart';
import 'package:namer_app/pages/formBuilder.dart';

class FormListPage extends StatefulWidget {
  @override
  _FormListPageState createState() => _FormListPageState();
}

class _FormListPageState extends State<FormListPage> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _formStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _formStream =
        FirebaseFirestore.instance.collection("formFields").snapshots();
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
                stream: _formStream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No forms found'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> formData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Card(
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          elevation: 5, // Add elevation for card
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: BorderSide(color: Colors.black, width: 1.0),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.description, color: Colors.blue),
                            title: Text(
                              formData['titleForm'] ?? '',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DynamicForm(formDefinition: snapshot.data!.docs[index]),
                                ),
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () async {
                                    bool confirmDelete = await _showConfirmationDialog(context);
                                    if (confirmDelete) {
                                      await FirebaseFirestore.instance.collection('formFields').doc(snapshot.data!.docs[index].id).delete();
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text("Form deleted"),
                                      ));
                                    }
                                  },
                                ),
                                Icon(Icons.arrow_forward_ios, color: Colors.grey),
                              ],
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormBuilder(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _formStream = FirebaseFirestore.instance
          .collection("formFields")
          .where('titleForm', isGreaterThanOrEqualTo: text)
          .where('titleForm', isLessThanOrEqualTo: text + '\uf8ff')
          .snapshots();
    });
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this form?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',style: TextStyle(
        color: Colors.blue,
        ),),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete',style: TextStyle(color: Colors.blue,),),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_isi_app/pages/DynamicForm.dart';

class FormListPage extends StatefulWidget {
  const FormListPage({super.key});

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
    _formStream = FirebaseFirestore.instance.collection("formFields").snapshots();
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
                  fillColor: const Color.fromRGBO(44, 44, 182, 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _onSearchTextChanged,
              ),
            ),
            Expanded(
              child:StreamBuilder<QuerySnapshot>(
                stream: _formStream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  return _buildFormList(snapshot);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    List<DocumentSnapshot> documents = snapshot.data!.docs;
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> formData = documents[index].data() as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: const BorderSide(color: Colors.black, width: 1.0),
            ),
            child: ListTile(
              leading: const Icon(Icons.description, color: Colors.blue),
              title: Text(
                formData['titleForm'] ?? '',
                style: const TextStyle(fontSize: 16.0),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DynamicForm(formDefinition: documents[index]),
                  ),
                );
              },
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _formStream = FirebaseFirestore.instance
          .collection("formFields")
          .where('titleForm', isGreaterThanOrEqualTo: text)
          .where('titleForm', isLessThanOrEqualTo: '$text\uf8ff')
          .snapshots();
    });
  }
}

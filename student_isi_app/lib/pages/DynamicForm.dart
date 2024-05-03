import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:student_isi_app/fields/radioButtonField.dart';

class DynamicForm extends StatefulWidget {
  final DocumentSnapshot formDefinition;

  DynamicForm({required this.formDefinition});

  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
   String? uploadedFileName;


   @override
   Widget build(BuildContext context) {
     Map<String, dynamic> formData = widget.formDefinition.data() as Map<String, dynamic>;
     List<Map<String, dynamic>> formFields = List<Map<String, dynamic>>.from(formData['fields']);
     return Scaffold(
       appBar: AppBar(
         title: Text(formData['title'] ?? ''),
       ),

       body: Center(
         child: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Card(
            // Set card color to white and transparent
             child: Padding(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   Text(
                     formData['titleForm'] ?? '',
                     style: const TextStyle(
                       fontSize: 24, // Adjust font size as needed
                       fontWeight: FontWeight.bold, // Make title bold
                     ),
                     textAlign: TextAlign.center,
                   ),
                   const SizedBox(height: 20), // Add space between title and form fields
                   Expanded(
                     child: ListView.builder(
                       itemCount: formFields.length,
                       itemBuilder: (context, index) {
                         Map<String, dynamic> fieldData = formFields[index];
                         String fieldType = fieldData['name'];
                         switch (fieldType) {
                           case 'Text Field':
                             return buildTextField(fieldData['title'] ?? '');
                           case 'Date Field':
                             return buildDateField(fieldData['title'] ?? '');
                           case 'Number Field':
                             return buildNumberField(fieldData['title'] ?? '');
                           case 'Dropdown Field':
                             return buildDropdownField(fieldData['title'] ?? '', fieldData['options']);
                           case 'Radio Buttons Field':
                             return RadioButtonsField(title: fieldData['title'] ?? '', options: fieldData['options']);
                           case 'Upload File':
                             return buildUploadFileField(fieldData['title'] ?? '');
                           default:
                             return SizedBox.shrink();
                         }
                       },
                     ),

                   ),
                 ],
               ),
             ),
           ),

         ),

       ),
       floatingActionButton: Padding(
         padding: const EdgeInsets.all(16.0), // Add padding to the FloatingActionButton
         child: FloatingActionButton.extended(
           onPressed: () {},
           label: Text('Submit', style: TextStyle(color: Colors.white)), // Set text color to white
           // Set icon color to white
           backgroundColor: Colors.blue, // Set button background color to blue
         ),
       ),
     );
   }

  Widget buildTextField(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(labelText: title),
      ),
    );
  }

  Widget buildNumberField(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(labelText: title),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget buildDateField(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Builder(
        builder: (BuildContext context) {
          return InkWell(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
            },
            child: ListTile(
              title: Text(title),
              trailing: Icon(Icons.calendar_today),
            ),
          );
        },
      ),
    );
  }

  Widget buildDropdownField(String title, List<dynamic> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: title),
        items: options.map<DropdownMenuItem<String>>((option) {
          return DropdownMenuItem<String>(
            value: option.toString(),
            child: Text(option.toString()),
          );
        }).toList(),
        onChanged: (value) {
          // Handle dropdown value change
        },
      ),
    );
  }
   Widget buildUploadFileField(String title) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 8.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(
             title,
             style: TextStyle(
               fontWeight: FontWeight.bold, // Make the title bold
             ),
           ),
           SizedBox(height: 8), // Add some space between the title and the button
           ElevatedButton.icon(
             onPressed: () async {
               FilePickerResult? result = await FilePicker.platform.pickFiles();

               if (result != null) {
                 PlatformFile file = result.files.first;
                 setState(() {
                   uploadedFileName = file.name;
                 });
               } else {
                 print('File picking canceled');
               }
             },
             icon: Icon(Icons.file_upload, color: Colors.white), // Add an icon to the button
             label: Text(
               uploadedFileName ?? 'Upload File',
               style: TextStyle(
                 color: Colors.white,// Make the button text bold
               ),
             ),
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.blue, // Set the button background color to blue
               padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Adjust padding as needed
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(8), // Add rounded corners to the button
               ),
             ),
           ),
         ],
       ),
     );
   }

}

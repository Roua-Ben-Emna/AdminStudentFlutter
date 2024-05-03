import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:namer_app/pages/fields/radioButtonField.dart';

class DynamicForm extends StatefulWidget {
  final DocumentSnapshot formDefinition;

  DynamicForm({required this.formDefinition});

  @override
  _DynamicFormState createState() => _DynamicFormState();
}


class _DynamicFormState extends State<DynamicForm> {
   String? uploadedFileName;
   late DateTime selectedDate;


   @override
   void initState() {
     selectedDate = DateTime.now();

   }

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
             child: Padding(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   Text(
                     formData['titleForm'] ?? '',
                     style: TextStyle(
                       fontSize: 24,
                       fontWeight: FontWeight.bold,
                     ),
                     textAlign: TextAlign.center,
                   ),
                   SizedBox(height: 20),
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
    return buildFieldWrapper(
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(title),
                  trailing: TextButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',style: TextStyle(
                    color: Colors.blue,
                    ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
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
               fontWeight: FontWeight.bold,
             ),
           ),
           SizedBox(height: 8),
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
             icon: Icon(Icons.file_upload, color: Colors.white),
             label: Text(
               uploadedFileName ?? 'Upload File',
               style: TextStyle(
                 color: Colors.white,
               ),
             ),
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.blue,
               padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(8),
               ),
             ),
           ),
         ],
       ),
     );
   }

   Widget buildFieldWrapper(Widget child) {
     return Container(
       margin: EdgeInsets.symmetric(vertical: 8.0),
       child: child,
     );
   }

}

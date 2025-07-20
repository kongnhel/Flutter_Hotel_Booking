

// import 'package:flutter/material.dart';

// class FormAddData extends StatefulWidget {
//   static const String id = 'FormAddData';
//   final Function(StudentModel data) addToStudent;
//   final VoidCallback? onSave;

//   const FormAddData({
//     super.key,
//     required this.addToStudent,
//     required this.onSave,
//   });

//   @override
//   State<FormAddData> createState() => _FormAddDataState();
// }

// class _FormAddDataState extends State<FormAddData> {
//   final frmkey = GlobalKey<FormState>();
//   List<String> gender = ["Male", "Female"];
//   dynamic fileImage;

//   //add new--------
//   Color color = Colors.black;
//   Text myText(String txt, Color color) {
//     return Text(txt, style: TextStyle(color: color));
//   }

//   List<String> faculty = [
//     "IT",
//     "Language",
//     "Agriculture",
//     "Community Development",
//     "Business",
//   ];

//   final TextEditingController fullNameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();

//   String? _selectedGender;
//   String? _selectedFaculty;
//   DateTime? _selectedDOB;
//   String? selectedFormatDoB;

//   final DateFormat formatDate = DateFormat("yyyy/MM/dd");

//   String get fullNameValue => fullNameController.text.trim();
//   String get phoneValue => phoneController.text.trim();
//   String? get genderValue => _selectedGender;
//   String? get facultyValue => _selectedFaculty;
//   DateTime? get dobValue => _selectedDOB;
//   String get formattedDob =>
//       _selectedDOB != null ? formatDate.format(_selectedDOB!) : '';

//   // final String fullnameValue = fullNameController;
//   // final String phoneValue = phoneController;
//   // final String genderValue = _selectedGender;

//   //   final newStudent =StudentModel(
//   //       fullname: fullnameValue,
//   //       phone: phoneValue,
//   //       gender: genderValue,
//   //       dob: dobValue,
//   //       faculty: facultyValue,
//   //     );

//   void showDateOFBirth() async {
//     final now = DateTime.now();
//     final firstDate = DateTime(now.year - 50);
//     final selectedDOB = await showDatePicker(
//       context: context,
//       firstDate: firstDate,
//       lastDate: now,
//     );

//     if (selectedDOB != null) {
//       setState(() {
//         _selectedDOB = selectedDOB;
//         selectedFormatDoB = formatDate.format(_selectedDOB!);
//       });
//     }
//   }

//   @override
//   void dispose() {
//     fullNameController.dispose();
//     phoneController.dispose();
//     _selectedDOB = DateTime.now();
//     super.dispose();
//   }

//   Future<void> _submitForm() async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     if (!frmkey.currentState!.validate()) return;

//     // extra check for dropdown and dob
//     if (_selectedGender == null ||
//         _selectedFaculty == null ||
//         _selectedDOB == null) {
//       setState(() {
//         color = Colors.red;
//       });
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text('Please complete all fields')),
//       );
//       return;
//     }

//     try {
//       final newStudent = StudentModel(
//         id: '', // leave empty if auto-generated
//         fullname: fullNameValue,
//         phone: phoneValue,
//         gender: genderValue!,
//         faculty: facultyValue!,
//         dob: formatDate.format(dobValue!), // format DateTime to String
//       );

//       final addedStudent = await api.addStudent(
//         newStudent,
//       ); // ✅ pass as argument

//       widget.addToStudent(addedStudent);
//       widget.onSave?.call();

//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text('Student added successfully')),
//       );

//       // Navigator.pop(context, true);
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => StudentList(students: [])),
//       );

//       // optional: close form after save
//     } catch (error) {
//       scaffoldMessenger.showSnackBar(
//         SnackBar(content: Text('Failed to add student: $error')),
//       );
//     }
//   }

//   Future<void> uploadImage(Uint8List fileImage) async {
//     final cloudinary = CloudinaryPublic(
//       "dlykpbl7s",
//       'ml_default',
//       cache: false,
//     );

//     try {
//       CloudinaryResponse response = await cloudinary.uploadFile(
//         CloudinaryFile.fromBytesData(
//           fileImage,
//           identifier: 'pickerImage',
//           folder: "dashbord_2",
//         ),
//       );

//       print("Image uploaded: ${response.secureUrl}");
//     } catch (e) {
//       print("Upload failed: $e");
//     }
//   }

//   pikerImage() async {
//     FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
//       type: FileType.image,
//       allowMultiple: false,
//     );
//     if (filePickerResult != null) {
//       setState(() {
//         fileImage = filePickerResult.files.first.bytes;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded),
//           onPressed: () => Navigator.pop(context, false),
//           color: Theme.of(context).appBarTheme.foregroundColor,
//         ),
//         title: Text(
//           'Form Add Student',
//           style: TextStyle(color: const Color.fromARGB(255, 7, 255, 23)),
//         ),
//       ),
//       body: Form(
//         key: frmkey,
//         child: SizedBox(
//           height: MediaQuery.of(context).size.height * 0.5,

//           child: Card(
//             child: Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 children: [
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: TextButton(
//                       onPressed: () {
//                         pikerImage();
//                       },
//                       child: Icon(Icons.add_a_photo_sharp, size: 50),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   MyFormTextField(
//                     labelText: "Full Name",
//                     msgError: "Pleas Enter Full Name!",
//                     txtController: fullNameController,
//                   ),
//                   SizedBox(height: 10),

//                   MyFormTextField(
//                     labelText: "Phone Number",
//                     msgError: "Pleas Enter Phone Number!",
//                     txtController: phoneController,
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: DropdownButton(
//                           value: _selectedGender,
//                           isExpanded: true,
//                           hint: myText("Gender", color),
//                           icon: Icon(Icons.arrow_drop_up_outlined),
//                           items: gender
//                               .map(
//                                 (gender) => DropdownMenuItem(
//                                   value: gender,
//                                   child: Text(gender),
//                                 ),
//                               )
//                               .toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedGender = value!;
//                             });
//                           },
//                         ),
//                       ),
//                       Expanded(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             (_selectedDOB == null)
//                                 ? myText("No selected DOB! ", color)
//                                 : Text(selectedFormatDoB!),
//                             IconButton(
//                               onPressed: showDateOFBirth,
//                               icon: Icon(Icons.calendar_month),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   DropdownButton(
//                     value: _selectedFaculty,

//                     hint: myText("Faculty", color),
//                     isExpanded: true,
//                     icon: Icon(Icons.arrow_drop_down_circle),
//                     items: faculty
//                         .map(
//                           (faculty) => DropdownMenuItem(
//                             value: faculty,
//                             child: Text(faculty),
//                           ),
//                         )
//                         .toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedFaculty = value!;
//                       });
//                     },
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       OutlinedButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: Text("Cancel"),
//                       ),
//                       ElevatedButton(
//                         onPressed: _submitForm,
//                         child: const Text("Save"),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

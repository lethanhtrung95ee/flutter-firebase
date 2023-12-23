import 'dart:io';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_interview/core/const.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _selectedDate;

  //Image controller
  List<Widget> itemPhotosWidgetList = <Widget>[];
  final ImagePicker _picker = ImagePicker();
  File? file;
  List<XFile>? photo = <XFile>[];
  List<XFile> itemImagesList = <XFile>[];
  bool uploading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    itemPhotosWidgetList.clear();
    itemImagesList.clear();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      if (picked.isAfter(DateTime.now())) {
        _showErrorDialog("Please select a date in the past.");
      }
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('MM/dd/yyyy').format(_selectedDate!);
      });
    }
  }

  Future signUp() async {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim());
        User? user = userCredential.user;
        if (user != null) {
          List<String> downloadUrls =
              await upload(_emailController.text.trim());
          await addUserDetail(
              _emailController.text.trim(),
              _firstNameController.text.trim(),
              _lastNameController.text.trim(),
              _selectedDate!,
              downloadUrls);
        }
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message ?? 'An error occurred.');
      }
    } else {
      // Passwords don't match, show error dialog
      _showErrorDialog('Password does not match');
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future addUserDetail(String email, String firstName, String lastName,
      DateTime dob, List<String> downloadUrls) async {
    await FirebaseFirestore.instance.collection('users').doc(email).set({
      'first-name': firstName,
      'last-name': lastName,
      'dob': dob,
      'privateImageUrl': downloadUrls,
    });
  }

  void addImage() {
    itemPhotosWidgetList.clear();
    for (int i = 0; i < itemImagesList.length; i++) {
      itemPhotosWidgetList.add(buildImageWithDeleteButton(i));
    }
  }

  Widget buildImageWithDeleteButton(int index) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: SizedBox(
        height: 90.0,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                child: kIsWeb
                    ? Image.network(File(itemImagesList[index].path).path)
                    : Image.file(File(itemImagesList[index].path)),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    itemImagesList.removeAt(index);
                    addImage();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  pickPhotoFromGallery() async {
    photo = await _picker.pickMultiImage();
    if (photo != null) {
      setState(() {
        itemImagesList = itemImagesList + photo!;
        addImage();
        photo!.clear();
      });
    }
  }

  Future<List<String>> upload(String email) async {
    List<String> downloadUrl = await uplaodImageAndSaveItemInfo(email);
    // setState(() {
    //   uploading = false;
    // });
    showToast("Image Uploaded Successfully");
    return downloadUrl;
  }

  Future<List<String>> uplaodImageAndSaveItemInfo(String email) async {
    List<Future<String>> uploadTasks = [];
    for (int i = 0; i < itemImagesList.length; i++) {
      final file = File(itemImagesList[i].path);
      final pickedFile = PickedFile(file.path);
      uploadTasks.add(uploadImageToStorage(pickedFile, email));
    }

    // Wait for all uploads to complete before getting URLs
    List<String> downloadUrls = await Future.wait(uploadTasks);
    return downloadUrls;
  }

  Future<String> uploadImageToStorage(
      PickedFile? pickedFile, String email) async {
    String pId = const Uuid().v4();
    Reference reference = FirebaseStorage.instance
        .ref()
        .child('$pathPrivateImageFirebase$email/$pId');
    await reference.putData(
      await pickedFile!.readAsBytes(),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    String value = await reference.getDownloadURL();
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Interview Apps',
                style: GoogleFonts.bebasNeue(fontSize: kdouble50)),
            const SizedBox(height: kdouble10),

            const Text('Register below with your details.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                )),
            const SizedBox(height: kdouble20),
            Column(
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.blue[50],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          offset: const Offset(0.0, 0.5),
                          blurRadius: 30.0,
                        )
                      ]),
                  child: Center(
                    child: itemPhotosWidgetList.isEmpty
                        ? Center(
                            // onPressed: pickPhotoFromGallery,
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              child: Center(
                                child: Image.network(
                                  "https://static.thenounproject.com/png/3322766-200.png",
                                  height: 100.0,
                                  width: 100.0,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 400,
                            width: 400,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Wrap(
                                spacing: 5.0,
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.spaceEvenly,
                                runSpacing: 10.0,
                                children: itemPhotosWidgetList,
                              ),
                            ),
                          ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 50.0,
                        left: 100.0,
                        right: 100.0,
                      ),
                      child: TextButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 15.0),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromRGBO(0, 35, 102, 1),
                          ),
                        ),
                        onPressed:
                            uploading ? null : () => pickPhotoFromGallery(),
                        child: uploading
                            ? const SizedBox(
                                height: 15.0,
                                child: CircularProgressIndicator(),
                              )
                            : const Text(
                                "Add",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: kdouble10),

            //first name
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: kdouble20),
                child: TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(kdouble15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(kdouble15),
                      ),
                      hintText: 'First Name',
                      fillColor: Colors.grey[200],
                      filled: true),
                )),
            const SizedBox(height: kdouble10),

            //last name
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: kdouble20),
                child: TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(kdouble15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(kdouble15),
                      ),
                      hintText: 'Last name',
                      fillColor: Colors.grey[200],
                      filled: true),
                )),
            const SizedBox(height: kdouble10),

            //dob
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  hintText: 'Date of birth',
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: kdouble10),

            //Text Field: Email.
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: kdouble20),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(kdouble15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(kdouble15),
                      ),
                      hintText: 'Email',
                      fillColor: Colors.grey[200],
                      filled: true),
                )),
            const SizedBox(height: kdouble10),

            //Text Field: password.
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: kdouble20),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(kdouble15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(kdouble15),
                      ),
                      hintText: 'Password',
                      fillColor: Colors.grey[200],
                      filled: true),
                )),
            const SizedBox(height: kdouble10),

            //Text Field: confirm password.
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: kdouble20),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(kdouble15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(kdouble15),
                      ),
                      hintText: 'Confirm password',
                      fillColor: Colors.grey[200],
                      filled: true),
                )),
            const SizedBox(height: kdouble10),

            //login button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kdouble20),
              child: GestureDetector(
                onTap: signUp,
                child: Container(
                  padding: const EdgeInsets.all(kdouble15),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(kdouble15),
                  ),
                  child: const Center(
                    child: Text('Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                  ),
                ),
              ),
            ),
            const SizedBox(height: kdouble30),

            //not a member, register
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text(
                'Already has an account? ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: widget.showLoginPage,
                child: const Text(
                  'Sign-in',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              )
            ])
          ]),
        ),
      ),
    );
  }
}

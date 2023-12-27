import 'dart:io';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  Widget? itemPhotosWidget;
  final ImagePicker _picker = ImagePicker();
  XFile? photo;
  bool uploading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
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
          String downloadUrl =
              await uplaodImageAndSaveItemInfo(_emailController.text.trim());
          await addUserDetail(
              _emailController.text.trim(),
              _firstNameController.text.trim(),
              _lastNameController.text.trim(),
              _selectedDate!,
              downloadUrl);
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
      DateTime dob, String downloadUrl) async {
    await FirebaseFirestore.instance.collection('users').doc(email).set({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob,
      'privateImageUrl': downloadUrl,
    });
  }

  void pickPhotoFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        photo = pickedImage;
        itemPhotosWidget = Image.file(
          File(photo!.path),
          height: 150,
          width: 150,
          fit: BoxFit.cover,
        );
      });
    }
  }

  Widget _buildProfilePicture() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: itemPhotosWidget != null
              ? Image.file(
                  File(photo!.path),
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                )
              : GestureDetector(
                  onTap: pickPhotoFromGallery,
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Image.network(
                        "https://static.thenounproject.com/png/3322766-200.png",
                        height: 100.0,
                        width: 100.0,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Future<String> uplaodImageAndSaveItemInfo(String email) async {
    final file = File(photo!.path);
    final pickedFile = PickedFile(file.path);
    return uploadImageToStorage(pickedFile, email);
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
      backgroundColor: const Color.fromARGB(255, 200, 185, 185),
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
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.blue[50],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        offset: const Offset(0.0, 0.5),
                        blurRadius: 30.0,
                      )
                    ],
                  ),
                  child: GestureDetector(
                    onTap: pickPhotoFromGallery,
                    child: _buildProfilePicture(),
                  ),
                )
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
            ]),
            const SizedBox(height: kdouble30),
          ]),
        ),
      ),
    );
  }
}

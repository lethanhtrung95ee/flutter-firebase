import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interview/core/const.dart';
import 'package:flutter_interview/pages/auth/forgotpassword_page.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.android, size: 100),
            const SizedBox(height: kdouble80),
          
            Text('Interview Apps',
                style: GoogleFonts.bebasNeue(fontSize: kdouble50)),
            const SizedBox(height: kdouble10),
          
            const Text('You\'ve been missed.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                )),
            const SizedBox(height: kdouble60),
          
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
          
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kdouble30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const ForgotPasswordPage();
                          },
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          
            //login button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kdouble20),
              child: GestureDetector(
                onTap: signIn,
                child: Container(
                  padding: const EdgeInsets.all(kdouble15),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(kdouble15),
                  ),
                  child: const Center(
                    child: Text('Sign in',
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
                'Not a member? ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: widget.showRegisterPage,
                child: const Text(
                  'Register now',
                  style:
                      TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              )
            ])
          ]),
        ),
      ),
    );
  }
}

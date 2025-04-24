import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:women_safety_application/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signUpWithEmail() async {
    try {
      print("Attempting signup...");

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print("User created: ${userCredential.user!.uid}");

      // ✅ Update Firebase Auth profile with display name
      await userCredential.user!.updateDisplayName(_nameController.text.trim());
      await userCredential.user!.reload(); // Reload user to apply changes

      // ✅ Save full name and other details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'uid': userCredential.user!.uid,
      }).timeout(Duration(seconds: 5), onTimeout: () {
        throw Exception("Firestore write timeout");
      });

      print('Data saved in Firestore');

      if (mounted) {
        print('Navigating to LoginScreen...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      print("Signup Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SignUp Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up'), backgroundColor: Colors.redAccent),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUpWithEmail,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

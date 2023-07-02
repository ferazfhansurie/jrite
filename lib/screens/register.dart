import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jritev4/screens/login.dart';
import 'package:jritev4/services/database.dart';

class RegistrationActivity extends StatefulWidget {
  String role;
  RegistrationActivity({super.key, required this.role});
  @override
  _RegistrationActivityState createState() => _RegistrationActivityState();
}

class _RegistrationActivityState extends State<RegistrationActivity> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String role = "Freelancer";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    role = widget.role;
  }

  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> registerUser(
      String username, String email, String password, role) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await DatabaseService()
            .registerUserData(username, email.toLowerCase(), password, role);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Go back',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    )),
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                alignment: Alignment.centerLeft,
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Color.fromARGB(255, 208, 80, 21),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  'Join Jrite as ${widget.role}',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Join our growing freelance copywriting community to offer your tasks,connect with copywriters, and get your task done the right way at your price on Jrite',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w300),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  height: 50,
                  width: 300,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: CupertinoTextField(
                    key: const Key("username"),
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: _usernameController,
                    placeholder: 'Username',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  height: 50,
                  width: 300,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: CupertinoTextField(
                    key: const Key("username"),
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: _emailController,
                    placeholder: 'Email',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  height: 50,
                  width: 300,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: CupertinoTextField(
                    key: const Key("username"),
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: _passwordController,
                    placeholder: 'Password',
                    obscureText: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10,left: 25,right:25),
                child: Row(
                  children: [
                    Text(
                      "By joining, you agree to Jrite's ",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w300),
                    ),
                      Text(
                      "Terms of Service",
                      style: TextStyle(
                           color: Color.fromARGB(255, 208, 80, 21),
                          fontSize: 13,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  String username = _usernameController.text.trim();
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();
                  registerUser(username, email, password, role);
                },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color.fromARGB(255, 208, 80, 21),
                    ),
                    width: 300,
                    height: 42,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      )),
                    )),
              ),
              SizedBox(height: 55,),
               GestureDetector(
              onTap: () {
                 Navigator.of(context)
                        .push(CupertinoPageRoute(builder: (context) {
                      return LoginPage();
                    }));
              },
              child: Text(
                'Sign In',
                style: TextStyle(
                    color: Color.fromARGB(255, 208, 80, 21), fontSize: 18),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

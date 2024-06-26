import 'package:cms_task/customtoast.dart';
import 'package:cms_task/dashboardpage.dart';
import 'package:cms_task/registerpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final key1 = GlobalKey<FormState>();

  bool isEnableForget = false;

  Future<bool> _login(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null && user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed in as ${user.email}')),
        );
        return true;
      } else if (user != null && !user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Email not verified. Please verify your email.')),
        );
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found for that email.')),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong password provided.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: ${e.message}')),
        );
      }
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      print('Password reset email sent');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else {
        print('Something went wrong: ${e.message}');
      }
    }
  }

  bool validateEmail(String email) {
    // Regular expression for email validation
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool validatePassword(String password) {
    return password.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEnableForget ? "Forgot Password" : 'Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: key1,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  print(value);
                  if (!validateEmail(value ?? "")) {
                    return "Kindly check your email";
                  } else {
                    return null;
                  }
                },
              ),
              if (!isEnableForget)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (!validatePassword(value ?? "")) {
                      return "password length 6";
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (isEnableForget) {
                        sendPasswordResetEmail(_emailController.text);
                        CustomToast.show(context, "Kindly check your email");
                      } else {
                        if (key1.currentState?.validate() ?? false) {
                          bool isUser = await _login(
                              _emailController.text, _passwordController.text);
                          if (isUser) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DashboardPage(
                                          email: _emailController.text,
                                        )));
                          }
                        }
                        setState(() {});
                      }
                    },
                    child: Text(isEnableForget ? 'Send Reset Email' : 'Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEnableForget = !isEnableForget;
                      });
                    },
                    child: Text(
                        isEnableForget ? 'Back to Login' : 'Forgot Password'),
                  ),
                  if (isEnableForget == false)
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to your register page here
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text('Register'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

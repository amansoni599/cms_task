import 'dart:convert';

import 'package:cms_task/customtoast.dart';
import 'package:cms_task/dashboardpage.dart';
import 'package:cms_task/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  // Sample JSON configuration
  final String jsonData = '''
  [
    {"type": "TextField", "name": "username", "label": "Username", "validators": "required"},
    {"type": "TextField", "name": "email", "label": "Email", "validators": "required"},
    {"type": "PasswordField", "name": "password", "label": "Password", "validators": "required"},
    {"type": "TextField", "name": "firstName", "label": "First Name"},
    {"type": "TextField", "name": "lastName", "label": "Last Name"},
    {"type": "Dropdown", "name": "gender", "label": "Gender", "options": ["Male", "Female", "Other"],"validators": "required"}
  ]
  ''';

  List<Map<String, dynamic>>? formFields;

  @override
  void initState() {
    super.initState();
    formFields = List<Map<String, dynamic>>.from(json.decode(jsonData));
  }

  Widget _buildFormField(Map<String, dynamic> field) {
    switch (field['type']) {
      case 'TextField':
        return FormBuilderTextField(
          name: field['name'],
          decoration: InputDecoration(labelText: field['label']),
          validator: (value) {
            if (field['validators'] == "required") {
              if (value == null) {
                return "required field";
              } else {
                return null;
              }
            } else {
              return null;
            }
          },
        );
      case 'PasswordField':
        return FormBuilderTextField(
          name: field['name'],
          decoration: InputDecoration(labelText: field['label']),
          obscureText: true,
          validator: (value) {
            if (field['validators'] == "required") {
              if (value == null) {
                return "required field";
              } else {
                return null;
              }
            } else {
              return null;
            }
          },
        );
      case 'DatePicker':
        return FormBuilderDateTimePicker(
          format: DateFormat("M/d/y"),
          name: field['name'],
          decoration: InputDecoration(labelText: field['label']),
          inputType: InputType.date,
          validator: (value) {
            if (field['validators'] == "required") {
              if (value == null) {
                return "required field";
              } else {
                return null;
              }
            } else {
              return null;
            }
          },
        );
      case 'Dropdown':
        return FormBuilderDropdown(
          name: field['name'],
          decoration: InputDecoration(labelText: field['label']),
          items: buildDropdownMenuItems(field['options']),
          validator: (value) {
            if (field['validators'] == "required") {
              if (value == null) {
                return "required field";
              } else {
                return null;
              }
            } else {
              return null;
            }
          },
        );
      default:
        return Container();
    }
  }

  List<DropdownMenuItem<T>> buildDropdownMenuItems<T>(List<T> items) {
    return items.map((item) {
      return DropdownMenuItem<T>(
        value: item,
        child: Text(item.toString()), // Customize this as per your requirement
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: ListView(
            children: [
              ...formFields!.map((field) => _buildFormField(field)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        print(_formKey.currentState?.value);

                        User? user = await registerWithEmail(
                            _formKey.currentState?.value["email"],
                            _formKey.currentState?.value["password"]);
                        if (user != null) {
                          await storeDataInRealtimeDatabase(
                              _formKey.currentState!.value);
                          CustomToast.show(context, "Kindly verfiy your email");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        }
                      }
                    },
                    child: const Text('Register'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashboardPage(
                                    email:
                                        _formKey.currentState?.value["email"],
                                  )));
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //funcation
  Future<void> storeDataInRealtimeDatabase(
      Map<String, dynamic> jsonData) async {
    // Reference to the Firebase Realtime Database
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    print(jsonData["email"]);
    try {
      // Push the JSON data to the database
      await databaseReference
          .child("UserModel")
          .child(jsonData["email"].toString().split("@")[0])
          .set(jsonData);
      print('Data stored successfully!');
    } catch (e) {
      print('Error storing data: $e');
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = userCredential.user;

      if (user != null && user.emailVerified) {
        print('User signed in: ${user.email}');
        return user;
      } else if (user != null && !user.emailVerified) {
        print('Email not verified. Please verify your email.');
        await user.sendEmailVerification();
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
      } else {
        print('Something went wrong: ${e.message}');
      }
    }
    return null;
  }

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('Verification email has been sent to ${user.email}');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        CustomToast.show(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        CustomToast.show(context, 'The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        CustomToast.show(context, 'The email address is not valid.');
      } else {
        CustomToast.show(context, 'Registration failed: ${e.message}');
      }
    } catch (e) {
      print('An unknown error occurred: $e');
    }
    return null;
  }
}

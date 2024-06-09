import 'package:cms_task/userinfotitle.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.email});
  final String email;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();
  bool isLoading = true;
  var map;
  @override
  void initState() {
    _listenForData(widget.email);
    super.initState();
  }

  _listenForData(String email) {
    _databaseReference
        .child("UserModel")
        .child(email.split("@")[0])
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        map = event.snapshot.value;

        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(map);
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserInfoTile(label: 'Email', value: map["email"] ?? ""),
                  UserInfoTile(
                      label: 'First Name', value: map["firstName"] ?? ""),
                  UserInfoTile(
                      label: 'Last Name', value: map["lastName"] ?? ""),
                  UserInfoTile(label: 'Username', value: map["username"] ?? ""),
                  UserInfoTile(label: 'Gender', value: map["gender"] ?? ""),
                ],
              ),
      ),
    );
  }
}

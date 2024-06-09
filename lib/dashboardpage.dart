import 'package:cms_task/extension_String.dart';
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
  List<Map<String, String>> map = [];
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
        map = convertMapToList(event.snapshot.value);
        print(map.runtimeType);

        setState(() {
          isLoading = false;
        });
      }
    });
  }

  List<Map<String, String>> convertMapToList(inputMap) {
    List<Map<String, String>> resultList = [];

    inputMap.forEach((key, value) {
      if (key != null && value != null) {
        resultList.add({key.toString(): value.toString()});
      }
    });

    return resultList;
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
                  for (int i = 0; i < map.length; i++)
                    UserInfoTile(
                      label: map[i]
                          .keys
                          .toString()
                          .replaceAll("(", "")
                          .replaceAll(")", "")
                          .capitalizeFirstLetter(),
                      value: map[i]
                          .values
                          .toString()
                          .replaceAll("(", "")
                          .replaceAll(")", ""),
                    ),
                ],
              ),
      ),
    );
  }
}

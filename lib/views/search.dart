import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:swifty_companion/models/student_model.dart';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  const Search({super.key, required this.storage});

  final storage;

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  late Future<Map<String, String>> _storageValues;
  late Future<List<Student>> _students;

  @override
  void initState() {
    _storageValues = widget.storage.readAll();
  }

  Future<List<Student>> fetchListOfStudents(String search, Map<String, String> storage) async {
    List<Student> filteredItems = [];
    try {
      http.Response res = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/users?range[login]=$search,${search}zzzzz'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${storage['token']}',
        },
      ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {throw Exception("The service connexion is lost, please check your internet connection or try again later");}
      );

      debugPrint(res.body);
      var studs = jsonDecode(res.body);
      if (studs == null || studs.isEmpty) {
        return filteredItems;
      }

      for (var stud in studs) {
        try {
          debugPrint(jsonEncode(stud));
          filteredItems.add(Student(login: stud['login'], first_name: stud['first_name']));
        } on Exception catch (e) {
          continue;
        }
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return Future.error("The service connexion is lost, please check your internet connection or try again later");
    }

    return filteredItems;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _storageValues, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasData) {
          return Container(
            color: Colors.transparent,
            child: AppBar(
                backgroundColor: Colors.transparent,
                actions: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: TypeAheadField(
                        hideOnEmpty: false,
                        suggestionsCallback: (search) async {
                          List<Student> list = [];
                          try {
                            list = await fetchListOfStudents(search, snapshot.data!);
                          } catch (e) {
                            //widget.errorTextChanged(e.toString());
                            debugPrint(e.toString());
                          }
                          return list;
                        },
                        errorBuilder: (context, error) => Text(error.toString()),
                        builder: (context, controller, focusNode) {
                          return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              autofocus: false,
                              onSubmitted: (String text) async {
                                debugPrint("Submitted: $text");
                              },
                              decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2, color: Colors.blue)
                                  ),
                                  hintText: 'Search for a student...'
                              )
                          );
                        },
                        itemBuilder: (context, student) {
                          return ListTile(
                            leading: const Icon(Icons.person),
                            titleTextStyle: const TextStyle(fontSize: 20, color: Colors.black),
                            title: Text(student.login),
                          );
                        },
                        onSelected: (student) {
                          debugPrint("Selected: ${student}");
                        },
                      ),
                    ),
                  ),
                ]),
          );
        } else {
          return const Center(child: Text("No data"));
        }
      } else {
        return const Center(child: Text("Loading..."));
      }
    });
  }
}

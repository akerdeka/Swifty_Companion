import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/student_model.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.student, required this.storage});

  final Student? student;
  final storage;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  late Future<Map<String, String>> _storageValues;

  @override
  void initState() {
    _storageValues = widget.storage.readAll();
  }

  Future<Map<String, dynamic>> fetchStudInfos(Student student, Map<String, String> storage) async {
    Map<String, dynamic> studInfos = {};
    try {
      http.Response res = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/users/${student.id}'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${storage['token']}',
        },
      ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {throw Exception("The service connexion is lost, please check your internet connection or try again later");}
      );

      studInfos = jsonDecode(res.body);
    } on Exception catch (e) {
      debugPrint(e.toString());
      return Future.error("The service connexion is lost, please check your internet connection or try again later");
    }

    return studInfos;
  }

  Map<String, dynamic> getProjects(List<dynamic> project_user) {
    Map<String, dynamic> projects = {};
    for (var proj in project_user) {
      projects[proj['project']['name']] ={
        "status": proj['status'] + (proj['final_mark'] != null ? " - ${proj['final_mark']}" : ""),
        "validated": (proj['validated?'] == true) ? "Success" : "Failed"
      };
    }
    return projects;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.student != null) {
      return FutureBuilder(future: _storageValues, builder: (context, snapshot) {
        //region Checkers
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (!snapshot.hasData) {
          return const Text("No data found.");
        }
        //endregion

        return FutureBuilder(future: fetchStudInfos(widget.student!, snapshot.data!), builder: (context, studSnap) {

          //region Checkers
          if (studSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (studSnap.hasError) {
            return Center(child: Text(studSnap.error.toString()));
          }
          if (!studSnap.hasData) {
            return const Text("No data found.");
          }
          //endregion

          Map<String, dynamic> projects = getProjects(studSnap.data!["projects_users"]);


          return Scaffold(
            appBar: AppBar(
              title: Text('${widget.student!.first_name!} ${widget.student!.last_name!}'),
              backgroundColor: Colors.blueGrey,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Image.network(widget.student!.image!.versions!.large??"",
                            errorBuilder: (context, error, stackTrace) => const Placeholder(strokeWidth: 0, color: Colors.blue,)),
                        Text(widget.student!.email??""),
                        Text(widget.student!.location??"Unavailable"),
                        LinearPercentIndicator(
                          lineHeight: 20.0,
                          backgroundColor: Colors.grey,
                          progressColor: Colors.blue,
                          percent: (studSnap.data!['cursus_users'] as List).isEmpty ? 0 : studSnap.data!['cursus_users'][(studSnap.data!['cursus_users'] as List).length - 1]['level'] / 21,
                          center: (studSnap.data!['cursus_users'] as List).isEmpty ? const Text("0") : Text(studSnap.data!['cursus_users'][(studSnap.data!['cursus_users'] as List).length - 1]['level'].toString()),
                        ),
                        Text('Wallet: ${widget.student!.wallet}₳'),
                        Container(height: 50,),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 300,
                    width: MediaQuery.of(context).size.width,
                    child: DefaultTabController(
                      length: 2,
                      child: Scaffold(
                        appBar: AppBar(
                          title: const Text('Projects ans Skills'),
                          backgroundColor: Colors.blueGrey,
                        ),
                        body: TabBarView(
                          children: <Widget>[
                            ListView.builder(
                              itemCount: projects.length,
                              itemBuilder: (context, index) {
                                String key = projects.keys.elementAt(index);
                                if (projects.isEmpty) {
                                  return const ListTile(title: Text("No projects found."));
                                }
                                return ListTile(
                                  title: Text(key),
                                  subtitle: Text(projects[key]['status'], style: TextStyle(color: projects[key]['validated'] == "Success" ? Colors.green : Colors.red)),
                                  trailing: (projects[key]['status'] as String).contains("finished") ? Text(projects[key]['validated']) : null,
                                );
                              },
                            ),
                            ListView.builder(
                              itemCount: (studSnap.data!['cursus_users'] as List).isEmpty ? 1 : studSnap.data!['cursus_users'][(studSnap.data!['cursus_users'] as List).length - 1]['skills'].length,
                              itemBuilder: (context, index) {
                                if ((studSnap.data!['cursus_users'] as List).isEmpty) {
                                  return const ListTile(title: Text("No skills found."));
                                }
                                String skill = studSnap.data!['cursus_users'][(studSnap.data!['cursus_users'] as List).length - 1]['skills'][index]['name'];
                                double level = studSnap.data!['cursus_users'][(studSnap.data!['cursus_users'] as List).length - 1]['skills'][index]['level'];
                                return ListTile(
                                  title: Text(skill),
                                  subtitle: LinearPercentIndicator(
                                    lineHeight: 20.0,
                                    backgroundColor: Colors.grey,
                                    progressColor: Colors.blue,
                                    percent: level / 21,
                                    center: Text(level.toStringAsFixed(2)),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        bottomNavigationBar: const TabBar(
                            tabs: <Widget>[
                              Tab(
                                icon: Icon(Icons.drive_file_rename_outline_sharp),
                                text: "Projects",
                              ),
                              Tab(
                                icon: Icon(Icons.bar_chart),
                                text: "Skills",
                              ),
                            ]),
                      )
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      });
    }
    else {
      return const Center(child: Text("Please select a student in the 'Search' panel."));
    }
  }
}

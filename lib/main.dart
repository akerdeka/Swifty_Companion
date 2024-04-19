import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:swifty_companion/bars/bottom_bar.dart';
import 'package:swifty_companion/views/login.dart';
import 'package:swifty_companion/views/profile.dart';
import 'package:swifty_companion/views/search.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'bars/top_bar.dart';
import 'errors/error_handler.dart';
import 'models/student_model.dart';import 'package:connectivity_plus/connectivity_plus.dart';

Future main() async {
  try {
    await dotenv.load(fileName: ".env");
    runApp(const SwiftyCompanion());
  } on Exception catch (e) {
    ErrorHandler(errorText: e.toString());
  }
}

class SwiftyCompanion extends StatelessWidget {
  const SwiftyCompanion({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swifty Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Swifty Companion'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  final storage = const FlutterSecureStorage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>  with SingleTickerProviderStateMixin {

  bool isLogged = false;
  Student? student;
  late TabController _tabController;
  late List<ConnectivityResult> connectivityResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  void _logginChanged(bool Logged) {
    setState(() {
      isLogged = Logged;
    });
  }

  void _studentSelected(Student stud) {
    setState(() {
      student = stud;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogged) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: const Size.square(50),
              child: TopBar(onLoginChanged: _logginChanged, storage: widget.storage)),
          body: Center(
            child: TabBarView(
              children: [Search(storage: widget.storage, onStudentSelected: _studentSelected, tabController: _tabController), Profile(student: student, storage: widget.storage)],
            ),
          ),
          bottomNavigationBar: BottomBar(tabController: _tabController),
        ),
      );
    }
    return FutureBuilder(
      future: Connectivity().checkConnectivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        connectivityResult = snapshot.data!;
        if (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi)) {
          return Login(onLoginChanged: _logginChanged, storage: widget.storage);
        }
        return const Center(child: Text("No internet connection",
          style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)
        ));
      },
    );
  }
}

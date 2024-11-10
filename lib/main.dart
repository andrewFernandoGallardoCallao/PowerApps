import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:power_apps_flutter/firebase_options.dart';
import 'package:power_apps_flutter/utilities/admin_create_director.dart';
import 'package:power_apps_flutter/utilities/create_request.dart';
import 'package:power_apps_flutter/utilities/list_request_director.dart';
import 'package:power_apps_flutter/utilities/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/CreateRequest',
      routes: {

        /* Andrew Pages
        '/CreateRequest': (context) => const CreateRequest(),
        '/CreateDirector': (context) => const CreateDirector(),
        '/PermisionScreen': (context) => PermisosScreen(),*/ 

        '/CreateRequest': (context) => LoginPage(),
      },
    );
  }
}










/*import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:power_apps_flutter/firebase_options.dart';
import 'package:power_apps_flutter/utilities/login_page.dart';
import 'package:power_apps_flutter/utilities/admin_create_director.dart';
import 'package:power_apps_flutter/utilities/list_request_director.dart';
import 'utilities/create_request.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/PermisionScreen',
      routes: {
        /* Andrew
        '/CreateRequest': (context) => const CreateRequest(),
        '/CreateDirector': (context) => const CreateDirector(),
        '/PermisionScreen': (context) => PermisosScreen(),*/ 

        '/CreateRequest': (context) => LoginPage(),
      },
    );
  }
}*/

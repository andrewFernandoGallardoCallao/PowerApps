import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:power_apps_flutter/firebase_options.dart';
import 'package:power_apps_flutter/models/student.dart';
import 'package:power_apps_flutter/utilities/admin_create_director.dart';
import 'package:power_apps_flutter/utilities/list_request_director.dart';
import 'package:power_apps_flutter/utilities/login_page.dart';
import 'package:power_apps_flutter/utilities/menu_student.dart';
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

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/Login',
      routes: {
        '/Login': (context) => const LoginPage(),
        '/CreateDirector': (context) => const CreateDirector(),
        '/PermisionScreen': (context) => PermisosScreen(),
        '/MenuStudent': (context) => StudentMainMenu(
              student: Student(
                id: 'ZQSnrNOqEQXe6Ma1NAi6sKOj00i2',
                career: 'Ing. Sistemas',
                mail: 'gca5001500@est.univalle.edu',
                name: 'Andrew',
                password: '123',
                type: 'Student',
              ),
            )
      },
    );
  }
}

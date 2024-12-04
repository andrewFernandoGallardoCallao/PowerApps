import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:power_apps_flutter/firebase_options.dart';
import 'package:power_apps_flutter/utilities/admin_create_director.dart';
import 'package:power_apps_flutter/utilities/components/filter_state.dart';
import 'package:power_apps_flutter/utilities/list_request_director.dart';
import 'package:power_apps_flutter/utilities/login_page.dart';
import 'package:power_apps_flutter/utilities/menu_student.dart';
import 'package:provider/provider.dart';

import 'models/student.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FilterState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/Login',
        routes: {
          '/Login': (context) => const LoginPage(),
          '/CreateDirector': (context) => const CreateDirector(),
          '/PermisionScreen': (context) => PermisosScreen(),
          // '/MenuDirector': (context) => DirectorMainMenu(
          //       director: Director(
          //         id: '2MiymTliZ8OSbzxkOxmyZhx5B4D3',
          //         name: "Joaquin Justiniano",
          //         career: 'ISI',
          //         password: 'AnDrEw12345%',
          //         mail: 'andrewgallardo777@gmail.com',
          //         type: 'director',
          //       ),
          //     ),
          '/MenuStudent': (context) => StudentMainMenu(
                student: Student(
                  id: 'ZQSnrNOqEQXe6Ma1NAi6sKOj00i2',
                  career: 'Ing. Sistemas',
                  mail: 'gca5001500@est.univalle.edu',
                  name: 'Andrew',
                  type: 'Student',
                ),
              )
        },
      ),
    );
  }
}

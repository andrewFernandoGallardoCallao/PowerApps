import 'package:flutter/material.dart';
import 'package:power_apps_flutter/models/director.dart';
import 'package:power_apps_flutter/utilities/components/list_request_history.dart';
import 'package:power_apps_flutter/utilities/components/main_color.dart';
import 'package:power_apps_flutter/utilities/list_request_director.dart';

class DirectorMainMenu extends StatefulWidget {
  final Director director;

  const DirectorMainMenu({
    super.key,
    required this.director,
  });

  @override
  State<DirectorMainMenu> createState() => _DirectorMainMenuState();
}

class _DirectorMainMenuState extends State<DirectorMainMenu> {
  int _currentIndex = 0;
  final List<String> _titles = [
    'Solicitudes',
    'Historial',
  ];
  List<Widget> _getPages() {
    return [
      const PermisosScreen(),
      const PermisosScreenHistory(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        toolbarHeight: 100,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _titles[_currentIndex],
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.director.name,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.director.mail,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.director.career,
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Urbanist',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _getPages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}

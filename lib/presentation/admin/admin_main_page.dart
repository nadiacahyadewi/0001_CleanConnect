import 'package:cleanconnect/core/constants/colors.dart';
import 'package:cleanconnect/presentation/admin/home/admin_home_screen.dart';
import 'package:cleanconnect/presentation/admin/home/pemesanan_screen.dart';
import 'package:flutter/material.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;
  final _widgets = [
    const AdminHomeScreen(),
    const PemesananCustomerScreen(),
    // const AnakCanaryScreen(),
    // const PostingScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgets),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.0,
              blurStyle: BlurStyle.outer,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
          child: Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: const Color.fromARGB(255, 0, 109, 34),
              useLegacyColorScheme: false,
              currentIndex: _selectedIndex,
              onTap: (value) => setState(() {
                _selectedIndex = value;
              }),
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(color: AppColors.lightSheet),
              selectedIconTheme: const IconThemeData(color: AppColors.lightSheet),
              unselectedLabelStyle: const TextStyle(color: AppColors.grey),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    color: _selectedIndex == 0
                        ? AppColors.lightSheet
                        : AppColors.grey,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.playlist_add_outlined,
                    color: _selectedIndex == 1
                        ? AppColors.lightSheet
                        : AppColors.grey,
                  ),
                  label: 'Permintaan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.history,
                    color: _selectedIndex == 2
                        ? AppColors.lightSheet
                        : AppColors.grey,
                  ),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person,
                    color: _selectedIndex == 3
                        ? AppColors.lightSheet
                        : AppColors.grey,
                  ),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
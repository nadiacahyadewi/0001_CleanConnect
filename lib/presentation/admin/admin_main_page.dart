import 'package:cleanconnect/core/constants/colors.dart';
import 'package:cleanconnect/core/core.dart';
import 'package:cleanconnect/presentation/admin/home/admin_home_screen.dart';
import 'package:cleanconnect/presentation/admin/home/pemesanan_screen.dart';
import 'package:cleanconnect/presentation/customer/home/riwayat_home_screen.dart';
import 'package:cleanconnect/presentation/auth/login_screen.dart';
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
    const RiwayatPemesananCustomerScreen(),
  ];

  void _handleNavigation(int index) {
    if (index == 3) {
      // Index 3 adalah logout
      _showLogoutDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog dulu
                // Logika untuk logout
                context.pushAndRemoveUntil(
                  const LoginScreen(),
                  (_) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

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
              onTap: _handleNavigation, // Gunakan custom handler
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
                    Icons.logout,
                    color: AppColors.grey, // Selalu grey karena bukan navigasi biasa
                  ),
                  label: 'Logout',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
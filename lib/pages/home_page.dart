import 'package:flutter/material.dart';
import 'package:projek_akhir/pages/list_page.dart';
import 'package:projek_akhir/auth/session_manager.dart';
import 'package:projek_akhir/pages/login_page.dart';
import 'package:projek_akhir/pages/competition_page.dart';
import 'package:projek_akhir/pages/maps_page.dart'; 
import 'package:projek_akhir/pages/profile_page.dart';
import 'package:projek_akhir/pages/saran_page.dart';
import 'package:projek_akhir/pages/tiket_page.dart';
import 'package:projek_akhir/pages/sensor_page.dart';

class HomePage extends StatefulWidget {
  
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

//Navigation bar dengan 3 Pages
class _HomePageState extends State<HomePage> {
late int currentUserId = 1;


Future<void> _handleLogout() async {
  // Tampilkan dialog konfirmasi
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );

  // Jika user mengkonfirmasi logout
  if (shouldLogout == true) {
    try {
      // Tampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Lakukan logout
      final sessionManager = await SessionManager.getInstance();
      final logoutSuccess = await sessionManager.logout();

      // Tutup loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (logoutSuccess) {
        // Logout berhasil, navigasi ke login page dan hapus semua route sebelumnya
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        // Logout gagal, tampilkan pesan error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal melakukan logout. Silakan coba lagi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Tutup loading dialog jika masih terbuka
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Tampilkan pesan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      print('Error during logout: $e');
    }
  }
}

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomePageContent(),
    const ProfilePage(),
    const SaranPage(),
  ];

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _selectedIndex == 0
              ? AppBar(
                backgroundColor: const Color.fromARGB(255, 255, 0, 0), // AppBar hitam
                elevation: 1,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Formula 1 App', // Mengganti judul
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _handleLogout();                          
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Tombol logout merah gelap
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red[50]!, Colors.red[700]!],
          ),
        ),
        child: _pages[_selectedIndex],
      ),
      // Latar belakang body hitam
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 255, 13, 0), // Item yang dipilih merah gelap
        unselectedItemColor: Colors.white, // Item yang tidak dipilih putih
        backgroundColor: Colors.black, // Background nav bar hitam
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Saran & Kesan'),
        ],
      ),
    );
  }
}

//Isi dari HomePage
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _buildMenuItem(
            context,
            'List Data',
            Icons.list,
            Colors.white, // Merah gelap
            const ListPage(),
          ),
          _buildMenuItem(
            context,
            'Competition',
            Icons.emoji_events,
            Colors.black, // Putih
            const CompetitionPage(currentUserId: 1),
          ),
          _buildMenuItem(
            context,
            'Maps',
            Icons.location_on,
            Colors.black, // Hitam
            const SimpleMapsPage(),
          ),
          _buildMenuItem(
            context,
            'Beli Ticket',
            Icons.monetization_on,
            Colors.white,
            const TiketPage(),
          ),
          _buildMenuItem(
            context,
            'Sensor',
            Icons.sports_soccer,
            Colors.white, // Putih
            const SensorPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(3, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color == Colors.black ? Colors.white : Colors.black), // Warna icon disesuaikan
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color == Colors.black ? Colors.white : Colors.black, // Warna teks disesuaikan
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
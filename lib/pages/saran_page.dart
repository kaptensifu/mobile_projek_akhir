import 'package:flutter/material.dart';
import 'package:projek_akhir/pages/home_page.dart';


class SaranPage extends StatelessWidget {
  const SaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red[700]!, Colors.red[900]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline, // Changed icon to suggest ideas/feedback
                        size: 64,
                        color: Colors.red[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Saran dan Kesan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Kesan:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mata kuliah Teknologi Pemrograman Mobile ini memberikan kesan yang luar biasa. Penuh adrenaline, menguatkan mental, dan tak bisa dipungkiri, cukup melelahkan. Namun, pengalaman ini sangat berharga dalam membangun aplikasi mobile.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Saran:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Untuk ke depannya, sebaiknya untuk pengumpulan tugas, laporan, maupun presentasi (PPT) dapat diberikan kelonggaran waktu, misalnya dikumpulkan 1 hari setelah proyek utama dikumpulkan. Hal ini akan membantu mahasiswa dalam mengelola waktu dan memastikan kualitas pekerjaan.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()),
                            ); // Navigate back
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Kembali',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
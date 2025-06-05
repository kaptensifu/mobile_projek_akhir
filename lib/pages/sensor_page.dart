import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async'; // Untuk StreamSubscription

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  // Variabel untuk menyimpan data giroskop
  List<double>? _gyroscopeValues;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  // Variabel untuk melacak rotasi simulasi atau aksi F1
  double _simulatedSteeringAngle = 0.0;
  String _f1ActionMessage = 'Ready to feel the G\'s!';

  @override
  void initState() {
    super.initState();
    // Berlangganan (subscribe) ke event giroskop
    _gyroscopeSubscription = gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (GyroscopeEvent event) {
        setState(() {
          _gyroscopeValues = <double>[event.x, event.y, event.z];

          // Contoh implementasi: Simulasi Kemudi F1
          // Kita akan menggunakan sumbu Y (pitch) untuk kemudi kiri/kanan
          // Sesuaikan sensitivitas sesuai kebutuhan
          _simulatedSteeringAngle += event.y * 5.0; // Mengalikan dengan faktor sensitivitas
          // Pastikan sudut tetap dalam rentang -180 hingga 180 derajat
          if (_simulatedSteeringAngle > 180.0) {
            _simulatedSteeringAngle -= 360.0;
          } else if (_simulatedSteeringAngle < -180.0) {
            _simulatedSteeringAngle += 360.0;
          }

          // Contoh: Memicu aksi F1 berdasarkan gerakan kuat
          if (event.y.abs() > 5.0) { // Jika rotasi sumbu Y sangat cepat
            _f1ActionMessage = 'Quick Corner Turn!';
          } else if (event.x.abs() > 5.0) { // Jika rotasi sumbu X sangat cepat
            _f1ActionMessage = 'Heavy Braking/Acceleration!';
          } else if (event.z.abs() > 5.0) { // Jika rotasi sumbu Z sangat cepat
            _f1ActionMessage = 'Spinning Out!';
          } else {
            _f1ActionMessage = 'Steady Driving...';
          }
        });
      },
      onError: (e) {
        // Tangani jika sensor tidak tersedia atau ada error
        print("Gyroscope sensor error: $e");
        setState(() {
          _f1ActionMessage = 'Gyroscope not available or error: $e';
        });
      },
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    // Pastikan untuk menghentikan langganan sensor saat widget dihapus
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> gyroscope = _gyroscopeValues?.map((double v) => v.toStringAsFixed(2)).toList() ?? ['0.00', '0.00', '0.00'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'F1 Gyro Sensor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red[700]!, Colors.red[50]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.orange[50]!],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.track_changes, size: 50, color: Colors.red[700]),
                      const SizedBox(height: 16),
                      Text(
                        'Gyroscope Data (rad/s)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('X: ${gyroscope[0]}', style: const TextStyle(fontSize: 18)),
                      Text('Y: ${gyroscope[1]}', style: const TextStyle(fontSize: 18)),
                      Text('Z: ${gyroscope[2]}', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.blue[50]!],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_motorsports, size: 50, color: Colors.blue[700]),
                      const SizedBox(height: 16),
                      Text(
                        'F1 Driving Simulation',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Steering Angle: ${_simulatedSteeringAngle.toStringAsFixed(1)}°',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _f1ActionMessage,
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Visualisasi sederhana untuk kemudi
                      Transform.rotate(
                        angle: _simulatedSteeringAngle * (3.1415926535 / 180), // Konversi derajat ke radian
                        child: Icon(
                          Icons.add_circle_outline_rounded, // Atau icon kemudi jika ada
                          size: 80,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
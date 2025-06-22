import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard.dart';
import 'login_screen.dart';
import 'staff_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // On vérifie si un 'userId' est stocké
    final String? userId = prefs.getString('userId');

    // On attend un court instant pour que l'écran de démarrage soit visible
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    if (userId != null && userId.isNotEmpty) {
      // Si l'utilisateur est connecté, on le redirige
      final String? userRole = prefs.getString('userRole');
      if (userRole == 'admin') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AdminDashboard()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => StaffDashboard()));
      }
    } else {
      // Sinon, on va à l'écran de connexion
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Écran de chargement simple avec le logo
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hotel, size: 80, color: Colors.blue.shade700),
            const SizedBox(height: 20),
            const Text(
              'Hotel Staff App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
} 
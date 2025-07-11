import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import 'admin_dashboard.dart';
import 'staff_dashboard.dart';
import '../services/notification_service_web.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (nameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await ApiService.login(nameController.text, passwordController.text);
      if (user != null) {
        try {
          await NotificationService.promptForPushNotifications();
          await NotificationService.subscribeUserToPush();
          await NotificationService.waitForPlayerIdReady();
          // Toujours utiliser l'ID MongoDB comme external_id pour OneSignal !
          final String? userId = user['_id'] ?? user['id'];
          if (userId != null) {
            await NotificationService.setExternalUserId(userId);
            await ApiService.syncOneSignalPlayerId(userId);
          }
        } catch (e) {
          print('AVERTISSEMENT: La configuration des notifications a échoué mais la connexion continue. Erreur: $e');
        }

        if (mounted) {
          if (user['role'] == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StaffDashboard()));
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Identifiants incorrects'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion. Veuillez vérifier vos identifiants ou votre connexion.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 500;
    final maxWidth = isWide ? 400.0 : double.infinity;
    final horizontalPadding = isWide ? 0.0 : 24.0;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.hotel,
                              size: 60,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            'Hotel Staff App',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Gestion des réclamations internes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 50),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Connexion',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Nom d\'utilisateur',
                                      prefixIcon: Icon(Icons.person_outline, color: Colors.blue.shade700),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextField(
                                    controller: passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Mot de passe',
                                      prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade700),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: Colors.grey.shade600,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              'Se connecter',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

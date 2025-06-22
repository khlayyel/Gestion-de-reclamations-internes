// Importation du package Flutter pour utiliser les widgets de Material Design
import 'package:flutter/material.dart';
// Importation de l'écran de connexion personnalisé
import 'screens/login_screen.dart';
// Importe notre service de notification abstrait, qui gère la logique web/mobile
import 'services/notification_service.dart';
import 'services/pwa_service.dart'; // Importe le nouveau service

// Point d'entrée principal de l'application
void main() async {
  // S'assure que le binding de Flutter est initialisé avant d'exécuter l'application
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialise notre service de notification.
  // Sur mobile, cela configure OneSignal.
  // Sur web, cela attend que le SDK JS soit prêt.
  await NotificationService.init();

  // Initialise le service PWA pour écouter l'événement d'installation
  PwaService.init();

  // Lance l'application en affichant le widget MyApp
  runApp(MyApp());
}

// Définition du widget principal de l'application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retourne une application Material avec un thème personnalisé et l'écran de connexion comme page d'accueil
    return MaterialApp(
      title: 'Hotel Staff App', // Titre de l'application
      theme: ThemeData(
        primarySwatch: Colors.blue, // Couleur principale
        visualDensity: VisualDensity.adaptivePlatformDensity, // Densité visuelle adaptée à la plateforme
      ),
      home: LoginScreen(), // Écran affiché au démarrage
      debugShowCheckedModeBanner: false, // Désactive le bandeau "debug"
    );
  }
}

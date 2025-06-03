// Importation du package Flutter pour utiliser les widgets de Material Design
import 'package:flutter/material.dart';
// Importation de l'écran de connexion personnalisé
import 'screens/login_screen.dart';

// Point d'entrée principal de l'application
void main() {
  // S'assure que le binding de Flutter est initialisé avant d'exécuter l'application
  WidgetsFlutterBinding.ensureInitialized();
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

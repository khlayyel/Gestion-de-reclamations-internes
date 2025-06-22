import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  // Import nécessaire pour SharedPreferences

// URL de base de l'API
final String baseUrl = kDebugMode 
    ? "http://localhost:5000/api" // URL pour le développement local
    : "https://gestion-de-reclamations-internes.onrender.com/api"; // URL pour la production

// Service d'accès à l'API pour l'authentification et les infos utilisateur
class ApiService {

  // Méthode pour se connecter
  static Future<Map<String, dynamic>?> login(String name, String password) async {
    final url = Uri.parse('$baseUrl/users/login');
    print('Tentative de connexion avec: name=$name');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'password': password}),
      );

      print('Réponse du serveur: \\${response.statusCode}');
      print('Corps de la réponse: \\${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        
        // Récupération des infos utilisateur
        String userId = responseData['id'] ?? responseData['_id'] ?? '';
        String userName = responseData['name'];
        String userEmail = responseData['email'];
        String userRole = responseData['role'] ?? 'staff';
        List<String> userDepartments = List<String>.from(responseData['departments'] ?? []);
        
        // Stockage local des infos utilisateur
        await prefs.setString('userId', userId);
        await prefs.setString('userName', userName);
        await prefs.setString('userEmail', userEmail);
        await prefs.setString('userRole', userRole);
        await prefs.setStringList('userDepartments', userDepartments);
        
        print('Connexion réussie pour: $userName avec le rôle: $userRole');
        return responseData;
      } else {
        print('Échec de la connexion: \\${response.statusCode}');
        print('Message d\'erreur: \\${response.body}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return null;
    }
  }

  // Méthode pour obtenir l'email de l'utilisateur connecté
  static Future<String?> obtenirEmailUtilisateurConnecte() async {
    final prefs = await SharedPreferences.getInstance();
    // Récupérer l'email de l'utilisateur stocké dans SharedPreferences
    String? userEmail = prefs.getString('userEmail');
    return userEmail;  // Retourner l'email ou null si l'utilisateur n'est pas connecté
  }

  // Méthode pour obtenir le nom de l'utilisateur connecté
  static Future<String?> obtenirNomUtilisateurConnecte() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  // Méthode pour obtenir le rôle de l'utilisateur connecté
  static Future<String?> obtenirRoleUtilisateurConnecte() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  // Méthode pour obtenir les départements de l'utilisateur connecté
  static Future<List<String>> obtenirDepartementsUtilisateurConnecte() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('userDepartments') ?? [];
  }

  // Méthode pour obtenir l'id de l'utilisateur connecté
  static Future<String?> obtenirIdUtilisateurConnecte() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Méthode pour se déconnecter
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userRole');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Service pour la gestion des utilisateurs (CRUD)
class UserService {
  // Getter pour l'URL de base de l'API
  static String get baseUrl {
    return 'https://gestion-de-reclamations-internes.onrender.com';
  }

  // Récupérer la liste de tous les utilisateurs
  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/get'));
    if (response.statusCode == 200) {
      // Décodage de la réponse JSON
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des utilisateurs');
    }
  }

  // Supprimer un utilisateur par son ID
  static Future<void> deleteUser(String id, BuildContext context) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/users/$id'));
    if (response.statusCode == 200) {
      // Affiche un message de succès
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilisateur supprimé')));
    } else {
      // Affiche un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la suppression de l\'utilisateur')));
      throw Exception('Erreur lors de la suppression');
    }
  }

  // Créer un nouvel utilisateur
  static Future<void> createUser(Map<String, dynamic> userData, BuildContext context) async {
    // Préparation du corps de la requête
    final body = <String, dynamic>{
      ...userData,
      if (userData['departments'] != null && userData['departments'] is List && (userData['departments'] as List).isNotEmpty)
        'departments': List<String>.from(userData['departments']),
    };
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 201) {
      // Affiche un message de succès
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilisateur créé avec succès')));
    } else {
      // Affiche un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la création de l\'utilisateur')));
      throw Exception('Erreur lors de la création de l\'utilisateur');
    }
  }

  // Modifier un utilisateur existant
  static Future<void> updateUser(String id, Map<String, dynamic> userData, BuildContext context) async {
    // Préparation du corps de la requête
    final body = <String, dynamic>{
      ...userData,
      if (userData['departments'] != null && userData['departments'] is List && (userData['departments'] as List).isNotEmpty)
        'departments': List<String>.from(userData['departments']),
    };
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      // Affiche un message de succès
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilisateur modifié avec succès')));
    } else {
      // Affiche un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la modification de l\'utilisateur')));
      throw Exception('Erreur lors de la modification de l\'utilisateur');
    }
  }

  // Vérifier si un email existe déjà dans la base
  static Future<bool> checkEmailExists(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/get'));
    if (response.statusCode == 200) {
      final users = json.decode(response.body) as List;
      // Vérifie si l'email existe déjà
      return users.any((u) => u['email'] == email);
    }
    return false;
  }

  // Récupérer le nom de l'utilisateur connecté (stocké localement)
  static Future<String?> getConnectedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }
} 
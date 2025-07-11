import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/reclamation.dart';
import 'package:flutter/foundation.dart';  // Pour vérifier la plateforme
import 'package:flutter/material.dart';

// Service pour la gestion des réclamations (CRUD)
class ReclamationService {
  // Fonction pour obtenir l'URL de base selon la plateforme
  static String getBaseUrl() {
    return kDebugMode
        ? 'http://localhost:5000' // URL pour le développement local
        : 'https://gestion-de-reclamations-internes.onrender.com'; // URL pour la production
  }

  // Méthode pour récupérer toutes les réclamations
  static Future<List<Reclamation>> getReclamations() async {
    final baseUrl = getBaseUrl();
    final response = await http.get(Uri.parse('$baseUrl/api/reclamations'));

    print('GET Reclamations response code: ${response.statusCode}');
    print('GET Reclamations response body: ${response.body}');

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        // Décodage de la réponse JSON et conversion en liste de Réclamation
        List<dynamic> data = json.decode(response.body);
        print('Reclamations count: ${data.length}');
        return data.map((e) => Reclamation.fromJson(e)).toList();
      } else {
        throw Exception('Réponse vide de l\'API');
      }
    } else {
      throw Exception('Failed to load reclamations');
    }
  }

  // Méthode pour créer une nouvelle réclamation
  static Future<void> createReclamation(Reclamation reclamation, BuildContext context) async {
    final baseUrl = getBaseUrl();
    if (reclamation == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La réclamation ne peut pas être nulle')));
      throw Exception('La réclamation ne peut pas être nulle');
    }
    final response = await http.post(
      Uri.parse('$baseUrl/api/reclamations/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reclamation.toJson()),
    );
    if (response.statusCode == 201) {
      // Affiche un message de succès
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Réclamation créée avec succès')));
    } else {
      // Affiche un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la création de la réclamation')));
      throw Exception('Failed to create reclamation');
    }
  }

  // Méthode pour modifier une réclamation existante
  static Future<void> updateReclamation(Reclamation reclamation, BuildContext context) async {
    final baseUrl = getBaseUrl();
    if (reclamation.id == null || reclamation.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ID de la réclamation manquant')));
      throw Exception('La réclamation doit avoir un ID pour être modifiée');
    }
    final response = await http.put(
      Uri.parse('$baseUrl/api/reclamations/update/${reclamation.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reclamation.toJson()),
    );
    if (response.statusCode == 200) {
      // Affiche un message de succès
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Réclamation modifiée avec succès')));
    } else {
      // Affiche un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la modification de la réclamation')));
      throw Exception('Échec de la modification de la réclamation');
    }
  }

  // Méthode pour mettre à jour uniquement le status d'une réclamation (et éventuellement l'assignation)
  static Future<void> updateReclamationStatus(String id, String status, {String? assignedTo}) async {
    final baseUrl = getBaseUrl();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/reclamations/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': status,
          if (assignedTo != null) 'assignedTo': assignedTo,
        }),
      );

      if (response.statusCode != 200) {
        print('Erreur de mise à jour du statut: ${response.body}');
        throw Exception('Échec de la mise à jour du statut: ${response.body}');
      }
    } catch (e) {
      print('Exception lors de la mise à jour du statut: $e');
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Méthode pour supprimer une réclamation
  static Future<void> deleteReclamation(String id, BuildContext context) async {
    final baseUrl = getBaseUrl();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/reclamations/$id'),
    );
    if (response.statusCode == 200) {
      // Affiche un message de succès
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Réclamation supprimée')));
    } else {
      // Affiche un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la suppression de la réclamation')));
      throw Exception('Erreur lors de la suppression de la réclamation');
    }
  }

  // Méthode pour récupérer les réclamations filtrées par utilisateur
  static Future<List<Reclamation>> getReclamationsByUser(String userId) async {
    final baseUrl = getBaseUrl();
    final response = await http.get(Uri.parse('$baseUrl/api/reclamations/byUser?userId=$userId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Reclamation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load filtered reclamations');
    }
  }
}

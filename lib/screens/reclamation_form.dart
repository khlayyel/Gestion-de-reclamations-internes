import 'dart:io';
import 'package:flutter/foundation.dart';  // Import nécessaire pour kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';  // Assurez-vous d'importer ApiService

class ReclamationForm extends StatefulWidget {
  @override
  _ReclamationFormState createState() => _ReclamationFormState();
}

class _ReclamationFormState extends State<ReclamationForm> {
  final _formKey = GlobalKey<FormState>();
  // Méthode pour obtenir l'URL en fonction de la plateforme
  static String get baseUrl {
    return 'https://gestion-de-reclamations-internes.onrender.com';
  }

  // Variables pour stocker les valeurs des champs
  String _objet = '';
  String _description = '';
  List<String> _departments = [];
  String _status = 'New';  // Toujours 'New' pour une nouvelle réclamation
  String _location = '';
  String _createdBy = '';
  int? _priority;  // Changé en nullable pour indiquer qu'aucune priorité n'est sélectionnée

  // Liste des départements pour CheckboxListTile
  final List<String> _availableDepartments = [
    'Nettoyage',
    'Réception',
    'Maintenance',
    'Sécurité',
    'Restauration',
    'Cuisine',
    'Blanchisserie',
    'Spa',
    'Informatique',
    'Direction'
  ];

  // Liste des priorités avec leurs descriptions
  final List<Map<String, dynamic>> _priorityOptions = [
    {'value': 3, 'label': 'Basse', 'color': Colors.purple},
    {'value': 2, 'label': 'Moyenne', 'color': Colors.orange},
    {'value': 1, 'label': 'Haute', 'color': Colors.red},
  ];

  // Problèmes types d'hôtel
  final List<Map<String, dynamic>> _commonProblems = [
    {
      'icon': Icons.wc,
      'objet': "Toilettes sales",
      'description': "Les toilettes sont sales ou malodorantes.",
      'departments': ['Nettoyage'],
      'priority': 1,
    },
    {
      'icon': Icons.lightbulb_outline,
      'objet': "Ampoule grillée",
      'description': "Une ampoule ne fonctionne plus dans la chambre ou le couloir.",
      'departments': ['Maintenance'],
      'priority': 2,
    },
    {
      'icon': Icons.water_damage,
      'objet': "Fuite d'eau",
      'description': "Fuite d'eau détectée dans la salle de bain ou ailleurs.",
      'departments': ['Maintenance'],
      'priority': 1,
    },
    {
      'icon': Icons.ac_unit,
      'objet': "Climatisation en panne",
      'description': "La climatisation ne fonctionne pas ou fait du bruit.",
      'departments': ['Maintenance'],
      'priority': 2,
    },
    {
      'icon': Icons.tv,
      'objet': "Télévision défectueuse",
      'description': "La télévision ne s'allume pas ou a des problèmes d'image/son.",
      'departments': ['Maintenance', 'Informatique'],
      'priority': 2,
    },
    {
      'icon': Icons.wifi_off,
      'objet': "Problème Wi-Fi",
      'description': "Le Wi-Fi ne fonctionne pas ou est très lent.",
      'departments': ['Informatique'],
      'priority': 3,
    },
    {
      'icon': Icons.cleaning_services,
      'objet': "Chambre non nettoyée",
      'description': "La chambre n'a pas été nettoyée ou mal nettoyée.",
      'departments': ['Nettoyage'],
      'priority': 1,
    },
    {
      'icon': Icons.restaurant,
      'objet': "Problème de repas",
      'description': "Le repas servi est froid, manquant ou incorrect.",
      'departments': ['Restauration', 'Cuisine'],
      'priority': 2,
    },
    {
      'icon': Icons.lock,
      'objet': "Serrure défectueuse",
      'description': "La serrure de la porte ne fonctionne pas correctement.",
      'departments': ['Maintenance', 'Sécurité'],
      'priority': 1,
    },
    {
      'icon': Icons.local_laundry_service,
      'objet': "Problème de linge",
      'description': "Le linge n'a pas été changé ou est manquant.",
      'departments': ['Blanchisserie'],
      'priority': 2,
    },
  ];

  // Ajout des contrôleurs pour objet et description
  final TextEditingController _objetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Fonction pour récupérer l'email de l'utilisateur connecté
  void _getUserEmail() async {
    String? email = await ApiService.obtenirEmailUtilisateurConnecte();
    if (email != null) {
      setState(() {
        _createdBy = email;
      });
    } else {
      print("Aucun utilisateur connecté");
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserEmail();
    // Initialiser avec une liste vide au lieu de tous les départements
    _departments = [];
  }

  @override
  void dispose() {
    _objetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Fonction pour soumettre le formulaire
  void _submitForm() async {
    if (_createdBy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Le nom de l\'utilisateur n\'est pas encore chargé. Veuillez patienter.'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 10,
            right: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_priority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Veuillez sélectionner une priorité.'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 10,
            right: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_departments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Veuillez sélectionner au moins un département.'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 10,
            right: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final reclamationData = {
        'objet': _objet,
        'description': _description,
        'createdBy': _createdBy,
        'departments': _departments,
        'priority': _priority,  // Utilisation de la priorité sélectionnée
        'status': 'New',
        'location': _location,
      };

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/reclamations/create'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(reclamationData),
        );

        if (response.statusCode == 201) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Échec de la création de la réclamation.'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 100,
                left: 10,
                right: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Une erreur est survenue. Veuillez réessayer.'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 100,
              left: 10,
              right: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_createdBy.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Créer une réclamation'),
          elevation: 0,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      );
    }

    final isWide = MediaQuery.of(context).size.width > 700;
    final maxWidth = isWide ? 600.0 : double.infinity;
    final horizontalPadding = isWide ? 0.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une réclamation'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ajout : grille de problèmes types
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '  Problèmes courants',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            SizedBox(height: 8),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWide ? 5 : 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: _commonProblems.length,
                              itemBuilder: (context, index) {
                                final problem = _commonProblems[index];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _objet = problem['objet'];
                                      _description = problem['description'];
                                      _departments = List<String>.from(problem['departments']);
                                      _priority = problem['priority'];
                                      // Remplir les contrôleurs
                                      _objetController.text = problem['objet'];
                                      _descriptionController.text = problem['description'];
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.blue.shade100, width: 2),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.shade50,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(problem['icon'], color: Colors.blue, size: 32),
                                        SizedBox(height: 8),
                                        Text(
                                          problem['objet'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informations principales',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Objet',
                                  prefixIcon: Icon(Icons.title),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                controller: _objetController,
                                validator: (value) => value!.isEmpty ? 'L\'objet est requis' : null,
                                onChanged: (value) => setState(() => _objet = value),
                                onSaved: (value) => _objet = value!,
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  prefixIcon: Icon(Icons.description),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                maxLines: 3,
                                controller: _descriptionController,
                                validator: (value) => value!.isEmpty ? 'La description est requise' : null,
                                onChanged: (value) => setState(() => _description = value),
                                onSaved: (value) => _description = value!,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Détails',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Emplacement',
                                  prefixIcon: Icon(Icons.location_on),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (value) => value!.isEmpty ? 'L\'emplacement est requis' : null,
                                onSaved: (value) => _location = value!,
                              ),
                              SizedBox(height: 16),
                              // Ajout du sélecteur de priorité
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Priorité',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: _priorityOptions.map((priority) {
                                      return Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _priority = priority['value'];
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                              decoration: BoxDecoration(
                                                color: _priority == priority['value']
                                                    ? priority['color'].withOpacity(0.1)
                                                    : Colors.grey.shade100,
                                                border: Border.all(
                                                  color: _priority == priority['value']
                                                      ? priority['color']
                                                      : Colors.grey.shade300,
                                                  width: _priority == priority['value'] ? 2 : 1,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.flag,
                                                    color: priority['color'],
                                                    size: 24,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    priority['label'],
                                                    style: TextStyle(
                                                      color: priority['color'],
                                                      fontWeight: _priority == priority['value']
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Départements concernés',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Sélectionnez au moins un département',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              ..._availableDepartments.map((String dept) {
                                return CheckboxListTile(
                                  title: Text(dept),
                                  value: _departments.contains(dept),
                                  activeColor: Colors.blue,
                                  checkColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      if (selected != null && selected) {
                                        _departments.add(dept);
                                      } else {
                                        _departments.remove(dept);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: Icon(Icons.add_circle),
                          label: Text('Créer la réclamation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
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

// Modèle de données représentant une réclamation
class Reclamation {
  // Identifiant unique de la réclamation (généré par MongoDB)
  String id; // <-- Ajout de l'ID
  // Objet ou titre de la réclamation
  String objet;
  // Description détaillée de la réclamation
  String description;
  // Liste des départements concernés par la réclamation
  List<String> departments;
  // Niveau de priorité (1 = haute, 2 = moyenne, 3 = basse)
  int priority;
  // Statut de la réclamation (New, In Progress, Done)
  String status;
  // Emplacement où le problème a été signalé
  String location;
  // Date de création de la réclamation
  DateTime createdAt;
  // Date de dernière mise à jour
  DateTime updatedAt;
  // Créateur de la réclamation (email ou nom)
  String createdBy;
  // Utilisateur assigné à la réclamation
  String assignedTo;

  // Constructeur de la classe Reclamation
  Reclamation({
    required this.id, // <-- Ajouté dans le constructeur
    required this.objet,
    required this.description,
    required this.departments,
    required this.priority,
    required this.status,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.assignedTo,
  });

  // Méthode de fabrique pour créer une instance à partir d'un JSON
  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      id: json['_id'] ?? '', // <-- Assure-toi que le backend renvoie `_id`
      objet: json['objet'] ?? 'Objet non défini',
      description: json['description'] ?? 'Description non définie',
      departments: List<String>.from(json['departments'] ?? []),
      priority: json['priority'] ?? 1,
      status: json['status'] ?? 'New',
      location: json['location'] ?? 'Emplacement non défini',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      createdBy: json['createdBy'] ?? 'Non défini',
      assignedTo: json['assignedTo'] ?? 'Non défini',
    );
  }

  // Convertit l'objet Reclamation en un Map (pour l'envoyer en JSON)
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // <-- Inclure l'ID dans le JSON
      'objet': objet,
      'description': description,
      'departments': departments,
      'priority': priority,
      'status': status,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'assignedTo': assignedTo,
    };
  }
}

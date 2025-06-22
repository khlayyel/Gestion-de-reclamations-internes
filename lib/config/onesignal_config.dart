/// Configuration centralisée pour OneSignal
class OneSignalConfig {
  /// App ID OneSignal
  static const String appId = '6ce72582-adbc-4b70-a16b-6af977e59707';
  
  /// Domaines autorisés pour OneSignal Web
  static const List<String> allowedDomains = [
    'localhost',
    'reclamations-internes.vercel.app',
    // Ajoutez d'autres domaines si nécessaire
  ];
  
  /// Vérifie si le domaine actuel est autorisé
  static bool isDomainAllowed(String hostname) {
    return allowedDomains.any((domain) => hostname == domain || hostname.endsWith('.$domain'));
  }
} 
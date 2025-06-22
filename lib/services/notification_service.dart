import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_mobile.dart'
    if (dart.library.html) 'notification_service_web.dart';

class NotificationService {
  /// Initialise le service de notification au démarrage de l'app.
  static Future<void> init() {
    return initNotificationService();
  }

  /// Récupère le Player ID de l'utilisateur.
  /// Retourne null si l'utilisateur n'est pas abonné.
  static Future<String?> getPlayerId() {
    return getPlayerIdFromService();
  }

  /// Affiche une demande de permission pour les notifications.
  /// Principalement pour le web.
  static Future<void> promptForPushNotifications() {
    return promptForPushNotifications();
  }
} 
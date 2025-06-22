import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_mobile.dart'
    if (dart.library.html) 'notification_service_web.dart';

/// Un service abstrait pour gérer les notifications push sur mobile et web.
class NotificationService {
  /// Initialise le service de notification au démarrage de l'app.
  /// Pour le web, attend que le SDK soit prêt.
  /// Pour mobile, initialise OneSignal.
  static Future<void> init() {
    return initNotificationService();
  }

  /// Récupère le Player ID de l'utilisateur.
  /// Retourne null si l'utilisateur n'est pas abonné.
  static Future<String?> getPlayerId() {
    return getPlayerIdFromService();
  }

  /// Affiche une demande de permission pour les notifications.
  /// - Sur le web, cela affiche le "slidedown prompt" de OneSignal.
  /// - Sur mobile, cela déclenche la demande de permission native.
  static Future<void> promptForPushNotifications() {
    return promptForPushNotifications();
  }
} 
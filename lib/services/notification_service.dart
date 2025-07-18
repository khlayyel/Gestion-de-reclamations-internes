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

  /// Affiche une demande de permission pour les notifications.
  /// - Sur le web, cela affiche le "slidedown prompt" de OneSignal.
  /// - Sur mobile, cela déclenche la demande de permission native.
  static Future<void> promptForPushNotifications() {
    return promptForPushNotificationsFromService();
  }

  /// Force l'abonnement push de l'utilisateur.
  /// À appeler après la demande de permission pour s'assurer que l'abonnement est actif.
  static Future<void> subscribeUserToPush() {
    return subscribeUserToPushFromService();
  }

  /// Lie l'utilisateur courant à OneSignal (external_id)
  static Future<void> setExternalUserId(String externalId) async {
    return setExternalUserIdFromService(externalId);
  }

  /// Attend que le Player ID soit prêt (web uniquement, no-op sur mobile)
  static Future<void> waitForPlayerIdReady() {
    return waitForPlayerIdReadyFromService();
  }

  /// Déconnecte le Player ID OneSignal (désabonne du push)
  static Future<void> logoutOneSignal() {
    return logoutFromService();
  }

  /// Désabonne le Player ID OneSignal du push (unsubscribe)
  static Future<void> unsubscribeFromPush() {
    return unsubscribeFromPushService();
  }
} 
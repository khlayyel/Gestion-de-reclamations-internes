/// Stub pour l'implémentation des notifications quand ni web ni mobile ne sont détectés.

Future<void> initNotificationService() async {
  // Ne fait rien
}

Future<String?> getPlayerIdFromService() async {
  // Retourne toujours null
  return null;
}

Future<void> promptForPushNotificationsFromService() async {
  // Stub : ne fait rien
}

Future<void> subscribeUserToPushFromService() async {
  // Stub : ne fait rien
}

Future<void> setExternalUserIdFromService(String externalId) async {
  // Stub : ne fait rien
}

Future<void> waitForPlayerIdReadyFromService() async {
  // Ne fait rien (no-op)
} 
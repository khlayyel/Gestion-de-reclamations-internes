import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../config/onesignal_config.dart';

Future<void> initNotificationService() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  await OneSignal.initialize(OneSignalConfig.appId);
  await OneSignal.Notifications.requestPermission(true);
}

Future<String?> getPlayerIdFromService() async {
  return OneSignal.User.pushSubscription.id;
}

Future<void> promptForPushNotificationsFromService() async {
  // Sur mobile, la permission est déjà demandée à l'initialisation.
  // On peut la redemander explicitement si nécessaire.
  await OneSignal.Notifications.requestPermission(true);
}

Future<void> subscribeUserToPushFromService() async {
  print('[OneSignal Mobile] Forçage de l\'abonnement push...');
  try {
    // Sur mobile, on force l'opt-in pour l'abonnement push
    await OneSignal.User.pushSubscription.optIn();
    print('✅ [OneSignal Mobile] Abonnement push forcé avec succès');
  } catch (e) {
    print('❌ [OneSignal Mobile] Erreur lors du forçage de l\'abonnement push : $e');
  }
}

Future<void> setExternalUserIdFromService(String externalId) async {
  await OneSignal.User.setExternalUserId(externalId);
}
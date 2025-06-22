import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> initNotificationService() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  await OneSignal.initialize("109a25e1-389f-4f6b-a279-813a36f735c0");
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
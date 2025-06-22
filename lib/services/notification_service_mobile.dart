import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static Future<void> init() async {
    OneSignal.shared.setAppId("6ce72582-adbc-4b70-a16b-6af977e59707");
    await OneSignal.shared.promptUserForPushNotificationPermission();
  }

  static Future<String?> getPlayerId() async {
    final deviceState = await OneSignal.shared.getDeviceState();
    return deviceState?.userId;
  }
}
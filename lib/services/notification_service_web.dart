@JS()
library onesignal_web;

import 'dart:async';
import 'package:js/js.dart';
import 'dart:html';

// --- Définitions pour l'interop JS ---

@JS('OneSignal')
class _OneSignal {
  external static void push(dynamic item);
  external static void init(_InitOptions options);
  external static Future<String?> getPlayerId();
  external static Future<void> showSlidedownPrompt();
}

@JS()
@anonymous
class _InitOptions {
  external factory _InitOptions({
    String appId,
    bool allowLocalhostAsSecureOrigin,
  });
}

// --- Fonctions du service ---

Future<void> initNotificationService() async {
  final hostname = window.location.hostname;
  if (hostname != 'reclamations-internes.vercel.app' && hostname != 'localhost') {
    print('Initialisation de OneSignal ignorée pour le domaine : $hostname');
    return;
  }
  await _waitForOneSignal();
  _OneSignal.push(allowInterop((_) {
    _OneSignal.init(_InitOptions(
      appId: '109a25e1-389f-4f6b-a279-813a36f735c0',
      allowLocalhostAsSecureOrigin: true,
    ));
  }));
}

Future<void> promptForPushNotifications() async {
  final hostname = window.location.hostname;
  if (hostname != 'reclamations-internes.vercel.app' && hostname != 'localhost') {
    return;
  }
  await _waitForOneSignal();
  await _OneSignal.showSlidedownPrompt();
}

Future<String?> getPlayerIdFromService() async {
  final hostname = window.location.hostname;
  if (hostname != 'reclamations-internes.vercel.app' && hostname != 'localhost') {
    return null;
  }
  await _waitForOneSignal();
  return await _OneSignal.getPlayerId();
}

// --- Fonctions utilitaires ---

Future<void> _waitForOneSignal() async {
  for (int i = 0; i < 15; i++) {
    if (_isOneSignalDefined()) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }
  print('OneSignal SDK non chargé après plusieurs tentatives.');
}

@JS('eval')
external bool _eval(String code);

bool _isOneSignalDefined() {
  try {
    return _eval('typeof OneSignal !== "undefined"');
  } catch (e) {
    return false;
  }
} 
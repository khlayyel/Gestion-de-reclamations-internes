@JS()
library onesignal_web;

import 'dart:async';
import 'package:js/js.dart';
import 'dart:html';

// Verrou pour s'assurer que OneSignal n'est initialisé qu'une seule fois.
bool _isOneSignalInitialized = false;

// --- Définitions pour l'interop JS ---

// Classe pour l'objet Notifications de OneSignal
@JS()
@anonymous
class _OneSignalNotifications {
  external Future<bool> requestPermission();
}

// Classe pour l'objet principal OneSignal
@JS('OneSignal')
class _OneSignal {
  external static void push(dynamic item);
  external static void init(_InitOptions options);
  external static Future<String?> getPlayerId();

  // Getter pour accéder à l'objet Notifications
  @JS('Notifications')
  external static _OneSignalNotifications get Notifications;
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
  // On vérifie si le service a déjà été initialisé. Si oui, on ne fait rien.
  if (_isOneSignalInitialized) {
    return;
  }

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

  // On positionne le verrou pour les prochains appels.
  _isOneSignalInitialized = true;
}

Future<void> promptForPushNotifications() async {
  final hostname = window.location.hostname;
  if (hostname != 'reclamations-internes.vercel.app' && hostname != 'localhost') {
    return;
  }
  await _waitForOneSignal();
  // Utilisation de la nouvelle structure pour appeler requestPermission
  await _OneSignal.Notifications.requestPermission();
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
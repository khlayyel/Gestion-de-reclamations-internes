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

// --- Fonctions utilitaires ---

// Fonction pour vérifier si le nom de domaine est autorisé.
// Autorise localhost et tous les sous-domaines de vercel.app.
bool _isAllowedHostname() {
  final hostname = window.location.hostname;
  // On s'assure que le nom de domaine n'est pas nul avant de continuer.
  if (hostname == null) {
    return false;
  }
  return hostname == 'localhost' || hostname.endsWith('.vercel.app');
}

// --- Fonctions du service ---

Future<void> initNotificationService() async {
  if (_isOneSignalInitialized) {
    return;
  }
  // On pose le verrou immédiatement pour empêcher toute autre tentative, qu'elle réussisse ou échoue.
  _isOneSignalInitialized = true;

  if (!_isAllowedHostname()) {
    print('Initialisation de OneSignal ignorée pour le domaine : ${window.location.hostname}');
    return;
  }

  try {
    await _waitForOneSignal();
    _OneSignal.push(allowInterop((_) {
      _OneSignal.init(_InitOptions(
        appId: '109a25e1-389f-4f6b-a279-813a36f735c0',
        allowLocalhostAsSecureOrigin: true,
      ));
    }));
  } catch (e) {
    // Si l'initialisation échoue (ex: mauvais domaine), on l'affiche en console mais on ne bloque pas l'app.
    print('ERREUR : L\'initialisation de OneSignal a échoué. Veuillez vérifier la configuration de votre domaine sur le tableau de bord OneSignal. Erreur: $e');
  }
}

Future<void> promptForPushNotifications() async {
  if (!_isAllowedHostname()) {
    return;
  }
  await _waitForOneSignal();
  await _OneSignal.Notifications.requestPermission();
}

Future<String?> getPlayerIdFromService() async {
  if (!_isAllowedHostname()) {
    return null;
  }
  await _waitForOneSignal();
  return await _OneSignal.getPlayerId();
}

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
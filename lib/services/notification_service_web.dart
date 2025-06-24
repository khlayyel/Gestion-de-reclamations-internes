@JS()
library onesignal_web;

import 'dart:async';
import 'package:js/js.dart';
import 'dart:html';
import '../config/onesignal_config.dart';

// Verrou pour s'assurer que OneSignal n'est initialisé qu'une seule fois.
bool _isOneSignalInitialized = false;

// --- Définitions pour l'interop JS ---

// Classe pour l'objet Notifications de OneSignal
@JS()
@anonymous
class _OneSignalNotifications {
  external Future<bool> requestPermission();
}

@JS()
@anonymous
class _PushSubscription {
  external String? get id;
}

@JS()
@anonymous
class _OneSignalUser {
  external _PushSubscription? get pushSubscription;
}

// Classe pour l'objet principal OneSignal
@JS('OneSignal')
class _OneSignal {
  external static void push(dynamic item);
  external static void init(_InitOptions options);

  @JS('User')
  external static _OneSignalUser get User;

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
    String serviceWorkerPath,
  });
}

// --- Fonctions utilitaires ---

// Fonction pour vérifier si le nom de domaine est autorisé.
bool _isAllowedHostname() {
  final hostname = window.location.hostname;
  // On s'assure que le nom de domaine n'est pas nul avant de continuer.
  if (hostname == null) {
    return false;
  }
  return OneSignalConfig.isDomainAllowed(hostname);
}

// --- Fonctions du service ---

Future<void> initNotificationService() async {
  print('[OneSignal] Démarrage de l\'initialisation du service de notification web...');
  if (_isOneSignalInitialized) {
    print('[OneSignal] Déjà initialisé, on quitte.');
    return;
  }
  _isOneSignalInitialized = true;

  if (!_isAllowedHostname()) {
    print('[OneSignal] Domaine non autorisé : ${window.location.hostname}');
    return;
  }

  try {
    await _waitForOneSignal();
    print('[OneSignal] SDK détecté, initialisation OneSignal...');
    
    // Initialisation simple sans désenregistrement de Service Workers
    _OneSignal.push(allowInterop((_) {
      _OneSignal.init(_InitOptions(
        appId: OneSignalConfig.appId,
        allowLocalhostAsSecureOrigin: true,
        serviceWorkerPath: 'OneSignalSDKWorker.js',
      ));
    }));
    
    print('✅ OneSignal Web initialisé avec succès');
  } catch (e) {
    print('❌ [OneSignal] ERREUR lors de l\'initialisation : $e');
    print('ERREUR : L\'initialisation de OneSignal a échoué. Veuillez vérifier la configuration de votre domaine sur le tableau de bord OneSignal. Erreur: $e');
  }
}

Future<void> promptForPushNotificationsFromService() async {
  print('[OneSignal] Demande explicite de permission de notification...');
  if (!_isAllowedHostname()) {
    print('[OneSignal] Domaine non autorisé pour la demande de permission.');
    return;
  }
  await _waitForOneSignal();
  print('[OneSignal] Appel à OneSignal.Notifications.requestPermission()');
  await _OneSignal.Notifications.requestPermission();
}

Future<void> subscribeUserToPushFromService() async {
  print('[OneSignal] Forçage de l\'abonnement push...');
  if (!_isAllowedHostname()) {
    print('[OneSignal] Domaine non autorisé pour l\'abonnement push.');
    return;
  }
  await _waitForOneSignal();

  try {
    // Demander la permission et forcer l'abonnement
    print('[OneSignal] Demande de permission et abonnement...');
    await _OneSignal.Notifications.requestPermission();
    
    // Attendre un peu que l'abonnement se fasse
    await Future.delayed(const Duration(seconds: 2));
    
    print('✅ [OneSignal] Demande d\'abonnement push terminée');
  } catch (e) {
    print('❌ [OneSignal] Erreur lors du forçage de l\'abonnement push : $e');
  }
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

@JS('OneSignal.login')
external void oneSignalLoginJs(String externalId);

Future<void> setExternalUserIdFromService(String externalId) async {
  if (!_isAllowedHostname()) return;
  await _waitForOneSignal();
  oneSignalLoginJs(externalId);
  print('[OneSignal] OneSignal.login appelé avec : ' + externalId);
  await Future.delayed(const Duration(seconds: 2));
  try {
    final id = _OneSignal.User.pushSubscription?.id;
    print('[OneSignal] Vérification post-login : Player ID = ' + (id ?? 'null'));
  } catch (e) {
    print('[OneSignal] Erreur lors de la vérification post-login : $e');
  }
}

Future<String?> getPlayerIdFromService() async {
  await _waitForOneSignal();
  try {
    return _OneSignal.User.pushSubscription?.id;
  } catch (e) {
    return null;
  }
}

Future<void> waitForPlayerIdReady({int maxTries = 20}) async {
  for (int i = 0; i < maxTries; i++) {
    final id = await getPlayerIdFromService();
    if (id != null && id.isNotEmpty) return;
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

Future<void> waitForPlayerIdReadyFromService() => waitForPlayerIdReady();

@JS('OneSignal.logout')
external Future<void> oneSignalLogoutJs();

Future<void> logoutFromService() async {
  if (!_isAllowedHostname()) return;
  await _waitForOneSignal();
  await oneSignalLogoutJs();
  print('[OneSignal] OneSignal.logout appelé (web)');
}
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
    String serviceWorkerUpdaterPath,
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
  debugPrint('[OneSignal] Démarrage de l\'initialisation du service de notification web...');
  if (_isOneSignalInitialized) {
    debugPrint('[OneSignal] Déjà initialisé, on quitte.');
    return;
  }
  _isOneSignalInitialized = true;

  if (!_isAllowedHostname()) {
    debugPrint('[OneSignal] Domaine non autorisé : [window.location.hostname]');
    return;
  }

  try {
    await _waitForOneSignal();
    debugPrint('[OneSignal] SDK détecté, vérification des Service Workers...');
    if (window.navigator.serviceWorker != null) {
      final registrations = await window.navigator.serviceWorker!.getRegistrations();
      debugPrint('[OneSignal] Nombre de Service Workers trouvés : [registrations.length]');
      for (final reg in registrations) {
        debugPrint('[OneSignal] Désenregistrement du Service Worker : [reg.scope]');
        await reg.unregister();
      }
      debugPrint('[OneSignal] Tous les anciens Service Workers ont été désenregistrés.');
    } else {
      debugPrint('[OneSignal] Aucun support Service Worker détecté dans ce navigateur.');
    }
    debugPrint('[OneSignal] Initialisation OneSignal...');
    _OneSignal.push(allowInterop((_) {
      _OneSignal.init(_InitOptions(
        appId: OneSignalConfig.appId,
        allowLocalhostAsSecureOrigin: true,
        serviceWorkerPath: 'OneSignalSDKWorker.js',
        serviceWorkerUpdaterPath: 'OneSignalSDKUpdaterWorker.js',
      ));
    }));
    debugPrint('✅ OneSignal Web initialisé avec succès');
  } catch (e) {
    debugPrint('❌ [OneSignal] ERREUR lors de l\'initialisation : $e');
    print('ERREUR : L\'initialisation de OneSignal a échoué. Veuillez vérifier la configuration de votre domaine sur le tableau de bord OneSignal. Erreur: $e');
  }
}

Future<void> promptForPushNotificationsFromService() async {
  debugPrint('[OneSignal] Demande explicite de permission de notification...');
  if (!_isAllowedHostname()) {
    debugPrint('[OneSignal] Domaine non autorisé pour la demande de permission.');
    return;
  }
  await _waitForOneSignal();
  debugPrint('[OneSignal] Appel à OneSignal.Notifications.requestPermission()');
  await _OneSignal.Notifications.requestPermission();
}

Future<String?> getPlayerIdFromService() async {
  debugPrint('[OneSignal] Démarrage de la récupération du Player ID...');
  if (!_isAllowedHostname()) {
    debugPrint('[OneSignal] Domaine non autorisé pour Player ID.');
    return null;
  }
  await _waitForOneSignal();

  // Vérification de la permission de notification
  final permission = window.Notification?.permission;
  debugPrint('[OneSignal] Permission de notification actuelle : $permission');
  if (permission == null) {
    debugPrint('[OneSignal] Notification API non supportée.');
  } else if (permission == 'denied') {
    debugPrint('[OneSignal] Permission refusée par l\'utilisateur.');
  } else if (permission == 'default') {
    debugPrint('[OneSignal] Permission pas encore demandée ou ignorée.');
  } else if (permission == 'granted') {
    debugPrint('[OneSignal] Permission accordée.');
  }

  // Attendre jusqu'à 20 secondes que le Player ID soit généré
  for (int i = 0; i < 100; i++) {
    final pushSub = _OneSignal.User.pushSubscription;
    final id = pushSub?.id;
    debugPrint('[OneSignal] Tentative $i : Player ID = $id');
    if (id != null && id.isNotEmpty) {
      debugPrint('✅ DEBUG: Player ID OneSignal trouvé = $id');
      return id;
    }
    if (i < 20) {
      debugPrint('⏳ DEBUG: Attente du Player ID... (essai ${i + 1})');
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }
  debugPrint('❌ DEBUG: Player ID OneSignal toujours null après 20 secondes.');
  return null;
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
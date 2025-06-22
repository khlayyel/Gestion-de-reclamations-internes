import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:js/js.dart';
import 'dart:html'; // Pour accéder à window.location

@JS()
library onesignal_web;

// Crée une "vue" de l'objet JavaScript OneSignal.User.pushSubscription
@JS('OneSignal.User.pushSubscription')
@staticInterop
class PushSubscription {}

// Ajoute des méthodes "Dart" à notre vue de l'objet JS
extension PushSubscriptionExtension on PushSubscription {
  // Permet d'accéder à la propriété 'id' de l'objet JS
  @JS('id')
  external JSString? get id;
}

// Récupère l'objet OneSignal.User.pushSubscription.
// Il sera null si l'utilisateur n'est pas abonné.
@JS('OneSignal.User.pushSubscription')
external PushSubscription? get pushSubscription;

// Appelle la fonction OneSignalDeferred.push pour s'assurer que le SDK est prêt
@JS('OneSignalDeferred.push')
external void _oneSignalPush(JSFunction func);

// --- Définitions pour l'interop JS avec le SDK OneSignal ---

@JS('OneSignal')
class OneSignal {
  external static void push(dynamic item);
  external static void init(InitOptions options);
  external static Future<String> getPlayerId();
  // Ajout de la fonction pour afficher la demande de permission
  external static Future<void> showSlidedownPrompt();
}

@JS()
@anonymous
class InitOptions {
  external factory InitOptions({
    required String appId,
    required bool allowLocalhostAsSecureOrigin,
  });
}

// --- Fonctions du service ---

/// Initialise le SDK OneSignal (appelé depuis main.dart)
Future<void> initNotificationService() async {
  final hostname = window.location.hostname;

  // On n'initialise OneSignal que sur le domaine de production ou en local.
  if (hostname != 'reclamations-internes.vercel.app' && hostname != 'localhost') {
    print('Initialisation de OneSignal ignorée pour le domaine : $hostname');
    return;
  }

  await _waitForOneSignal();
  
  OneSignal.push(allowInterop((_) {
    OneSignal.init(InitOptions(
      appId: '109a25e1-389f-4f6b-a279-813a36f735c0', // Votre App ID OneSignal
      allowLocalhostAsSecureOrigin: true,
    ));
  }));
}

/// Affiche la demande de permission à l'utilisateur
Future<void> promptForPushNotifications() async {
  final hostname = window.location.hostname;
  if (hostname != 'reclamations-internes.vercel.app' && hostname != 'localhost') {
    return; // Ne fait rien si on n'est pas sur le bon domaine
  }
  await _waitForOneSignal();
  await OneSignal.showSlidedownPrompt();
}

/// Récupère le Player ID (uniquement si l'utilisateur a donné son accord)
Future<String?> getPlayerIdFromService() async {
  final hostname = window.location.hostname;
  if (hostname != 'reclamations-internes.vercel.app' && hostname != 'localhost') {
    return null;
  }

  await _waitForOneSignal();
  return await OneSignal.getPlayerId();
}

// --- Fonctions utilitaires ---

/// Attend que l'objet OneSignal soit chargé sur la page
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

class NotificationService {
  static bool _isInitialized = false;

  /// Attend que le SDK OneSignal soit chargé et prêt.
  static Future<void> init() async {
    if (_isInitialized) return;
    final completer = Completer<void>();
    _oneSignalPush(() {
      _isInitialized = true;
      completer.complete();
    }.toJS);
    return completer.future;
  }

  /// Récupère le Player ID de manière sécurisée.
  static Future<String?> getPlayerId() async {
    await init();
    
    // Récupère l'objet d'abonnement.
    final subscription = pushSubscription;

    // Si l'objet est null, l'utilisateur n'est pas abonné, on retourne null sans planter.
    if (subscription == null) {
      print('OneSignal: User is not subscribed to push notifications.');
      return null;
    }

    // Sinon, on retourne l'ID.
    return subscription.id?.toDart;
  }
} 
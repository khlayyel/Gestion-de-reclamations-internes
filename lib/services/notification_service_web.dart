import 'dart:async';
import 'dart:js_interop';

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
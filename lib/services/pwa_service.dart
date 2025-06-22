import 'package:flutter/foundation.dart';
import 'package:js/js.dart';

// Service pour gérer l'installation de la PWA (Progressive Web App)

// On déclare une interface pour l'événement `beforeinstallprompt` du navigateur
@JS()
@anonymous
class BeforeInstallPromptEvent {
  external void prompt();
}

// Classe statique pour gérer la logique PWA
class PwaService {
  static BeforeInstallPromptEvent? _installPromptEvent;

  // Notifier pour que l'UI puisse réagir aux changements
  static final ValueNotifier<bool> canBeInstalled = ValueNotifier(false);

  /// Initialise le service. Doit être appelé au démarrage de l'application.
  static void init() {
    // On s'assure de n'exécuter ce code que sur le web
    if (kIsWeb) {
      // On écoute l'événement 'beforeinstallprompt'
      _listenForInstallPrompt();
    }
  }

  /// Déclenche la popup d'installation du navigateur.
  static void install() {
    if (_installPromptEvent != null) {
      _installPromptEvent!.prompt();
    }
  }

  @JS('window.addEventListener')
  external static void _addEventListener(String type, Function callback);

  // Méthode privée pour écouter l'événement
  static void _listenForInstallPrompt() {
    _addEventListener('beforeinstallprompt', allowInterop((event) {
      // Le navigateur nous empêche d'afficher la popup par défaut
      event.preventDefault(); 
      // On sauvegarde l'événement pour l'utiliser plus tard
      _installPromptEvent = event as BeforeInstallPromptEvent;
      // On notifie l'UI que le bouton peut être affiché
      canBeInstalled.value = true;
    }));
  }
} 
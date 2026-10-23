import 'dart:js_interop';

/// Définie dans web/index.html : ouvre la fenêtre « Installer l'application ».
@JS('doktaInstall.open')
external void doktaInstallOpen();

void openInstallPrompt() {
  try {
    doktaInstallOpen();
  } catch (_) {}
}

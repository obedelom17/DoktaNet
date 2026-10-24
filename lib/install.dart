import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'i18n.dart';

/// Définies dans web/index.html (objet window.doktaInstall).
@JS('doktaInstall.open')
external void doktaInstallOpen();

@JS('doktaInstall.canInstall')
external JSBoolean doktaCanInstall();

/// Ouvre la fenêtre « Installer l'application ».
void openInstallPrompt() {
  try {
    doktaInstallOpen();
  } catch (_) {}
}

/// true si le navigateur peut installer l'application et qu'elle ne l'est pas déjà.
bool installAvailable() {
  try {
    return doktaCanInstall().toDart;
  } catch (_) {
    return false;
  }
}

/// Bouton « Installer l'application » toujours disponible (même après avoir fermé la fenêtre).
/// Il disparaît tout seul une fois l'application installée.
class InstallButton extends StatefulWidget {
  final bool onDark;
  const InstallButton({super.key, this.onDark = true});
  @override
  State<InstallButton> createState() => _InstallButtonState();
}

class _InstallButtonState extends State<InstallButton> {
  Timer? _t;
  bool _can = false;

  @override
  void initState() {
    super.initState();
    _check();
    _t = Timer.periodic(const Duration(seconds: 2), (_) => _check());
  }

  void _check() {
    final v = installAvailable();
    if (v != _can && mounted) setState(() => _can = v);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_can) return const SizedBox.shrink();
    final wide = MediaQuery.of(context).size.width >= 900;
    final fg = widget.onDark ? Colors.white : const Color(0xFF0E5976);
    final bg = widget.onDark ? Colors.white.withOpacity(0.14) : const Color(0xFF0E5976).withOpacity(0.10);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: wide
          ? TextButton.icon(
              onPressed: openInstallPrompt,
              icon: Icon(Icons.install_desktop_rounded, size: 20, color: fg),
              label: Text(tr("Installer l'application"), style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
              style: TextButton.styleFrom(
                backgroundColor: bg,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            )
          : IconButton(
              tooltip: tr("Installer l'application"),
              onPressed: openInstallPrompt,
              style: IconButton.styleFrom(backgroundColor: bg),
              icon: Icon(Icons.install_mobile_rounded, color: fg),
            ),
    );
  }
}

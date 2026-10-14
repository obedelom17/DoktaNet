import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'common.dart';
import 'i18n.dart';
import 'screens/account.dart';
import 'screens/admin.dart';
import 'screens/auth.dart';
import 'screens/doctor.dart';
import 'screens/patient.dart';
import 'screens/pharmacy.dart';
import 'session.dart';
import 'theme.dart';

void main() => runApp(const DoktaNetApp());

class DoktaNetApp extends StatefulWidget {
  const DoktaNetApp({super.key});
  @override
  State<DoktaNetApp> createState() => _DoktaNetAppState();
}

class _DoktaNetAppState extends State<DoktaNetApp> {
  @override
  void initState() {
    super.initState();
    l10n.addListener(_onLang);
    l10n.load().then((_) {
      if (mounted) setState(() {});
    });
    session.init();
  }

  @override
  void dispose() {
    l10n.removeListener(_onLang);
    super.dispose();
  }

  /// Changement de langue : on reconstruit tout l'arbre (sans perdre les saisies,
  /// le chat ni les écrans ouverts) pour que chaque texte soit retraduit.
  void _onLang() {
    if (!mounted) return;
    setState(() {});
    void rebuild(Element e) {
      e.markNeedsBuild();
      e.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'DoktaNet',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: Locale(l10n.lang),
        supportedLocales: const [Locale('fr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: ListenableBuilder(
          listenable: session,
          builder: (context, _) {
            Widget page;
            if (session.loading) {
              page = const _Splash();
            } else {
              final u = session.user;
              if (u == null) {
                page = const AuthScreen();
              } else {
                final role = u['role'];
                if ((role == 'doctor' || role == 'pharmacy') && u['status'] != 'active') {
                  page = PendingScreen(status: '${u['status']}');
                } else if (u['require_2fa'] == true) {
                  page = const AccountPage(forced: true);
                } else {
                  switch (role) {
                    case 'doctor':
                      page = const DoctorHome();
                      break;
                    case 'pharmacy':
                      page = const PharmacyHome();
                      break;
                    case 'admin':
                      page = const AdminHome();
                      break;
                    default:
                      page = const PatientHome();
                  }
                }
              }
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.easeOut,
              child: KeyedSubtree(key: ValueKey(page.runtimeType), child: page),
            );
          },
        ),
      );
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => Scaffold(
        body: AnimatedBackdrop(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (context, v, child) => Transform.scale(scale: v, child: child),
                child: const LogoMark(size: 84),
              ),
              const SizedBox(height: 20),
              const Text('DoktaNet',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 18),
              const SizedBox(width: 130, height: 4, child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: LinearProgressIndicator(color: cAccent, backgroundColor: Color(0x33FFFFFF)),
              )),
            ]),
          ),
        ),
      );
}

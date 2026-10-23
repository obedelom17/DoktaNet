import 'dart:async';
import 'package:flutter/material.dart';
import 'common.dart';
import 'i18n.dart';
import 'theme.dart';

/// Photo de l'interface : deux tailles (s = mobile, l = grand écran) et deux cadrages
/// (narrow = zone haute/étroite, wide = bandeau large), pour garder les visages visibles.
class DkPhoto {
  final String name;
  final Alignment narrow;
  final Alignment wide;
  const DkPhoto(this.name, this.narrow, this.wide);
  String path(bool large) => 'assets/photos/${name}_${large ? 'l' : 's'}.jpg';
}

class Photos {
  static const team = DkPhoto('team', Alignment(0.0, -0.4), Alignment(0.0, -0.55));
  static const pharmacy = DkPhoto('pharmacy', Alignment(0.7, -0.3), Alignment(0.3, -0.55));
  static const consult = DkPhoto('consult', Alignment(0.2, -0.4), Alignment(0.1, -0.55));
  static const doctor = DkPhoto('doctor', Alignment(0.5, -0.4), Alignment(0.0, -0.6));
  static const slides = [team, consult, pharmacy, doctor];
}

bool _useLarge(Size s) => s.width > 700 || s.height > 700;

/// Image plein cadre (BoxFit.cover) avec fondu à l'affichage et choix automatique de la taille.
class DkImage extends StatelessWidget {
  final DkPhoto photo;
  const DkImage(this.photo, {super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final screen = MediaQuery.of(context).size;
        final w = box.maxWidth.isFinite ? box.maxWidth : screen.width;
        final h = box.maxHeight.isFinite ? box.maxHeight : screen.height;
        final ratio = w / h;
        final a = ratio < 1.2 ? photo.narrow : (ratio > 3 ? Alignment(photo.wide.x, -0.95) : photo.wide);
        return Image.asset(
          photo.path(w > 700 || h > 700),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: a,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          frameBuilder: (context, child, frame, sync) => sync
              ? child
              : AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: child,
                ),
        );
      });
}

/// Fond d'écran photo (diaporama en fondu) avec voile bleu, pour la page de connexion.
class PhotoBackdrop extends StatefulWidget {
  final Widget child;
  final List<DkPhoto> photos;
  final double overlay;
  const PhotoBackdrop({super.key, required this.child, this.photos = Photos.slides, this.overlay = 0.75});
  @override
  State<PhotoBackdrop> createState() => _PhotoBackdropState();
}

class _PhotoBackdropState extends State<PhotoBackdrop> {
  Timer? _t;
  int _i = 0;

  @override
  void initState() {
    super.initState();
    if (widget.photos.length > 1) {
      _t = Timer.periodic(const Duration(seconds: 7), (_) {
        if (mounted) setState(() => _i = (_i + 1) % widget.photos.length);
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        final large = _useLarge(MediaQuery.of(context).size);
        for (final p in widget.photos.skip(1)) {
          precacheImage(AssetImage(p.path(large)), context);
        }
      });
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(gradient: kHeroGradient),
        child: Stack(children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1400),
              child: SizedBox.expand(key: ValueKey(_i), child: DkImage(widget.photos[_i])),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cDark.withOpacity(widget.overlay * 0.55),
                    cDark.withOpacity(widget.overlay),
                    const Color(0xFF062B3C).withOpacity(0.95),
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
          widget.child,
        ]),
      );
}

/// Panneau translucide posé sur la photo (style « verre »).
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GlassPanel({super.key, required this.child, this.padding = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.28)),
        ),
        child: child,
      );
}

/// Bouton arrondi posé sur la photo : plein (corail) ou contour clair.
class HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  const HeroPill({super.key, required this.icon, required this.label, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) => Material(
        color: filled ? cAccent : Colors.white.withOpacity(0.16),
        shape: StadiumBorder(side: filled ? BorderSide.none : BorderSide(color: Colors.white.withOpacity(0.55))),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            ]),
          ),
        ),
      );
}

/// En-tête d'accueil : photo + voile + salutation + boutons + panneau d'information.
/// Mobile : pleine largeur, coins bas arrondis. Grand écran : carte arrondie, texte à gauche, photo à droite.
class PhotoHero extends StatelessWidget {
  final DkPhoto photo;
  final String kicker;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? panel;
  const PhotoHero({
    super.key,
    required this.photo,
    required this.kicker,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.panel,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 700;
        final content = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: wide ? 4 : 150),
          Text(kicker, style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.88))),
          const SizedBox(height: 2),
          Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: wide ? 34 : 30, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(subtitle!, style: TextStyle(fontSize: 15.5, height: 1.3, color: Colors.white.withOpacity(0.88))),
            ),
          if (actions.isNotEmpty)
            Padding(padding: const EdgeInsets.only(top: 16), child: Wrap(spacing: 8, runSpacing: 8, children: actions)),
          if (panel != null) Padding(padding: const EdgeInsets.only(top: 16), child: panel!),
        ]);
        return Padding(
          padding: wide ? const EdgeInsets.fromLTRB(16, 16, 16, 8) : EdgeInsets.zero,
          child: Reveal(
            child: ClipRRect(
              borderRadius: wide ? BorderRadius.circular(28) : const BorderRadius.vertical(bottom: Radius.circular(32)),
              child: DecoratedBox(
                decoration: BoxDecoration(color: wide ? null : cDark, gradient: wide ? kHeroGradient : null),
                child: Stack(children: [
                  // Mobile : photo en haut (300 px) qui se fond dans le bleu ; grand écran : photo plein cadre.
                  if (wide)
                    Positioned.fill(child: DkImage(photo))
                  else
                    Positioned(top: 0, left: 0, right: 0, height: 300, child: DkImage(photo)),
                  if (wide)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [cDark.withOpacity(0.94), cDark.withOpacity(0.62), cDark.withOpacity(0.04)],
                            stops: const [0, 0.52, 1],
                          ),
                        ),
                      ),
                    )
                  else
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 312,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [cDark.withOpacity(0.05), cDark.withOpacity(0.35), cDark],
                            stops: const [0, 0.45, 1],
                          ),
                        ),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: wide ? 290 : 0),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(wide ? 32 : 20, wide ? 26 : 16, wide ? 32 : 20, wide ? 26 : 24),
                      child: wide
                          ? Row(children: [Expanded(flex: 6, child: content), const Spacer(flex: 4)])
                          : content,
                    ),
                  ),
                ]),
              ),
            ),
          ),
        );
      });
}

/// Bandeau photo plus court pour les sections (Médecins, Pharmacies).
class PhotoBanner extends StatelessWidget {
  final DkPhoto photo;
  final String title;
  final String subtitle;
  const PhotoBanner({super.key, required this.photo, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 700;
        return Padding(
          padding: wide ? const EdgeInsets.fromLTRB(16, 16, 16, 0) : EdgeInsets.zero,
          child: Reveal(
            child: ClipRRect(
              borderRadius: wide ? BorderRadius.circular(24) : const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: SizedBox(
                height: wide ? 150 : 138,
                child: Stack(children: [
                  Positioned.fill(child: DkImage(photo)),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: wide
                            ? LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [cDark.withOpacity(0.92), cDark.withOpacity(0.55), cDark.withOpacity(0.04)],
                                stops: const [0, 0.55, 1],
                              )
                            : LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [cDark.withOpacity(0.1), cDark.withOpacity(0.9)],
                              ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: wide ? Alignment.centerLeft : Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 3),
                          Text(subtitle, style: TextStyle(fontSize: 14, height: 1.25, color: Colors.white.withOpacity(0.88))),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        );
      });
}

/// Page avec photo en tête (pleine largeur sur mobile), puis contenu avec marges.
class HeroList extends StatelessWidget {
  final Widget hero;
  final List<Widget> children;
  const HeroList({super.key, required this.hero, required this.children});

  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          hero,
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ],
      );
}

/// Panneau « prochain rendez-vous » affiché sur la photo d'accueil (patient ou médecin).
Widget nextApptPanel(List appts, {required bool forDoctor}) {
  final open = appts.where((a) => a['status'] == 'scheduled' || a['status'] == 'in_progress').toList();
  open.sort((a, b) => '${a['starts_at']}'.compareTo('${b['starts_at']}'));
  final limit = DateTime.now().subtract(const Duration(hours: 2));
  dynamic next;
  for (final a in open) {
    if (DateTime.parse('${a['starts_at']}').isAfter(limit)) {
      next = a;
      break;
    }
  }
  next ??= open.isEmpty ? null : open.first;
  if (next == null) {
    return GlassPanel(
      child: Row(children: [
        const Icon(Icons.event_available_rounded, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(tr("Aucun rendez-vous à venir."), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
  final who = forDoctor ? '${next['patient_name']}' : 'Dr ${next['doctor_name']}';
  return GlassPanel(
    child: Row(children: [
      const Icon(Icons.event_rounded, color: Colors.white),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(tr("Prochain rendez-vous"), style: TextStyle(color: Colors.white.withOpacity(0.78), fontSize: 12.5)),
          Text(who, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16.5)),
          Text(fmtDt(next['starts_at']), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
        ]),
      ),
    ]),
  );
}

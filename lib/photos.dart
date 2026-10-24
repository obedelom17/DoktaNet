import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'common.dart';
import 'i18n.dart';
import 'pattern.dart';
import 'theme.dart';

/// Photo de l'interface : deux tailles (s = mobile, l = grand écran) et deux cadrages
/// (narrow = zone haute/étroite, wide = bandeau large), pour garder les visages visibles.
class DkPhoto {
  final String name;
  final Alignment narrow;
  final Alignment wide;
  /// Hauteur (0 à 1) du centre des visages dans l'image : sert à cadrer les bandeaux très larges.
  final double faceY;
  /// Abscisse (0 à 1) du centre des visages.
  final double faceX;
  /// Zoom conseillé sur les visages dans les bandeaux de mobile.
  final double zoom;
  const DkPhoto(this.name, this.narrow, this.wide, this.faceX, this.faceY, this.zoom);
  String _p(String tier) => 'assets/photos/${name}_$tier.jpg';
  /// s = mobile (720 px), l = 1280 px, xl = résolution d'origine (grands écrans).
  String pathFor(double w, double h) => (w > 1300 || h > 1000) ? _p('xl') : ((w > 700 || h > 700) ? _p('l') : _p('s'));
}

class Photos {
  static const team = DkPhoto('team', Alignment(0.0, -0.4), Alignment(0.0, -0.55), 0.50, 0.27, 1.3);
  static const pharmacy = DkPhoto('pharmacy', Alignment(0.7, -0.3), Alignment(0.3, -0.55), 0.66, 0.30, 1.8);
  static const consult = DkPhoto('consult', Alignment(0.2, -0.4), Alignment(0.1, -0.55), 0.55, 0.30, 1.8);
  static const doctor = DkPhoto('doctor', Alignment(0.5, -0.4), Alignment(0.0, -0.6), 0.50, 0.28, 1.5);
  static const slides = [team, consult, pharmacy, doctor];
}

/// Image plein cadre (BoxFit.cover) avec fondu à l'affichage et choix automatique de la taille.
class DkImage extends StatelessWidget {
  final DkPhoto photo;
  /// > 1 : agrandit l'image en gardant les visages en place (utile sur mobile).
  final double zoom;
  const DkImage(this.photo, {super.key, this.zoom = 1.0});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final screen = MediaQuery.of(context).size;
        final w = box.maxWidth.isFinite ? box.maxWidth : screen.width;
        final h = box.maxHeight.isFinite ? box.maxHeight : screen.height;
        final ratio = w / h;
        const imgRatio = 16 / 9;
        Alignment a;
        if (ratio < 1.2) {
          a = photo.narrow;
        } else if (ratio > imgRatio) {
          // Cadre plus large que l'image : on centre verticalement la fenêtre sur les visages.
          final sh = w / imgRatio;
          final slack = sh - h;
          final y = slack <= 0 ? 0.0 : (((photo.faceY * sh) - h / 2) / slack * 2 - 1).clamp(-1.0, 1.0).toDouble();
          a = Alignment(photo.wide.x, y);
        } else {
          a = photo.wide;
        }
        final z = zoom < 1 ? 1.0 : zoom;
        Widget img = Image.asset(
          photo.pathFor(w * z, h * z),
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
        if (z > 1.0) {
          const ir = 16 / 9;
          final s = math.max(w / ir, h); // hauteur affichée de l'image (BoxFit.cover)
          final sw = s * ir;
          final fx = (w - sw) * (a.x + 1) / 2 + photo.faceX * sw;
          final fy = (h - s) * (a.y + 1) / 2 + photo.faceY * s;
          img = Transform.scale(
            scale: z,
            alignment: Alignment(((fx / w) * 2 - 1).clamp(-1.0, 1.0).toDouble(), ((fy / h) * 2 - 1).clamp(-1.0, 1.0).toDouble()),
            child: img,
          );
        }
        return img;
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
  Size? _box;

  @override
  void initState() {
    super.initState();
    if (widget.photos.length > 1) {
      _t = Timer.periodic(const Duration(seconds: 7), (_) {
        if (mounted) setState(() => _i = (_i + 1) % widget.photos.length);
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        final size = _box ?? MediaQuery.of(context).size;
        for (final p in widget.photos.skip(1)) {
          precacheImage(AssetImage(p.pathFor(size.width, size.height)), context);
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
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        _box = Size(box.maxWidth, box.maxHeight);
        return _stack();
      });

  Widget _stack() => DecoratedBox(
        decoration: const BoxDecoration(gradient: kHeroGradient),
        child: Stack(children: [
          if ((_box?.width ?? 1000) < 700 && (_box?.height ?? 0) > (_box?.width ?? 0))
            // Mobile portrait : photo moins zoomee (bande en haut), fondue vers le fond.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: math.min(_box!.height * 0.62, _box!.width * 1.25),
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.black, Colors.transparent],
                  stops: [0, 0.7, 1],
                ).createShader(r),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1400),
                  child: SizedBox.expand(key: ValueKey(_i), child: DkImage(widget.photos[_i])),
                ),
              ),
            )
          else
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
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(child: CustomPaint(painter: WaxPainter(color: Colors.white, opacity: 0.05, cell: 140))),
            ),
          ),
          const Positioned(top: 0, left: 0, right: 0, child: KenteBar()),
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
          SizedBox(height: wide ? 4 : 110),
          Text(kicker, style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.88))),
          const SizedBox(height: 2),
          Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: wide ? 40 : 30, fontWeight: FontWeight.w800, color: Colors.white, height: 1.08)),
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
          padding: EdgeInsets.zero,
          child: Reveal(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
              child: DecoratedBox(
                decoration: BoxDecoration(color: wide ? null : cDark, gradient: wide ? kHeroGradient : null),
                child: Stack(children: [
                  // Mobile : photo en haut (300 px) qui se fond dans le bleu ; grand écran : photo plein cadre.
                  if (wide)
                    Positioned.fill(child: DkImage(photo))
                  else
                    Positioned(top: 0, left: 0, right: 0, height: 300, child: ClipRect(child: DkImage(photo, zoom: 1 + (photo.zoom - 1) * 0.5))),
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
                      height: 301,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [cDark.withOpacity(0.05), cDark.withOpacity(0.55), cDark, cDark],
                            stops: const [0, 0.4, 0.85, 1],
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(painter: WaxRingsPainter(anchor: Alignment.bottomRight, maxRadius: wide ? 380 : 250)),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: wide ? (box.maxWidth * 0.30).clamp(340.0, 480.0).toDouble() : 0),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(wide ? 32 : 20, wide ? 26 : 16, wide ? 32 : 20, wide ? 26 : 24),
                      child: wide
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: content),
                            )
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
          padding: EdgeInsets.zero,
          child: Reveal(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              child: SizedBox(
                height: wide ? (box.maxWidth * 0.26).clamp(240.0, 420.0).toDouble() : 210,
                child: Stack(children: [
                  Positioned.fill(child: DkImage(photo, zoom: wide ? 1.0 : photo.zoom)),
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
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(painter: WaxRingsPainter(anchor: wide ? Alignment.bottomLeft : Alignment.bottomRight, maxRadius: 260)),
                    ),
                  ),
                  Align(
                    alignment: wide ? Alignment.centerLeft : Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(title, style: TextStyle(fontSize: wide ? 34 : 24, fontWeight: FontWeight.w800, color: Colors.white)),
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
            padding: EdgeInsets.fromLTRB(hPad(context), 8, hPad(context), 24),
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

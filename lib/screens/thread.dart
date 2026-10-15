import 'dart:async';
import 'package:flutter/material.dart';
import '../api.dart';
import '../common.dart';
import '../i18n.dart';
import '../session.dart';
import '../theme.dart';

/// Messagerie sécurisée patient <-> médecin, rattachée à un rendez-vous (rafraîchie toutes les 4 s).
class ThreadPage extends StatefulWidget {
  final String apptId;
  final String title;
  const ThreadPage({super.key, required this.apptId, required this.title});
  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final msgs = <Map<String, dynamic>>[];
  int last = 0;
  bool sending = false;
  Timer? timer;

  String get me => '${session.user?['id']}';

  @override
  void initState() {
    super.initState();
    _poll();
    timer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
  }

  @override
  void dispose() {
    timer?.cancel();
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  void _down() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.jumpTo(scroll.position.maxScrollExtent);
    });
  }

  Future<void> _poll() async {
    try {
      final r = (await Api.get('/appointments/${widget.apptId}/messages', {'after': '$last'})) as List;
      if (r.isEmpty || !mounted) return;
      for (final m in r) {
        msgs.add(Map<String, dynamic>.from(m as Map));
        last = int.parse('${m['id']}');
      }
      setState(() {});
      _down();
    } catch (_) {}
  }

  Future<void> _send() async {
    final t = input.text.trim();
    if (t.isEmpty || sending) return;
    setState(() => sending = true);
    await guard(context, () async {
      await Api.post('/appointments/${widget.apptId}/messages', {'content': t});
      input.clear();
      await _poll();
    });
    if (mounted) setState(() => sending = false);
  }

  Widget _bubble(Map<String, dynamic> m) {
    final mine = '${m['sender_id']}' == me;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mine ? cMid : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: mine ? null : Border.all(color: Colors.black12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!mine) Text('${m['sender_name']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: cMid)),
          SelectableText('${m['content']}', style: TextStyle(color: mine ? Colors.white : cInk)),
          const SizedBox(height: 2),
          Text(fmtHm(m['created_at']), style: TextStyle(fontSize: 11, color: mine ? Colors.white70 : cMuted)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: gradientAppBar(widget.title),
        body: pageWrap(
          Column(children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFFFEDE8),
              padding: const EdgeInsets.all(10),
              child: Text(
                tr("Messagerie sécurisée entre patient et médecin. En cas d'urgence, rendez-vous à l'hôpital le plus proche."),
                style: const TextStyle(fontSize: 13, color: Color(0xFF8A2F1C)),
              ),
            ),
            Expanded(
              child: ListView(controller: scroll, padding: const EdgeInsets.all(16), children: [for (final m in msgs) _bubble(m)]),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(hintText: tr("Écrire un message")),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: sending ? null : _send, icon: const Icon(Icons.send_rounded)),
              ]),
            ),
          ]),
        ),
      );
}

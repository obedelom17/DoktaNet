import 'package:flutter/material.dart';
import '../api.dart';
import '../common.dart';
import '../i18n.dart';
import '../session.dart';
import '../theme.dart';
import 'chat.dart';

class PharmacyHome extends StatelessWidget {
  const PharmacyHome({super.key});
  @override
  Widget build(BuildContext context) => const Shell(title: "Pharmacie", tabs: [
        TabDef("Commandes", Icons.receipt_long_outlined, _Orders()),
        TabDef("Stock", Icons.inventory_2_outlined, _Stock()),
        TabDef("Assistant", Icons.smart_toy_outlined, ChatPage()),
        TabDef("Profil", Icons.storefront_outlined, _PharmacyProfile()),
      ]);
}

class _Orders extends StatelessWidget {
  const _Orders();

  Future<void> _advice(BuildContext context, dynamic o, VoidCallback reload) async {
    final ctl = TextEditingController(text: '${o['advice'] ?? ''}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(tr("Conseil de prise")),
        content: SizedBox(width: 400, child: TextField(controller: ctl, minLines: 3, maxLines: 6)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(tr("Annuler"))),
          ElevatedButton(onPressed: () => Navigator.pop(d, true), child: Text(tr("Envoyer"))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await guard(context, () async {
      await Api.post('/orders/${o['id']}/advice', {'text': ctl.text});
      reload();
    });
  }

  Widget _btn(BuildContext c, dynamic o, String label, String status, IconData icon, VoidCallback reload) =>
      ElevatedButton.icon(
        icon: Icon(icon),
        onPressed: () => guard(c, () async {
          await Api.post('/orders/${o['id']}/status', {'status': status});
          reload();
        }),
        label: Text(tr(label)),
      );

  Widget _card(BuildContext c, dynamic o, int i, VoidCallback reload) => AppCard(
        index: i,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            InitialsAvatar('${o['patient_name']}'),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${o['patient_name']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: cDark)),
                Text(tr("Ordonnance {c}", {'c': o['code']}), style: const TextStyle(color: cMuted)),
              ]),
            ),
            chip('${o['status']}'),
          ]),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: cBg, borderRadius: BorderRadius.circular(14)),
            child: Text(itemsText(o['items']), style: const TextStyle(height: 1.4)),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Text('${o['total']} FCFA  ', style: const TextStyle(fontWeight: FontWeight.w800, color: cDark)),
            chip('${o['payment_status']}'),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.description_outlined),
              onPressed: () => openPrint('${o['prescription_id']}'),
              label: Text(tr("Voir ordonnance")),
            ),
            if (o['status'] == 'sent') _btn(c, o, "Valider et préparer", 'preparing', Icons.inventory_rounded, reload),
            if (o['status'] == 'preparing') _btn(c, o, "Prête", 'ready', Icons.check_circle_outline, reload),
            if (o['status'] == 'ready') _btn(c, o, "Délivrée", 'delivered', Icons.local_shipping_outlined, reload),
            if (o['status'] == 'sent' || o['status'] == 'preparing')
              OutlinedButton(
                onPressed: () => guard(c, () async {
                  await Api.post('/orders/${o['id']}/status', {'status': 'cancelled'});
                  reload();
                }),
                child: Text(tr("Refuser")),
              ),
            OutlinedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              onPressed: () => _advice(c, o, reload),
              label: Text(tr("Conseil")),
            ),
          ]),
        ]),
      );

  @override
  Widget build(BuildContext context) => Load<List<dynamic>>(
        load: () async => (await Api.get('/orders')) as List,
        builder: (c, orders, reload) => RefreshIndicator(
          onRefresh: () async => reload(),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            HeroBanner(
              title: tr("Pharmacie connectée"),
              subtitle: tr("{n} commande(s) dans votre file.", {'n': orders.length}),
              trailing: const Padding(padding: EdgeInsets.only(left: 12), child: PulseDot()),
            ),
            sectionTitle("File des ordonnances", icon: Icons.receipt_long_rounded),
            if (orders.isEmpty) const Empty("Aucune commande reçue.", icon: Icons.inbox_outlined),
            for (var i = 0; i < orders.length; i++) _card(c, orders[i], i, reload),
            const SizedBox(height: 20),
          ]),
        ),
      );
}

class _Stock extends StatelessWidget {
  const _Stock();

  Future<void> _edit(BuildContext context, dynamic item, VoidCallback reload) async {
    final name = TextEditingController(text: item == null ? '' : '${item['name']}');
    final qty = TextEditingController(text: item == null ? '' : '${item['quantity']}');
    final price = TextEditingController(text: item == null ? '' : '${item['price']}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(item == null ? tr("Ajouter un médicament") : tr("Modifier")),
        content: SizedBox(
          width: 400,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            tf(name, "Nom"),
            tf(qty, "Quantité", type: TextInputType.number),
            tf(price, "Prix (FCFA)", type: TextInputType.number),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(tr("Annuler"))),
          ElevatedButton(onPressed: () => Navigator.pop(d, true), child: Text(tr("Enregistrer"))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await guard(context, () async {
      await Api.put('/pharmacy/stock', {
        'items': [
          {'name': name.text.trim(), 'quantity': int.tryParse(qty.text.trim()) ?? 0, 'price': int.tryParse(price.text.trim()) ?? 0}
        ]
      });
      reload();
    });
  }

  Future<void> _import(BuildContext context, VoidCallback reload) async {
    final ctl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(tr("Import CSV")),
        content: SizedBox(
          width: 460,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(tr("Collez une ligne par médicament : nom,quantité,prix")),
            const SizedBox(height: 8),
            TextField(controller: ctl, minLines: 8, maxLines: 12, decoration: const InputDecoration(hintText: 'Paracétamol 500mg,120,500')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(tr("Annuler"))),
          ElevatedButton(onPressed: () => Navigator.pop(d, true), child: Text(tr("Importer"))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final items = <Map<String, dynamic>>[];
    for (final line in ctl.text.split('\n')) {
      final p = line.split(RegExp(r'[,;]'));
      if (p.length < 3) continue;
      final q = int.tryParse(p[1].trim());
      final pr = int.tryParse(p[2].trim());
      if (q == null || pr == null || p[0].trim().isEmpty) continue;
      items.add({'name': p[0].trim(), 'quantity': q, 'price': pr});
    }
    if (items.isEmpty) {
      toast(context, tr("Aucune ligne valide"));
      return;
    }
    await guard(context, () async {
      await Api.put('/pharmacy/stock', {'items': items});
      if (context.mounted) toast(context, tr("{n} lignes importées", {'n': items.length}));
      reload();
    });
  }

  @override
  Widget build(BuildContext context) => Load<List<dynamic>>(
        load: () async => (await Api.get('/pharmacy/stock')) as List,
        builder: (c, stock, reload) => ListView(padding: const EdgeInsets.all(16), children: [
          Reveal(
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              ElevatedButton.icon(icon: const Icon(Icons.add_rounded), onPressed: () => _edit(c, null, reload), label: Text(tr("Ajouter"))),
              OutlinedButton.icon(icon: const Icon(Icons.upload_file_rounded), onPressed: () => _import(c, reload), label: Text(tr("Import CSV"))),
            ]),
          ),
          const SizedBox(height: 14),
          if (stock.isEmpty) const Empty("Stock vide.", icon: Icons.inventory_2_outlined),
          for (var i = 0; i < stock.length; i++)
            AppCard(
              index: i,
              onTap: () => _edit(c, stock[i], reload),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                IconBadge(Icons.medication_rounded,
                    gradient: (stock[i]['quantity'] as int) <= 5 ? kGoldGradient : kBrandGradient),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${stock[i]['name']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cDark)),
                    Text(tr("Quantité : {q} - {p} FCFA", {'q': stock[i]['quantity'], 'p': stock[i]['price']}),
                        style: const TextStyle(color: cMuted)),
                  ]),
                ),
                if ((stock[i]['quantity'] as int) <= 5)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFF8A5A00)),
                    const SizedBox(width: 4),
                    Text(tr("Stock faible"), style: const TextStyle(color: Color(0xFF8A5A00), fontWeight: FontWeight.w800)),
                  ]),
              ]),
            ),
          const SizedBox(height: 20),
        ]),
      );
}

class _PharmacyProfile extends StatefulWidget {
  const _PharmacyProfile();
  @override
  State<_PharmacyProfile> createState() => _PharmacyProfileState();
}

class _PharmacyProfileState extends State<_PharmacyProfile> {
  final name = TextEditingController(), city = TextEditingController(), address = TextEditingController();
  final phone = TextEditingController(), lat = TextEditingController(), lng = TextEditingController();
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    name.dispose();
    city.dispose();
    address.dispose();
    phone.dispose();
    lat.dispose();
    lng.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await guard(context, () async {
      final m = await Api.get('/me');
      final p = (m['profile'] ?? {}) as Map;
      name.text = '${p['name'] ?? ''}';
      city.text = '${p['city'] ?? ''}';
      address.text = '${p['address'] ?? ''}';
      phone.text = '${p['phone'] ?? ''}';
      lat.text = p['lat'] == null ? '' : '${p['lat']}';
      lng.text = p['lng'] == null ? '' : '${p['lng']}';
      ready = true;
    });
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) return const SkeletonList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Reveal(
        child: Row(children: [
          const IconBadge(Icons.storefront_rounded, gradient: kGoldGradient, size: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cDark)),
              Text('${session.user?['email'] ?? ''}', style: const TextStyle(color: cMuted)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 18),
      AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          tf(name, "Nom de la pharmacie", icon: Icons.storefront_outlined),
          tf(city, "Ville", icon: Icons.location_city_outlined),
          tf(address, "Adresse", icon: Icons.place_outlined),
          tf(phone, "Téléphone", type: TextInputType.phone, icon: Icons.phone_outlined),
          Row(children: [
            Expanded(child: tf(lat, "Latitude", type: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: tf(lng, "Longitude", type: TextInputType.number)),
          ]),
          PrimaryButton(
            "Enregistrer",
            icon: Icons.save_outlined,
            onPressed: () => guard(context, () async {
              await Api.put('/pharmacy/profile', {
                'name': name.text.trim(),
                'city': city.text.trim(),
                'address': address.text.trim(),
                'phone': phone.text.trim(),
                'lat': lat.text.trim(),
                'lng': lng.text.trim(),
              });
              if (mounted) toast(context, tr("Profil enregistré"));
            }),
          ),
        ]),
      ),
    ]);
  }
}

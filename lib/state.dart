import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

/// Палитра для вещей, добавленных вручную.
const manualPalette = <ColorVariant>[
  ColorVariant('Лагуна', Color(0xFF00B4D8), Color(0xFFFFFFFF), Print.solid),
  ColorVariant('Коралл', Color(0xFFFF6B6B), Color(0xFFFFD166), Print.solid),
  ColorVariant('Мята', Color(0xFF06D6A0), Color(0xFF1B2A41), Print.dots),
  ColorVariant('Солнце', Color(0xFFFFD166), Color(0xFFFF6B6B), Print.stripes),
  ColorVariant('Фиалка', Color(0xFF7B61FF), Color(0xFFFF8FB1), Print.tropic),
  ColorVariant('Ночь', Color(0xFF1B2A41), Color(0xFF00B4D8), Print.waves),
];

const wardrobeTags = <String>['Любимый', 'На отпуск', 'Для бассейна', 'Новый'];

class WardrobeItem {
  final String id;
  final String? swimId;
  final String name;
  final String brand;
  final SwimType type;
  final int variant; // индекс в colors товара или в manualPalette
  final String size;
  final int qty;
  final Set<String> tags;
  final String note;
  final bool archived;
  final DateTime added;

  WardrobeItem({
    required this.id,
    this.swimId,
    required this.name,
    required this.brand,
    required this.type,
    required this.variant,
    required this.size,
    this.qty = 1,
    Set<String>? tags,
    this.note = '',
    this.archived = false,
    DateTime? added,
  })  : tags = tags ?? {},
        added = added ?? DateTime.now();

  ColorVariant get color {
    if (swimId != null) {
      final c = byId(swimId!).colors;
      return c[variant.clamp(0, c.length - 1)];
    }
    return manualPalette[variant.clamp(0, manualPalette.length - 1)];
  }

  WardrobeItem copyWith({int? qty, Set<String>? tags, String? note, bool? archived, String? size}) => WardrobeItem(
        id: id,
        swimId: swimId,
        name: name,
        brand: brand,
        type: type,
        variant: variant,
        size: size ?? this.size,
        qty: qty ?? this.qty,
        tags: tags ?? this.tags,
        note: note ?? this.note,
        archived: archived ?? this.archived,
        added: added,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'swimId': swimId,
        'name': name,
        'brand': brand,
        'type': type.index,
        'variant': variant,
        'size': size,
        'qty': qty,
        'tags': tags.toList(),
        'note': note,
        'archived': archived,
        'added': added.millisecondsSinceEpoch,
      };

  factory WardrobeItem.fromJson(Map<String, dynamic> j) => WardrobeItem(
        id: j['id'] as String,
        swimId: j['swimId'] as String?,
        name: j['name'] as String,
        brand: j['brand'] as String,
        type: SwimType.values[j['type'] as int],
        variant: j['variant'] as int,
        size: j['size'] as String,
        qty: j['qty'] as int,
        tags: (j['tags'] as List).cast<String>().toSet(),
        note: j['note'] as String? ?? '',
        archived: j['archived'] as bool? ?? false,
        added: DateTime.fromMillisecondsSinceEpoch(j['added'] as int),
      );
}

class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  ThemeMode themeMode = ThemeMode.system;
  bool onboarded = false;
  String userName = 'Алина';
  final List<WardrobeItem> wardrobe = [];
  final Set<String> wishlist = {};
  final Set<String> priceAlerts = {};
  final Set<String> favorites = {};
  final Set<String> readNotices = {};

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('state_v2');
    if (raw == null) {
      _seed();
      return;
    }
    final j = jsonDecode(raw) as Map<String, dynamic>;
    themeMode = ThemeMode.values[j['theme'] as int? ?? 0];
    onboarded = j['onboarded'] as bool? ?? false;
    userName = j['name'] as String? ?? userName;
    wardrobe
      ..clear()
      ..addAll((j['wardrobe'] as List).map((e) => WardrobeItem.fromJson(e as Map<String, dynamic>)));
    wishlist.addAll((j['wishlist'] as List).cast<String>());
    priceAlerts.addAll((j['alerts'] as List).cast<String>());
    favorites.addAll((j['favorites'] as List).cast<String>());
    readNotices.addAll((j['read'] as List? ?? const []).cast<String>());
  }

  void _seed() {
    final now = DateTime.now();
    WardrobeItem from(String sid, int variant, String size, Set<String> tags, int daysAgo, {bool archived = false, int qty = 1}) {
      final s = byId(sid);
      return WardrobeItem(
        id: '$sid-$variant',
        swimId: sid,
        name: s.name,
        brand: s.brand,
        type: s.type,
        variant: variant,
        size: size,
        qty: qty,
        tags: tags,
        archived: archived,
        added: now.subtract(Duration(days: daysAgo)),
      );
    }

    wardrobe.addAll([
      from('s6', 0, 'S', {'Любимый', 'На отпуск'}, 3),
      from('s1', 0, 'M', {'Любимый'}, 40),
      from('s11', 0, 'S', {'Для бассейна'}, 75, qty: 2),
      from('s3', 0, 'S', {'На отпуск'}, 12),
      from('s9', 0, 'S', {'Новый', 'На отпуск'}, 1),
      from('s13', 0, 'M', {}, 400, archived: true),
    ]);
    wishlist.addAll(['s2', 's10', 's15', 's5']);
    priceAlerts.addAll(['s2', 's15']);
    favorites.addAll(['s6', 's2', 's15']);
  }

  void _save() {
    _prefs?.setString(
      'state_v2',
      jsonEncode({
        'theme': themeMode.index,
        'onboarded': onboarded,
        'name': userName,
        'wardrobe': wardrobe.map((e) => e.toJson()).toList(),
        'wishlist': wishlist.toList(),
        'alerts': priceAlerts.toList(),
        'favorites': favorites.toList(),
        'read': readNotices.toList(),
      }),
    );
  }

  void _changed() {
    _save();
    notifyListeners();
  }

  // ---------- действия ----------

  void finishOnboarding() {
    onboarded = true;
    _changed();
  }

  void setTheme(ThemeMode m) {
    themeMode = m;
    _changed();
  }

  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    _changed();
  }

  void toggleWish(String id) {
    if (wishlist.remove(id)) {
      priceAlerts.remove(id);
    } else {
      wishlist.add(id);
    }
    _changed();
  }

  void toggleAlert(String id) {
    priceAlerts.contains(id) ? priceAlerts.remove(id) : priceAlerts.add(id);
    _changed();
  }

  bool inWardrobe(String swimId) => wardrobe.any((w) => w.swimId == swimId && !w.archived);

  void addFromCatalog(Swimsuit s, int variant, String size) {
    final idx = wardrobe.indexWhere((w) => w.swimId == s.id && w.variant == variant && w.size == size && !w.archived);
    if (idx >= 0) {
      wardrobe[idx] = wardrobe[idx].copyWith(qty: wardrobe[idx].qty + 1);
    } else {
      wardrobe.insert(
        0,
        WardrobeItem(
          id: '${s.id}-$variant-${DateTime.now().millisecondsSinceEpoch}',
          swimId: s.id,
          name: s.name,
          brand: s.brand,
          type: s.type,
          variant: variant,
          size: size,
          tags: {'Новый'},
        ),
      );
    }
    wishlist.remove(s.id);
    priceAlerts.remove(s.id);
    _changed();
  }

  void addManual({required String name, required String brand, required SwimType type, required int paletteIndex, required String size, required Set<String> tags, required String note}) {
    wardrobe.insert(
      0,
      WardrobeItem(
        id: 'm-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        brand: brand,
        type: type,
        variant: paletteIndex,
        size: size,
        tags: tags,
        note: note,
      ),
    );
    _changed();
  }

  void updateItem(WardrobeItem item) {
    final i = wardrobe.indexWhere((w) => w.id == item.id);
    if (i >= 0) wardrobe[i] = item;
    _changed();
  }

  void removeItem(String id) {
    wardrobe.removeWhere((w) => w.id == id);
    _changed();
  }

  void markNoticesRead() {
    for (var i = 0; i < notices.length; i++) {
      readNotices.add('$i');
    }
    _changed();
  }

  int get unreadNotices => notices.length - readNotices.length;

  List<WardrobeItem> get active => wardrobe.where((w) => !w.archived).toList();

  int get wardrobeCount => active.fold(0, (a, w) => a + w.qty);

  int get wishTotal => wishlist.fold(0, (a, id) => a + byId(id).minPrice);

  String exportCsv() {
    final b = StringBuffer('Название;Бренд;Тип;Цвет;Размер;Кол-во;Теги;Заметка\n');
    for (final w in wardrobe) {
      b.writeln('${w.name};${w.brand};${w.type.single};${w.color.name};${w.size};${w.qty};${w.tags.join(", ")};${w.note}');
    }
    return b.toString();
  }
}

/// Доступ к состоянию из любого виджета.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

String rub(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return '$b руб.';
}

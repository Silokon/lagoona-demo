import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'art.dart';
import 'data.dart';
import 'main.dart';
import 'state.dart';
import 'widgets.dart';

// ======================= Онбординг и вход =======================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;

  static const _slides = [
    ('Весь пляжный гардероб в одном месте', 'Отмечайте, что уже есть, а что пора обновить к отпуску', ['s3', 's1', 's6']),
    ('Каталог купальников от брендов', 'Фильтры по размеру, цвету, посадке и цене', ['s10', 's5', 's2']),
    ('Лучшая цена в один тап', 'Сравниваем магазины и сообщаем, когда цена снизилась', ['s15', 's11', 's9']),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: _toLogin, child: const Text('Пропустить')),
          ),
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => page = i),
              itemBuilder: (_, i) {
                final (title, sub, ids) = _slides[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(children: [
                    Expanded(child: _Collage(ids)),
                    const SizedBox(height: 24),
                    Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(sub, textAlign: TextAlign.center, style: TextStyle(fontSize: 15.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ]),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < _slides.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == page ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(color: i == page ? Brand.lagoon : Brand.lagoon.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(8)),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: last ? _toLogin : () => controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut),
                child: Text(last ? 'Начать' : 'Далее'),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _toLogin() => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
}

class _Collage extends StatelessWidget {
  final List<String> ids;
  const _Collage(this.ids);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) {
        final w = math.min(c.maxWidth, c.maxHeight) * 0.62;
        Widget card(String id, double angle, Offset o) => Transform.translate(
              offset: o,
              child: Transform.rotate(
                angle: angle,
                child: Container(
                  width: w,
                  height: w * 1.15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 12))],
                  ),
                  child: SwimPhoto(byId(id), radius: 28),
                ),
              ),
            );
        return Stack(alignment: Alignment.center, children: [
          card(ids[1], -0.18, Offset(-w * 0.42, w * 0.08)),
          card(ids[2], 0.18, Offset(w * 0.42, w * 0.1)),
          card(ids[0], 0, Offset.zero),
        ]);
      });
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _enter(BuildContext context) {
    AppScope.of(context).finishOnboarding();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const Shell()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget social(Widget icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OutlinedButton(
            onPressed: () => _enter(context),
            child: Row(children: [icon, Expanded(child: Text(text, textAlign: TextAlign.center)), const SizedBox(width: 24)]),
          ),
        );
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(24, 32, 24, 24), children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(gradient: Brand.gradient, borderRadius: BorderRadius.circular(26)),
              child: const Icon(Icons.waves_rounded, color: Colors.white, size: 46),
            ),
          ),
          const SizedBox(height: 18),
          Text('Lagoona', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('Войдите, чтобы гардероб и списки были на всех устройствах', textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 28),
          social(const CircleAvatar(radius: 12, backgroundColor: Color(0xFF4285F4), child: Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13))), 'Продолжить с Google'),
          social(const CircleAvatar(radius: 12, backgroundColor: Color(0xFF0077FF), child: Text('VK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9))), 'Продолжить с VK ID'),
          social(const Icon(Icons.apple, size: 24), 'Продолжить с Apple'),
          const SizedBox(height: 8),
          Row(children: [
            const Expanded(child: Divider()),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('или', style: TextStyle(color: cs.onSurfaceVariant))),
            const Expanded(child: Divider()),
          ]),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.alternate_email_rounded), hintText: 'Email или телефон')),
          const SizedBox(height: 12),
          const TextField(obscureText: true, decoration: InputDecoration(prefixIcon: Icon(Icons.lock_outline_rounded), hintText: 'Пароль', suffixIcon: Icon(Icons.visibility_outlined))),
          const SizedBox(height: 18),
          FilledButton(onPressed: () => _enter(context), child: const Text('Войти')),
          const SizedBox(height: 8),
          TextButton(onPressed: () => _enter(context), child: const Text('Посмотреть без регистрации')),
        ]),
      ),
    );
  }
}

// ======================= Гардероб =======================

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});

  static const _tabs = ['Все', 'Любимые', 'На отпуск', 'Для бассейна', 'Архив'];

  List<WardrobeItem> _filter(AppState st, int tab) => switch (tab) {
        0 => st.active,
        1 => st.active.where((w) => w.tags.contains('Любимый')).toList(),
        2 => st.active.where((w) => w.tags.contains('На отпуск')).toList(),
        3 => st.active.where((w) => w.tags.contains('Для бассейна')).toList(),
        _ => st.wardrobe.where((w) => w.archived).toList(),
      };

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final value = st.active.where((w) => w.swimId != null).fold<int>(0, (a, w) => a + byId(w.swimId!).minPrice * w.qty);
    final brandCount = st.active.map((w) => w.brand).toSet().length;
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Мой гардероб'),
          actions: [
            IconButton(
              tooltip: 'Хочу купить',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
              icon: Badge(label: Text('${st.wishlist.length}'), backgroundColor: Brand.coral, child: const Icon(Icons.favorite_border_rounded)),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(130),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Row(children: [
                  _Stat('${st.wardrobeCount}', 'вещей', Brand.lagoon),
                  _Stat(rub(value).replaceAll(' руб.', ''), 'руб. стоимость', Brand.coral),
                  _Stat('$brandCount', 'брендов', Brand.mint),
                ]),
              ),
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                tabs: [for (final t in _tabs) Tab(text: t)],
              ),
            ]),
          ),
        ),
        body: TabBarView(children: [
          for (var t = 0; t < _tabs.length; t++)
            Builder(builder: (context) {
              final items = _filter(st, t);
              if (items.isEmpty) {
                return Center(
                  child: EmptyState(
                    icon: t == 4 ? Icons.inventory_2_outlined : Icons.checkroom_rounded,
                    title: t == 4 ? 'Архив пуст' : 'Здесь пока пусто',
                    text: t == 4 ? 'Сюда попадают вещи, которые вы больше не носите' : 'Добавьте купальник из каталога или вручную',
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final w = items[i];
                  return SwimRow(
                    type: w.type,
                    variant: w.color,
                    image: w.swimId == null ? null : SwimPhoto(byId(w.swimId!), radius: 16),
                    title: w.name,
                    subtitle: '${w.brand} · ${w.color.name} · размер ${w.size}',
                    onTap: () => _editItem(context, w),
                    bottom: Wrap(spacing: 6, runSpacing: 6, children: [
                      if (w.qty > 1) TagChip('${w.qty} шт.', color: Brand.ink),
                      for (final tg in w.tags) TagChip(tg, color: tagColor(tg)),
                      if (w.swimId == null) TagChip('Своя', color: Colors.grey),
                    ]),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
                      onSelected: (v) {
                        switch (v) {
                          case 'edit':
                            _editItem(context, w);
                          case 'archive':
                            st.updateItem(w.copyWith(archived: !w.archived));
                            toast(context, w.archived ? 'Вернули в гардероб' : 'Перенесено в архив', icon: Icons.inventory_2_outlined);
                          case 'delete':
                            st.removeItem(w.id);
                            toast(context, 'Удалено', icon: Icons.delete_outline_rounded);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Изменить')),
                        PopupMenuItem(value: 'archive', child: Text(w.archived ? 'Вернуть из архива' : 'В архив')),
                        const PopupMenuItem(value: 'delete', child: Text('Удалить')),
                      ],
                    ),
                  );
                },
              );
            }),
        ]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addMenu(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Добавить', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  void _addMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              leading: const CircleAvatar(backgroundColor: Brand.lagoon, child: Icon(Icons.grid_view_rounded, color: Colors.white)),
              title: const Text('Из каталога', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Найти модель и отметить размер'),
              onTap: () {
                Navigator.pop(ctx);
                context.findAncestorStateOfType<ShellState>()?.go(1);
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Brand.coral, child: Icon(Icons.edit_rounded, color: Colors.white)),
              title: const Text('Вручную', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Если модели нет в каталоге'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddManualScreen()));
              },
            ),
          ]),
        ),
      ),
    );
  }

  void _editItem(BuildContext context, WardrobeItem item) {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => _EditSheet(item: item));
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Stat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            FittedBox(child: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color.lerp(color, Colors.black, 0.15)))),
            Text(label, style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
      );
}

class _EditSheet extends StatefulWidget {
  final WardrobeItem item;
  const _EditSheet({required this.item});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late int qty = widget.item.qty;
  late String size = widget.item.size;
  late final Set<String> tags = {...widget.item.tags};
  late final note = TextEditingController(text: widget.item.note);

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.item;
    final sizeOptions = w.swimId != null ? byId(w.swimId!).sizes : sizes;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            SizedBox(width: 72, height: 72, child: w.swimId == null ? SwimArt(type: w.type, variant: w.color, radius: 16, showBubbles: false) : SwimPhoto(byId(w.swimId!), radius: 16)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(w.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Text('${w.brand} · ${w.color.name}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]),
            ),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            const Expanded(child: Text('Количество', style: TextStyle(fontWeight: FontWeight.w800))),
            IconButton.filledTonal(onPressed: qty > 1 ? () => setState(() => qty--) : null, icon: const Icon(Icons.remove_rounded)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
            IconButton.filledTonal(onPressed: () => setState(() => qty++), icon: const Icon(Icons.add_rounded)),
          ]),
          const SizedBox(height: 12),
          const Text('Размер', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final z in sizeOptions) ChoiceChip(label: Text(z), selected: size == z, onSelected: (_) => setState(() => size = z)),
          ]),
          const SizedBox(height: 12),
          const Text('Метки', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in wardrobeTags)
              FilterChip(label: Text(t), selected: tags.contains(t), onSelected: (v) => setState(() => v ? tags.add(t) : tags.remove(t))),
          ]),
          const SizedBox(height: 14),
          TextField(controller: note, maxLines: 2, decoration: const InputDecoration(hintText: 'Заметка: «маломерит», «для фотосессии»...')),
          const SizedBox(height: 16),
          Row(children: [
            if (w.swimId != null)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openProduct(context, w.swimId!, variant: w.variant);
                  },
                  child: const Text('В каталоге'),
                ),
              ),
            if (w.swimId != null) const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  AppScope.of(context).updateItem(w.copyWith(qty: qty, size: size, tags: tags, note: note.text.trim()));
                  Navigator.pop(context);
                  toast(context, 'Сохранено');
                },
                child: const Text('Сохранить'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class AddManualScreen extends StatefulWidget {
  const AddManualScreen({super.key});

  @override
  State<AddManualScreen> createState() => _AddManualScreenState();
}

class _AddManualScreenState extends State<AddManualScreen> {
  final name = TextEditingController();
  final brand = TextEditingController();
  final note = TextEditingController();
  SwimType type = SwimType.onePiece;
  int color = 0;
  String size = 'M';
  final Set<String> tags = {'Новый'};

  @override
  void dispose() {
    name.dispose();
    brand.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget label(String t) => Padding(padding: const EdgeInsets.only(top: 18, bottom: 8), child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800)));
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить вручную')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        SizedBox(
          height: 220,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: SwimArt(key: ValueKey('$type-$color'), type: type, variant: manualPalette[color], radius: 26),
          ),
        ),
        label('Название *'),
        TextField(controller: name, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Например, синий слитный с Бали')),
        label('Бренд'),
        TextField(controller: brand, decoration: const InputDecoration(hintText: 'Если знаете')),
        label('Вид'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in SwimType.values) ChoiceChip(label: Text(t.title), selected: type == t, onSelected: (_) => setState(() => type = t)),
        ]),
        label('Цвет'),
        Row(children: [
          for (var i = 0; i < manualPalette.length; i++)
            GestureDetector(
              onTap: () => setState(() => color = i),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color == i ? Brand.lagoon : Colors.transparent, width: 2.5)),
                child: CircleAvatar(radius: 16, backgroundColor: manualPalette[i].main),
              ),
            ),
        ]),
        label('Размер'),
        Wrap(spacing: 8, children: [
          for (final z in [...sizes, 'ONE']) ChoiceChip(label: Text(z), selected: size == z, onSelected: (_) => setState(() => size = z)),
        ]),
        label('Метки'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in wardrobeTags)
            FilterChip(label: Text(t), selected: tags.contains(t), onSelected: (v) => setState(() => v ? tags.add(t) : tags.remove(t))),
        ]),
        label('Заметка'),
        TextField(controller: note, maxLines: 2, decoration: const InputDecoration(hintText: 'Где купили, как сидит')),
        const SizedBox(height: 22),
        FilledButton(
          onPressed: name.text.trim().isEmpty
              ? null
              : () {
                  AppScope.of(context).addManual(
                    name: name.text.trim(),
                    brand: brand.text.trim().isEmpty ? 'Без бренда' : brand.text.trim(),
                    type: type,
                    paletteIndex: color,
                    size: size,
                    tags: tags,
                    note: note.text.trim(),
                  );
                  Navigator.pop(context);
                  toast(context, 'Добавлено в гардероб');
                },
          child: const Text('Сохранить'),
        ),
      ]),
    );
  }
}

// ======================= Хочу купить =======================

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final items = st.wishlist.map(byId).toList()..sort((a, b) => a.minPrice.compareTo(b.minPrice));
    return Scaffold(
      appBar: AppBar(title: const Text('Хочу купить')),
      body: items.isEmpty
          ? const Center(
              child: EmptyState(icon: Icons.favorite_border_rounded, title: 'Список пуст', text: 'Нажмите «Хочу» в карточке купальника, и мы будем следить за ценой'),
            )
          : ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8FB1)]),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${items.length} вещи на сумму', style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                      Text(rub(st.wishTotal), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('Следим за ценой: ${st.priceAlerts.length}', style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                    ]),
                  ),
                  const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 46),
                ]),
              ),
              const SizedBox(height: 14),
              for (final s in items) ...[
                SwimRow(
                  type: s.type,
                  variant: s.colors.first,
                  image: SwimPhoto(s, radius: 16),
                  title: s.name,
                  subtitle: 'дешевле всего в «${storeById(s.bestOffer.storeId).name}»',
                  onTap: () => openProduct(context, s.id),
                  bottom: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(rub(s.minPrice), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Row(children: [
                      const Text('Сообщить о скидке', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(value: st.priceAlerts.contains(s.id), onChanged: (_) => st.toggleAlert(s.id)),
                      ),
                    ]),
                  ]),
                  trailing: IconButton(
                    onPressed: () {
                      st.toggleWish(s.id);
                      toast(context, 'Убрано из списка', icon: Icons.delete_outline_rounded);
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ]),
    );
  }
}

// ======================= Магазины =======================

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({super.key});

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final store = stores[selected];
    final wish = st.wishlist.map(byId).toList();
    final promos = catalog.where((s) => s.priceHistory.first > s.priceHistory.last).toList();
    return SafeArea(
      child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text('Магазины', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text('${stores.length} партнёров рядом с вами', style: TextStyle(color: cs.onSurfaceVariant)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              SizedBox(height: 230, child: StoresMap(selected: selected, onSelect: (i) => setState(() => selected = i))),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: store.color, borderRadius: BorderRadius.circular(14)),
                    child: Text(store.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(store.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Text('${store.address} · ${store.distanceKm.toStringAsFixed(1)} км', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5)),
                    ]),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(minimumSize: const Size(0, 42)),
                    onPressed: () => toast(context, 'Строим маршрут до «${store.name}»', icon: Icons.directions_rounded),
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    label: const Text('Маршрут'),
                  ),
                ]),
              ),
            ]),
          ),
        ),
        const SectionHeader('Партнёры'),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: stores.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ChoiceChip(
              avatar: CircleAvatar(backgroundColor: stores[i].color, radius: 8),
              label: Text(stores[i].name),
              selected: i == selected,
              onSelected: (_) => setState(() => selected = i),
            ),
          ),
        ),
        const SectionHeader('Акции недели'),
        SwimCarousel(promos),
        SectionHeader('Сравнение цен по списку «Хочу»', action: wish.isEmpty ? null : 'Открыть',
            onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()))),
        if (wish.isEmpty)
          const EmptyState(icon: Icons.compare_arrows_rounded, title: 'Нечего сравнивать', text: 'Добавьте купальники в «Хочу», и здесь появятся лучшие цены')
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Column(children: [
                for (final s in wish)
                  ListTile(
                    onTap: () => openProduct(context, s.id),
                    leading: SizedBox(width: 48, height: 48, child: SwimPhoto(s, radius: 12)),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${s.offers.length} магазина, разница ${rub(s.offers.map((o) => o.price).reduce(math.max) - s.minPrice)}'),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(rub(s.minPrice), style: const TextStyle(fontWeight: FontWeight.w900)),
                      Text(storeById(s.bestOffer.storeId).name, style: TextStyle(fontSize: 11.5, color: storeById(s.bestOffer.storeId).color, fontWeight: FontWeight.w700)),
                    ]),
                  ),
              ]),
            ),
          ),
      ]),
    );
  }
}

// ======================= Уведомления =======================

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Уведомления'), actions: [
        TextButton(onPressed: st.unreadNotices == 0 ? null : st.markNoticesRead, child: const Text('Прочитать все')),
        const SizedBox(width: 8),
      ]),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: notices.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final n = notices[i];
          final unread = !st.readNotices.contains('$i');
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: n.swimId == null ? null : () => openProduct(context, n.swimId!),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: n.color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)),
                    child: Icon(n.icon, color: n.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w800))),
                        Text(n.time, style: TextStyle(fontSize: 11.5, color: cs.onSurfaceVariant)),
                      ]),
                      const SizedBox(height: 4),
                      Text(n.body, style: const TextStyle(height: 1.35)),
                    ]),
                  ),
                  if (unread)
                    Container(
                      margin: const EdgeInsets.only(left: 8, top: 4),
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(color: Brand.coral, shape: BoxShape.circle),
                    ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ======================= Профиль =======================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool push = true;
  bool priceDrops = true;

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: Brand.gradient, borderRadius: BorderRadius.circular(26)),
          child: Column(children: [
            Row(children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Text(st.userName[0], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Brand.lagoon)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(st.userName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  Text('Сочи · в Lagoona с июня 2026', style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                ]),
              ),
              IconButton(onPressed: () => toast(context, 'Редактирование профиля в полной версии', icon: Icons.edit_rounded), icon: const Icon(Icons.edit_rounded, color: Colors.white)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              _ProfStat('${st.wardrobeCount}', 'в гардеробе'),
              _ProfStat('${st.wishlist.length}', 'хочу'),
              _ProfStat('${st.favorites.length}', 'избранное'),
              _ProfStat('${st.wardrobe.where((w) => w.archived).length}', 'в архиве'),
            ]),
          ]),
        ),
        const SizedBox(height: 18),
        Text('Оформление', style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_rounded), label: Text('Авто')),
            ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_rounded), label: Text('Светлая')),
            ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_rounded), label: Text('Тёмная')),
          ],
          selected: {st.themeMode},
          onSelectionChanged: (v) => st.setTheme(v.first),
        ),
        const SizedBox(height: 18),
        Card(
          child: Column(children: [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text('Push-уведомления'),
              value: push,
              onChanged: (v) => setState(() => push = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.trending_down_rounded),
              title: const Text('Снижение цен в «Хочу»'),
              value: priceDrops,
              onChanged: (v) => setState(() => priceDrops = v),
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Экспорт гардероба в CSV'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _export(context, st),
            ),
            ListTile(
              leading: const Icon(Icons.slideshow_outlined),
              title: const Text('Показать приветствие'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const OnboardingScreen()), (_) => false),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('О приложении'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Lagoona',
                applicationVersion: 'демо 1.0',
                applicationIcon: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(gradient: Brand.gradient, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.waves_rounded, color: Colors.white),
                ),
                children: const [
                  Text('Демо-приложение: каталог купальников, личный гардероб, список желаний и сравнение цен. Бренды и магазины вымышленные.'),
                  SizedBox(height: 10),
                  Text('Фото: Unsplash, авторы указаны в репозитории проекта.'),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  void _export(BuildContext context, AppState st) {
    final csv = st.exportCsv();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Экспорт гардероба'),
        content: SingleChildScrollView(child: SelectableText(csv, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Закрыть')),
          FilledButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csv));
              Navigator.pop(ctx);
              toast(context, 'CSV скопирован');
            },
            child: const Text('Скопировать'),
          ),
        ],
      ),
    );
  }
}

class _ProfStat extends StatelessWidget {
  final String v;
  final String l;
  const _ProfStat(this.v, this.l);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(v, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(l, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11.5)),
        ]),
      );
}

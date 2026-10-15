import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'art.dart';
import 'data.dart';
import 'main.dart';
import 'screens_b.dart';
import 'state.dart';
import 'widgets.dart';

// ======================= Главная =======================

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final vacation = st.active.where((w) => w.tags.contains('На отпуск')).length;
    final deals = catalog.where((s) => s.priceHistory.first > s.priceHistory.last).toList()
      ..sort((a, b) => _drop(b).compareTo(_drop(a)));
    return SafeArea(
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(gradient: Brand.gradient, shape: BoxShape.circle),
                child: Text(st.userName[0], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Привет, ${st.userName}!', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  Text('Пляжный сезон открыт', style: TextStyle(color: cs.onSurfaceVariant)),
                ]),
              ),
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticesScreen())),
                icon: Badge(
                  isLabelVisible: st.unreadNotices > 0,
                  label: Text('${st.unreadNotices}'),
                  backgroundColor: Brand.coral,
                  child: const Icon(Icons.notifications_none_rounded, size: 28),
                ),
              ),
            ]),
          ),
        ),
        // баннер отпуска
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: Brand.gradient,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [BoxShadow(color: Brand.lagoon.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(20)),
                      child: const Text('До отпуска 14 дней', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    const SizedBox(height: 10),
                    const Text('Соберите пляжный чемодан', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.15)),
                    const SizedBox(height: 6),
                    Text('Уже отмечено вещей: $vacation', style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                    const SizedBox(height: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Brand.ink, minimumSize: const Size(0, 40)),
                      onPressed: () => onNavigate(2),
                      child: const Text('Открыть гардероб'),
                    ),
                  ]),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 104,
                  height: 128,
                  child: SwimArt(type: SwimType.bikini, variant: byId('s2').colors.first, radius: 22),
                ),
              ]),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              QuickTile(icon: Icons.checkroom_rounded, title: 'Мой гардероб', value: '${st.wardrobeCount}', colors: const [Color(0xFF00B4D8), Color(0xFF0077B6)], onTap: () => onNavigate(2)),
              QuickTile(icon: Icons.grid_view_rounded, title: 'Каталог', value: '${catalog.length}', colors: const [Color(0xFF7B61FF), Color(0xFFB388FF)], onTap: () => onNavigate(1)),
              QuickTile(
                icon: Icons.favorite_rounded,
                title: 'Хочу купить',
                value: '${st.wishlist.length}',
                colors: const [Color(0xFFFF6B6B), Color(0xFFFF8FB1)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
              ),
              QuickTile(
                icon: Icons.trending_down_rounded,
                title: 'Слежу за ценой',
                value: '${st.priceAlerts.length}',
                colors: const [Color(0xFF06D6A0), Color(0xFF1B9E77)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SectionHeader('Хиты сезона', action: 'Все', onAction: () => onNavigate(1))),
        SliverToBoxAdapter(child: SwimCarousel(catalog.where((s) => s.isHit).toList())),
        const SliverToBoxAdapter(child: SectionHeader('Цены снизились')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: deals.take(3).length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final s = deals[i];
              return SwimRow(
                type: s.type,
                variant: s.colors.first,
                title: s.name,
                subtitle: '${s.brand} · ${storeById(s.bestOffer.storeId).name}',
                onTap: () => openProduct(context, s.id),
                bottom: Row(children: [
                  Text(rub(s.minPrice), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(width: 8),
                  Text(rub(s.priceHistory.first),
                      style: TextStyle(decoration: TextDecoration.lineThrough, color: cs.onSurfaceVariant, fontSize: 12)),
                ]),
                trailing: TagChip('-${_drop(s)}%', color: Brand.mint),
              );
            },
          ),
        ),
        SliverToBoxAdapter(child: SectionHeader('Новинки', action: 'Все', onAction: () => onNavigate(1))),
        SliverToBoxAdapter(child: SwimCarousel(catalog.where((s) => s.isNew).toList())),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ]),
    );
  }

  static int _drop(Swimsuit s) => ((s.priceHistory.first - s.minPrice) / s.priceHistory.first * 100).round();
}

// ======================= Каталог =======================

enum SortBy { popular, rating, cheap, expensive, fresh }

extension SortByX on SortBy {
  String get title => switch (this) {
        SortBy.popular => 'Популярные',
        SortBy.rating => 'По рейтингу',
        SortBy.cheap => 'Сначала дешёвые',
        SortBy.expensive => 'Сначала дорогие',
        SortBy.fresh => 'Новинки',
      };
}

class CatalogFilter {
  Set<SwimType> types = {};
  Set<String> brands = {};
  Set<String> sizes = {};
  RangeValues price = const RangeValues(1000, 7000);
  bool inStock = false;
  bool topRated = false;

  CatalogFilter copy() => CatalogFilter()
    ..types = {...types}
    ..brands = {...brands}
    ..sizes = {...sizes}
    ..price = price
    ..inStock = inStock
    ..topRated = topRated;

  int get count =>
      types.length + brands.length + sizes.length + (price != const RangeValues(1000, 7000) ? 1 : 0) + (inStock ? 1 : 0) + (topRated ? 1 : 0);

  bool test(Swimsuit s) {
    if (types.isNotEmpty && !types.contains(s.type)) return false;
    if (brands.isNotEmpty && !brands.contains(s.brand)) return false;
    if (sizes.isNotEmpty && !s.sizes.any(sizes.contains) && !s.sizes.contains('ONE')) return false;
    if (s.minPrice < price.start || s.minPrice > price.end) return false;
    if (inStock && !s.offers.any((o) => o.inStock)) return false;
    if (topRated && s.rating < 4.7) return false;
    return true;
  }
}

class CatalogScreen extends StatefulWidget {
  final bool openFilters;
  const CatalogScreen({super.key, this.openFilters = false});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String query = '';
  SwimType? type;
  SortBy sort = SortBy.popular;
  CatalogFilter filter = CatalogFilter();

  @override
  void initState() {
    super.initState();
    if (widget.openFilters) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openFilters());
    }
  }

  List<Swimsuit> get items {
    final q = query.trim().toLowerCase();
    final list = catalog.where((s) {
      if (type != null && s.type != type) return false;
      if (q.isNotEmpty &&
          !'${s.name} ${s.brand} ${s.type.title} ${s.features.join(' ')} ${s.colors.map((c) => c.name).join(' ')}'.toLowerCase().contains(q)) {
        return false;
      }
      return filter.test(s);
    }).toList();
    switch (sort) {
      case SortBy.popular:
        list.sort((a, b) => b.reviews.compareTo(a.reviews));
      case SortBy.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case SortBy.cheap:
        list.sort((a, b) => a.minPrice.compareTo(b.minPrice));
      case SortBy.expensive:
        list.sort((a, b) => b.minPrice.compareTo(a.minPrice));
      case SortBy.fresh:
        list.sort((a, b) => (b.isNew ? 1 : 0).compareTo(a.isNew ? 1 : 0));
    }
    return list;
  }

  Future<void> _openFilters() async {
    final res = await showModalBottomSheet<CatalogFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FiltersSheet(initial: filter.copy()),
    );
    if (res != null) setState(() => filter = res);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final list = items;
    return SafeArea(
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text('Каталог', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => query = v),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Название, бренд, цвет'),
                ),
              ),
              const SizedBox(width: 10),
              Badge(
                isLabelVisible: filter.count > 0,
                label: Text('${filter.count}'),
                backgroundColor: Brand.coral,
                child: IconButton.filled(
                  style: IconButton.styleFrom(minimumSize: const Size(52, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: _openFilters,
                  icon: const Icon(Icons.tune_rounded),
                ),
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 58,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              scrollDirection: Axis.horizontal,
              children: [
                _TypeChip(label: 'Все', selected: type == null, onTap: () => setState(() => type = null)),
                for (final t in SwimType.values) _TypeChip(label: t.title, selected: type == t, onTap: () => setState(() => type = t)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 92,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: brands.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (_, i) {
                final b = brands[i];
                final on = filter.brands.contains(b);
                final color = [Brand.lagoon, Brand.coral, const Color(0xFF7B61FF), Brand.mint, Brand.sun, const Color(0xFFFF8FB1)][i % 6];
                return GestureDetector(
                  onTap: () => setState(() => on ? filter.brands.remove(b) : filter.brands.add(b)),
                  child: Column(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: on ? 1 : 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(color: on ? Colors.white : Colors.transparent, width: 3),
                        boxShadow: on ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10)] : null,
                      ),
                      child: Text(b.substring(0, 2).toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.w900, color: on ? Colors.white : Color.lerp(color, Colors.black, 0.2))),
                    ),
                    const SizedBox(height: 4),
                    Text(b, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
            child: Row(children: [
              Expanded(child: Text('Найдено: ${list.length}', style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600))),
              PopupMenuButton<SortBy>(
                initialValue: sort,
                onSelected: (v) => setState(() => sort = v),
                itemBuilder: (_) => [for (final s in SortBy.values) PopupMenuItem(value: s, child: Text(s.title))],
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(children: [
                    const Icon(Icons.swap_vert_rounded, size: 20),
                    const SizedBox(width: 4),
                    Text(sort.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
        if (list.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Ничего не нашлось',
              text: 'Попробуйте убрать часть фильтров или изменить запрос',
              action: 'Сбросить фильтры',
              onAction: () => setState(() {
                filter = CatalogFilter();
                type = null;
              }),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 262,
              ),
              delegate: SliverChildBuilderDelegate((_, i) => SwimCard(list[i]), childCount: list.length),
            ),
          ),
      ]),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          showCheckmark: false,
          selectedColor: Brand.lagoon,
          labelStyle: TextStyle(fontWeight: FontWeight.w700, color: selected ? Colors.white : null),
        ),
      );
}

class FiltersSheet extends StatefulWidget {
  final CatalogFilter initial;
  const FiltersSheet({super.key, required this.initial});

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  late CatalogFilter f = widget.initial;

  @override
  Widget build(BuildContext context) {
    final found = catalog.where(f.test).length;
    Widget title(String t) => Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        );
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
          child: Row(children: [
            Text('Фильтры', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const Spacer(),
            TextButton(onPressed: () => setState(() => f = CatalogFilter()), child: const Text('Сбросить')),
          ]),
        ),
        Expanded(
          child: ListView(controller: controller, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            title('Вид купальника'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final t in SwimType.values)
                FilterChip(
                  label: Text(t.title),
                  selected: f.types.contains(t),
                  onSelected: (v) => setState(() => v ? f.types.add(t) : f.types.remove(t)),
                ),
            ]),
            title('Бренд'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final b in brands)
                FilterChip(label: Text(b), selected: f.brands.contains(b), onSelected: (v) => setState(() => v ? f.brands.add(b) : f.brands.remove(b))),
            ]),
            title('Размер'),
            Wrap(spacing: 8, children: [
              for (final z in sizes)
                FilterChip(label: Text(z), selected: f.sizes.contains(z), onSelected: (v) => setState(() => v ? f.sizes.add(z) : f.sizes.remove(z))),
            ]),
            title('Цена: ${rub(f.price.start.round())} до ${rub(f.price.end.round())}'),
            RangeSlider(
              values: f.price,
              min: 1000,
              max: 7000,
              divisions: 60,
              onChanged: (v) => setState(() => f.price = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Только в наличии', style: TextStyle(fontWeight: FontWeight.w700)),
              value: f.inStock,
              onChanged: (v) => setState(() => f.inStock = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Рейтинг 4.7 и выше', style: TextStyle(fontWeight: FontWeight.w700)),
              value: f.topRated,
              onChanged: (v) => setState(() => f.topRated = v),
            ),
            const SizedBox(height: 12),
          ]),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: () => Navigator.pop(context, f), child: Text('Показать $found')),
            ),
          ),
        ),
      ]),
    );
  }
}

// ======================= Карточка товара =======================

class ProductScreen extends StatefulWidget {
  final String id;
  final int initialVariant;
  const ProductScreen({super.key, required this.id, this.initialVariant = 0});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final Swimsuit s = byId(widget.id);
  late int variant = widget.initialVariant;
  late final PageController pages = PageController(initialPage: widget.initialVariant);
  String? size;

  @override
  void dispose() {
    pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final fav = st.favorites.contains(s.id);
    final wished = st.wishlist.contains(s.id);
    final offers = [...s.offers]..sort((a, b) => a.price.compareTo(b.price));
    final drop = ((s.priceHistory.first - s.priceHistory.last) / s.priceHistory.first * 100).round();

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 420,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: Padding(
            padding: const EdgeInsets.all(6),
            child: IconButton.filledTonal(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
          ),
          actions: [
            IconButton.filledTonal(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 'https://lagoona.app/item/${s.id}'));
                toast(context, 'Ссылка скопирована', icon: Icons.link_rounded);
              },
              icon: const Icon(Icons.ios_share_rounded),
            ),
            IconButton.filledTonal(
              onPressed: () => st.toggleFavorite(s.id),
              icon: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: fav ? Brand.coral : null),
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(children: [
              Positioned.fill(
                child: PageView.builder(
                  controller: pages,
                  itemCount: s.colors.length,
                  onPageChanged: (i) => setState(() => variant = i),
                  itemBuilder: (_, i) => SwimArt(type: s.type, variant: s.colors[i], radius: 0),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < s.colors.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == variant ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: i == variant ? 1 : 0.6), borderRadius: BorderRadius.circular(8)),
                    ),
                ]),
              ),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          sliver: SliverList.list(children: [
            Row(children: [
              TagChip(s.brand, color: Brand.lagoon),
              const SizedBox(width: 6),
              TagChip(s.type.single, color: const Color(0xFF7B61FF)),
              const Spacer(),
              Stars(s.rating, reviews: s.reviews),
            ]),
            const SizedBox(height: 10),
            Text(s.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Row(children: [
              Text('от ${rub(s.minPrice)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(width: 10),
              if (drop > 0) TagChip('-$drop% за полгода', color: Brand.mint),
            ]),
            const SizedBox(height: 18),
            Text('Цвет: ${s.colors[variant].name}', style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(children: [
              for (var i = 0; i < s.colors.length; i++)
                GestureDetector(
                  onTap: () => pages.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: i == variant ? Brand.lagoon : Colors.transparent, width: 2.5),
                    ),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(colors: [s.colors[i].main, s.colors[i].accent, s.colors[i].main]),
                      ),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 18),
            const Text('Размер', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              for (final z in s.sizes)
                ChoiceChip(
                  label: Text(z),
                  selected: size == z,
                  showCheckmark: false,
                  selectedColor: Brand.lagoon,
                  labelStyle: TextStyle(fontWeight: FontWeight.w800, color: size == z ? Colors.white : null),
                  onSelected: (_) => setState(() => size = z),
                ),
            ]),
            const SizedBox(height: 22),
            _Block(
              title: 'Где купить',
              trailing: Text('${offers.where((o) => o.inStock).length} из ${offers.length} в наличии', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              child: Column(children: [
                for (var i = 0; i < offers.length; i++) _OfferRow(offer: offers[i], best: i == 0, swim: s),
              ]),
            ),
            const SizedBox(height: 14),
            _Block(
              title: 'История цены',
              trailing: Text('6 месяцев', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(height: 96, child: PriceSparkline(values: s.priceHistory, color: Brand.mint)),
                const SizedBox(height: 8),
                Row(children: [
                  Text('Было ${rub(s.priceHistory.first)}', style: TextStyle(color: cs.onSurfaceVariant)),
                  const Spacer(),
                  Text('Сейчас ${rub(s.priceHistory.last)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            _Block(
              title: 'Характеристики',
              child: Column(children: [
                _Spec('Тип', s.type.single),
                _Spec('Материал', s.material),
                _Spec('Посадка', s.fit),
                _Spec('Размеры', s.sizes.join(', ')),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(spacing: 6, runSpacing: 6, children: [for (final f in s.features) TagChip(f, color: Brand.coral)]),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            _Block(title: 'Описание', child: Text(s.description, style: const TextStyle(height: 1.45))),
            const SizedBox(height: 14),
            _Block(
              title: 'Отзывы',
              trailing: Stars(s.rating, reviews: s.reviews),
              child: Column(children: const [
                _Review('Марина', 5, 'Села идеально, ткань плотная. После моря не растянулся.', 'неделю назад'),
                _Review('Катя', 4, 'Цвет чуть ярче, чем на фото, но так даже лучше. Беру на размер больше.', 'месяц назад'),
              ]),
            ),
          ]),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            color: cs.surface,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
          ),
          child: Row(children: [
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                onPressed: () {
                  st.toggleWish(s.id);
                  toast(context, wished ? 'Убрано из списка «Хочу»' : 'Добавлено в «Хочу купить»', icon: Icons.favorite_rounded);
                },
                icon: Icon(wished ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: Brand.coral),
                label: Text(wished ? 'В списке' : 'Хочу'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: FilledButton.icon(
                onPressed: () {
                  if (size == null) {
                    quickAdd(context, s, variant: variant);
                  } else {
                    st.addFromCatalog(s, variant, size!);
                    toast(context, 'Добавлено в гардероб');
                  }
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('В гардероб'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _Block({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              ?trailing,
            ]),
            const SizedBox(height: 12),
            child,
          ]),
        ),
      );
}

class _OfferRow extends StatelessWidget {
  final Offer offer;
  final bool best;
  final Swimsuit swim;
  const _OfferRow({required this.offer, required this.best, required this.swim});

  @override
  Widget build(BuildContext context) {
    final store = storeById(offer.storeId);
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: best ? Brand.mint.withValues(alpha: 0.10) : cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: best ? Border.all(color: Brand.mint.withValues(alpha: 0.6)) : null,
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: store.color, borderRadius: BorderRadius.circular(12)),
          child: Text(store.name.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(store.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800))),
              if (best) ...[const SizedBox(width: 6), const TagChip('Лучшая цена', color: Brand.mint)],
            ]),
            const SizedBox(height: 2),
            Text(
              offer.inStock ? 'В наличии · доставка ${store.delivery}' : 'Под заказ · доставка ${store.delivery}',
              style: TextStyle(fontSize: 12, color: offer.inStock ? cs.onSurfaceVariant : Brand.coral),
            ),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(rub(offer.price), style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          SizedBox(
            height: 30,
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 30), padding: const EdgeInsets.symmetric(horizontal: 14), textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
              onPressed: () => toast(context, 'Открываем ${store.name}: ${swim.name}', icon: Icons.open_in_new_rounded),
              child: const Text('Перейти'),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _Spec extends StatelessWidget {
  final String k;
  final String v;
  const _Spec(this.k, this.v);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 96, child: Text(k, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
        ]),
      );
}

class _Review extends StatelessWidget {
  final String name;
  final int stars;
  final String text;
  final String when;
  const _Review(this.name, this.stars, this.text, this.when);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Brand.coral.withValues(alpha: 0.18),
            child: Text(name[0], style: const TextStyle(color: Brand.coral, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                for (var i = 0; i < 5; i++) Icon(Icons.star_rounded, size: 14, color: i < stars ? Brand.sun : Colors.grey.withValues(alpha: 0.4)),
                const Spacer(),
                Text(when, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]),
              const SizedBox(height: 4),
              Text(text, style: const TextStyle(height: 1.35)),
            ]),
          ),
        ]),
      );
}

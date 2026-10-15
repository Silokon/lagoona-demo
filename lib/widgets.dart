import 'package:flutter/material.dart';

import 'art.dart';
import 'data.dart';
import 'main.dart';
import 'screens_a.dart';
import 'state.dart';

void openProduct(BuildContext context, String id, {int variant = 0}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductScreen(id: id, initialVariant: variant)));
}

void toast(BuildContext context, String text, {IconData icon = Icons.check_circle_rounded}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(children: [Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 10), Expanded(child: Text(text))]),
      duration: const Duration(milliseconds: 1800),
    ));
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 12, 10),
        child: Row(children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
          if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
        ]),
      );
}

class Stars extends StatelessWidget {
  final double rating;
  final int? reviews;
  final double size;
  const Stars(this.rating, {super.key, this.reviews, this.size = 14});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.star_rounded, size: size + 2, color: Brand.sun),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(1), style: TextStyle(fontSize: size, fontWeight: FontWeight.w700)),
        if (reviews != null)
          Text(' ($reviews)', style: TextStyle(fontSize: size - 1, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]);
}

class TagChip extends StatelessWidget {
  final String text;
  final Color color;
  const TagChip(this.text, {super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: dark ? 0.26 : 0.16), borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(
          color: dark ? Color.lerp(color, Colors.white, 0.45) : Color.lerp(color, Colors.black, 0.25),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Color tagColor(String t) => switch (t) {
      'Любимый' => Brand.coral,
      'На отпуск' => Brand.lagoon,
      'Для бассейна' => const Color(0xFF7B61FF),
      'Новый' => Brand.mint,
      _ => Brand.sun,
    };

/// Карточка купальника для сеток и каруселей.
class SwimCard extends StatelessWidget {
  final Swimsuit s;
  final double? width;
  const SwimCard(this.s, {super.key, this.width});

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final fav = st.favorites.contains(s.id);
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openProduct(context, s.id),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(children: [
                Positioned.fill(child: SwimPhoto(s, radius: 0)),
                if (s.isNew)
                  const Positioned(left: 10, top: 10, child: _Badge('NEW', Brand.mint)),
                if (s.isHit && !s.isNew)
                  const Positioned(left: 10, top: 10, child: _Badge('ХИТ', Brand.coral)),
                Positioned(
                  right: 6,
                  top: 6,
                  child: _RoundIcon(
                    icon: fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: fav ? Brand.coral : cs.onSurface,
                    onTap: () => st.toggleFavorite(s.id),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                const SizedBox(height: 2),
                Text('${s.brand} · ${s.type.title}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: Text('от ${rub(s.minPrice)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                  Stars(s.rating, size: 12),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10.5, letterSpacing: 0.6)),
      );
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(7), child: Icon(icon, size: 19, color: color)),
        ),
      );
}

/// Горизонтальная карусель карточек.
class SwimCarousel extends StatelessWidget {
  final List<Swimsuit> items;
  const SwimCarousel(this.items, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 262,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) => SwimCard(items[i], width: 168),
        ),
      );
}

/// Строка списка: картинка слева, текст и действия справа.
class SwimRow extends StatelessWidget {
  final SwimType type;
  final ColorVariant variant;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final VoidCallback? onTap;
  final String? heroTag;
  final Widget? image;

  const SwimRow({
    super.key,
    required this.type,
    required this.variant,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.bottom,
    this.onTap,
    this.heroTag,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final art = image ?? SwimArt(type: type, variant: variant, radius: 16, showBubbles: false);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 84, height: 84, child: heroTag == null ? art : Hero(tag: heroTag!, child: art)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 2),
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12.5)),
                if (bottom != null) ...[const SizedBox(height: 8), bottom!],
              ]),
            ),
            ?trailing,
          ]),
        ),
      ),
    );
  }
}

/// Плитка с градиентом для главного экрана.
class QuickTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<Color> colors;
  final VoidCallback onTap;
  const QuickTile({super.key, required this.icon, required this.title, required this.value, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                ]),
                const Spacer(),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.5)),
              ]),
            ),
          ),
        ),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const EmptyState({super.key, required this.icon, required this.title, required this.text, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: Brand.lagoon.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: Brand.lagoon),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(text, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          if (action != null) ...[const SizedBox(height: 16), FilledButton(onPressed: onAction, child: Text(action!))],
        ]),
      );
}

/// Шторка выбора размера при быстром добавлении в гардероб.
Future<void> quickAdd(BuildContext context, Swimsuit s, {int variant = 0}) async {
  final st = AppScope.of(context);
  final size = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Какой размер у вас?', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('${s.name}, ${s.colors[variant].name}', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final z in s.sizes) ActionChip(label: Text(z, style: const TextStyle(fontWeight: FontWeight.w800)), onPressed: () => Navigator.pop(ctx, z)),
        ]),
      ]),
    ),
  );
  if (size == null) return;
  st.addFromCatalog(s, variant, size);
  if (context.mounted) toast(context, 'Добавлено в гардероб');
}

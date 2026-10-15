import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens_a.dart';
import 'screens_b.dart';
import 'state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.load();
  final theme = Uri.base.queryParameters['theme'];
  if (theme == 'dark') state.themeMode = ThemeMode.dark;
  if (theme == 'light') state.themeMode = ThemeMode.light;
  runApp(AppScope(state: state, child: const LagoonaApp()));
}

class Brand {
  static const lagoon = Color(0xFF00A6C8);
  static const coral = Color(0xFFFF6B6B);
  static const sun = Color(0xFFFFD166);
  static const mint = Color(0xFF06D6A0);
  static const ink = Color(0xFF1B2A41);
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00B4D8), Color(0xFF48CAE4), Color(0xFFFF8FA3)],
  );
}

ThemeData _theme(Brightness b) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: Brand.lagoon,
    brightness: b,
    primary: Brand.lagoon,
    secondary: Brand.coral,
    tertiary: Brand.sun,
    surface: dark ? const Color(0xFF13212C) : Colors.white,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: b);
  return base.copyWith(
    scaffoldBackgroundColor: dark ? const Color(0xFF0B1620) : const Color(0xFFF4F9FB),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface),
      systemOverlayStyle: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF1A2B38) : const Color(0xFFEDF4F7),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: Brand.lagoon.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(fontSize: 11.5, fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class LagoonaApp extends StatelessWidget {
  const LagoonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return MaterialApp(
      title: 'Lagoona',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: state.themeMode,
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _demoHome() ?? (state.onboarded ? const Shell() : const OnboardingScreen()),
    );
  }

  /// Веб-демо: ?screen=catalog&theme=dark открывает нужный экран (для скриншотов и ссылок).
  Widget? _demoHome() {
    final screen = Uri.base.queryParameters['screen'];
    return switch (screen) {
      'onboarding' => const OnboardingScreen(),
      'login' => const LoginScreen(),
      'home' => const Shell(),
      'catalog' => const Shell(initial: 1),
      'filters' => const Shell(initial: 1, openFilters: true),
      'wardrobe' => const Shell(initial: 2),
      'shops' => const Shell(initial: 3),
      'profile' => const Shell(initial: 4),
      'product' => ProductScreen(id: Uri.base.queryParameters['id'] ?? 's1'),
      'wishlist' => const WishlistScreen(),
      'notices' => const NoticesScreen(),
      'add' => const AddManualScreen(),
      _ => null,
    };
  }
}

/// Главный каркас с нижним меню.
class Shell extends StatefulWidget {
  final int initial;
  final bool openFilters;
  const Shell({super.key, this.initial = 0, this.openFilters = false});

  @override
  State<Shell> createState() => ShellState();
}

class ShellState extends State<Shell> {
  late int index = widget.initial;

  void go(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigate: go),
      CatalogScreen(openFilters: widget.openFilters),
      const WardrobeScreen(),
      const ShopsScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: go,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Главная'),
          const NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Каталог'),
          NavigationDestination(
            icon: _CenterIcon(selected: index == 2),
            selectedIcon: _CenterIcon(selected: true),
            label: 'Гардероб',
          ),
          const NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront_rounded), label: 'Магазины'),
          const NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Профиль'),
        ],
      ),
    );
  }
}

class _CenterIcon extends StatelessWidget {
  final bool selected;
  const _CenterIcon({required this.selected});

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 32,
        decoration: BoxDecoration(
          gradient: Brand.gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected ? [BoxShadow(color: Brand.lagoon.withValues(alpha: 0.45), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: const Icon(Icons.checkroom_rounded, color: Colors.white, size: 20),
      );
}

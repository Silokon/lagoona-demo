import 'package:flutter/material.dart';

/// Демо-данные Lagoona. Бренды и магазины вымышленные.

enum SwimType { onePiece, bikini, tankini, monokini, sport, pareo }

extension SwimTypeX on SwimType {
  String get title => switch (this) {
        SwimType.onePiece => 'Слитные',
        SwimType.bikini => 'Бикини',
        SwimType.tankini => 'Танкини',
        SwimType.monokini => 'Монокини',
        SwimType.sport => 'Спортивные',
        SwimType.pareo => 'Парео',
      };

  String get single => switch (this) {
        SwimType.onePiece => 'Слитный купальник',
        SwimType.bikini => 'Бикини',
        SwimType.tankini => 'Танкини',
        SwimType.monokini => 'Монокини',
        SwimType.sport => 'Спортивный купальник',
        SwimType.pareo => 'Парео',
      };
}

enum Print { solid, stripes, dots, tropic, waves }

class ColorVariant {
  final String name;
  final Color main;
  final Color accent;
  final Print pattern;
  const ColorVariant(this.name, this.main, this.accent, this.pattern);
}

class Store {
  final String id;
  final String name;
  final Color color;
  final String delivery;
  final double distanceKm;
  final String address;
  const Store(this.id, this.name, this.color, this.delivery, this.distanceKm, this.address);
}

class Offer {
  final String storeId;
  final int price;
  final bool inStock;
  const Offer(this.storeId, this.price, {this.inStock = true});
}

class Swimsuit {
  final String id;
  final String name;
  final String brand;
  final SwimType type;
  final List<ColorVariant> colors;
  final List<String> sizes;
  final List<Offer> offers;
  final double rating;
  final int reviews;
  final String material;
  final String fit;
  final List<String> features;
  final String description;
  final bool isNew;
  final bool isHit;
  final List<int> priceHistory;

  const Swimsuit({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.colors,
    required this.sizes,
    required this.offers,
    required this.rating,
    required this.reviews,
    required this.material,
    required this.fit,
    required this.features,
    required this.description,
    this.isNew = false,
    this.isHit = false,
    required this.priceHistory,
  });

  int get minPrice => offers.map((o) => o.price).reduce((a, b) => a < b ? a : b);
  Offer get bestOffer => offers.reduce((a, b) => a.price <= b.price ? a : b);
}

const stores = <Store>[
  Store('breeze', 'Бриз', Color(0xFF00B4D8), 'Бесплатно', 1.2, 'ул. Морская, 12'),
  Store('aquastyle', 'AquaStyle', Color(0xFFFF6B6B), '290 руб.', 2.8, 'ТЦ «Прибой», 2 этаж'),
  Store('seaside', 'Мода у моря', Color(0xFFFFB703), '350 руб.', 4.1, 'пр. Солнечный, 40'),
  Store('swimshop', 'SwimShop', Color(0xFF7B61FF), '199 руб.', 5.6, 'ул. Лазурная, 7'),
  Store('beachbox', 'BeachBox', Color(0xFF06D6A0), 'Бесплатно', 7.3, 'ТРЦ «Атолл», 1 этаж'),
];

Store storeById(String id) => stores.firstWhere((s) => s.id == id);

const brands = <String>['Coralé', 'Marea Lab', 'Azure Muse', 'Palma Studio', 'Wave & Co', 'Sol Mio'];

const sizes = <String>['XS', 'S', 'M', 'L', 'XL'];

const _coral = Color(0xFFFF6B6B);
const _lagoon = Color(0xFF00B4D8);
const _sun = Color(0xFFFFD166);
const _mint = Color(0xFF06D6A0);
const _violet = Color(0xFF7B61FF);
const _ink = Color(0xFF1B2A41);
const _pink = Color(0xFFFF8FB1);
const _sand = Color(0xFFF4D6B0);
const _white = Color(0xFFFFFFFF);
const _lime = Color(0xFFB8F35B);

final catalog = <Swimsuit>[
  Swimsuit(
    id: 's1', name: 'Lagoon Classic', brand: 'Coralé', type: SwimType.onePiece,
    colors: const [
      ColorVariant('Лагуна', _lagoon, _white, Print.solid),
      ColorVariant('Коралл', _coral, _sun, Print.solid),
      ColorVariant('Ночь', _ink, _lagoon, Print.waves),
    ],
    sizes: const ['XS', 'S', 'M', 'L', 'XL'],
    offers: const [Offer('breeze', 4290), Offer('aquastyle', 4490), Offer('seaside', 4190), Offer('swimshop', 4590, inStock: false)],
    rating: 4.8, reviews: 214, material: 'Полиамид 80%, эластан 20%', fit: 'Утягивающий',
    features: const ['UPF 50+', 'Съёмные чашки', 'Хлор-стойкий'],
    description: 'Базовый слитный купальник с глубоким вырезом на спине. Плотная ткань держит форму и не просвечивает.',
    isHit: true, priceHistory: const [4890, 4890, 4690, 4590, 4390, 4190],
  ),
  Swimsuit(
    id: 's2', name: 'Tropic Bloom', brand: 'Palma Studio', type: SwimType.bikini,
    colors: const [
      ColorVariant('Тропики', _mint, _pink, Print.tropic),
      ColorVariant('Закат', _coral, _sun, Print.tropic),
    ],
    sizes: const ['XS', 'S', 'M', 'L'],
    offers: const [Offer('aquastyle', 3290), Offer('beachbox', 3190), Offer('breeze', 3390)],
    rating: 4.7, reviews: 168, material: 'Переработанный нейлон', fit: 'Треугольный топ, низкая посадка',
    features: const ['Эко-ткань', 'Регулируемые завязки'],
    description: 'Яркий бикини с тропическим принтом из переработанного нейлона. Завязки на шее и бёдрах.',
    isHit: true, isNew: true, priceHistory: const [3590, 3590, 3490, 3390, 3290, 3190],
  ),
  Swimsuit(
    id: 's3', name: 'Marina Stripe', brand: 'Marea Lab', type: SwimType.tankini,
    colors: const [
      ColorVariant('Морская полоска', _white, _ink, Print.stripes),
      ColorVariant('Красная полоска', _white, _coral, Print.stripes),
    ],
    sizes: const ['S', 'M', 'L', 'XL'],
    offers: const [Offer('seaside', 3890), Offer('swimshop', 3790), Offer('breeze', 3990)],
    rating: 4.6, reviews: 97, material: 'Полиэстер 82%, эластан 18%', fit: 'Свободный топ, шорты',
    features: const ['Шорты с высокой талией', 'Быстро сохнет'],
    description: 'Танкини в морскую полоску: удобно и на пляже, и в бассейне с детьми.',
    priceHistory: const [3990, 3990, 3890, 3890, 3790, 3790],
  ),
  Swimsuit(
    id: 's4', name: 'Azure Cut', brand: 'Azure Muse', type: SwimType.monokini,
    colors: const [
      ColorVariant('Лазурь', _lagoon, _mint, Print.solid),
      ColorVariant('Чёрный', _ink, _sun, Print.solid),
      ColorVariant('Лайм', _lime, _ink, Print.solid),
    ],
    sizes: const ['XS', 'S', 'M'],
    offers: const [Offer('swimshop', 5490), Offer('aquastyle', 5290), Offer('beachbox', 5590)],
    rating: 4.9, reviews: 76, material: 'Итальянская лайкра', fit: 'Вырезы по бокам',
    features: const ['Премиум-ткань', 'Без косточек'],
    description: 'Монокини с геометричными вырезами. Выглядит как вечернее платье для пляжа.',
    isNew: true, priceHistory: const [5590, 5590, 5490, 5490, 5390, 5290],
  ),
  Swimsuit(
    id: 's5', name: 'Pool Pro', brand: 'Wave & Co', type: SwimType.sport,
    colors: const [
      ColorVariant('Электрик', _violet, _lime, Print.solid),
      ColorVariant('Графит', _ink, _coral, Print.solid),
    ],
    sizes: const ['XS', 'S', 'M', 'L', 'XL'],
    offers: const [Offer('breeze', 2990), Offer('swimshop', 2890), Offer('seaside', 3090)],
    rating: 4.5, reviews: 311, material: 'PBT, хлор-стойкий', fit: 'Спортивная спина',
    features: const ['Для бассейна', 'Хлор-стойкий', 'Фиксация груди'],
    description: 'Купальник для тренировок в бассейне: держит форму после сотни заплывов.',
    isHit: true, priceHistory: const [3290, 3190, 3090, 2990, 2990, 2890],
  ),
  Swimsuit(
    id: 's6', name: 'Sunset Wrap', brand: 'Sol Mio', type: SwimType.pareo,
    colors: const [
      ColorVariant('Песок', _sand, _coral, Print.waves),
      ColorVariant('Мята', _mint, _white, Print.dots),
    ],
    sizes: const ['ONE'],
    offers: const [Offer('beachbox', 1590), Offer('breeze', 1690)],
    rating: 4.4, reviews: 58, material: 'Вискоза', fit: 'Универсальный размер',
    features: const ['Лёгкая ткань', 'Можно носить как платье'],
    description: 'Парео, которое за минуту превращается в юбку или пляжное платье.',
    priceHistory: const [1790, 1790, 1690, 1690, 1590, 1590],
  ),
  Swimsuit(
    id: 's7', name: 'Polka Retro', brand: 'Coralé', type: SwimType.onePiece,
    colors: const [
      ColorVariant('Горошек', _coral, _white, Print.dots),
      ColorVariant('Тёмный горошек', _ink, _white, Print.dots),
    ],
    sizes: const ['S', 'M', 'L', 'XL'],
    offers: const [Offer('aquastyle', 4790), Offer('seaside', 4690)],
    rating: 4.8, reviews: 132, material: 'Полиамид 78%, эластан 22%', fit: 'Высокая талия, ретро',
    features: const ['Ретро-крой', 'Утяжка живота'],
    description: 'Купальник в стиле 50-х: горошек, высокая талия и мягкая утяжка.',
    isNew: true, priceHistory: const [4990, 4990, 4890, 4790, 4790, 4690],
  ),
  Swimsuit(
    id: 's8', name: 'Coral Reef', brand: 'Marea Lab', type: SwimType.bikini,
    colors: const [
      ColorVariant('Риф', _coral, _lagoon, Print.waves),
      ColorVariant('Солнце', _sun, _coral, Print.solid),
      ColorVariant('Мята', _mint, _ink, Print.solid),
    ],
    sizes: const ['XS', 'S', 'M', 'L'],
    offers: const [Offer('breeze', 3590), Offer('beachbox', 3490), Offer('swimshop', 3690)],
    rating: 4.6, reviews: 143, material: 'Полиамид 80%, эластан 20%', fit: 'Пуш-ап, средняя посадка',
    features: const ['Пуш-ап', 'Двусторонний'],
    description: 'Двусторонний бикини: две расцветки в одном купальнике.',
    isHit: true, priceHistory: const [3890, 3790, 3690, 3590, 3590, 3490],
  ),
  Swimsuit(
    id: 's9', name: 'Wave Rider', brand: 'Wave & Co', type: SwimType.sport,
    colors: const [
      ColorVariant('Волна', _lagoon, _white, Print.waves),
      ColorVariant('Неон', _pink, _violet, Print.stripes),
    ],
    sizes: const ['S', 'M', 'L'],
    offers: const [Offer('swimshop', 3390), Offer('aquastyle', 3490, inStock: false)],
    rating: 4.3, reviews: 49, material: 'Неопрен-лайт', fit: 'Длинный рукав',
    features: const ['Для сёрфинга', 'UPF 50+'],
    description: 'Купальник с длинным рукавом для сёрфинга и сапбординга, защищает от солнца.',
    isNew: true, priceHistory: const [3590, 3590, 3490, 3390, 3390, 3390],
  ),
  Swimsuit(
    id: 's10', name: 'Palm Shadow', brand: 'Palma Studio', type: SwimType.monokini,
    colors: const [
      ColorVariant('Пальма', _mint, _ink, Print.tropic),
      ColorVariant('Фиалка', _violet, _pink, Print.tropic),
    ],
    sizes: const ['XS', 'S', 'M', 'L'],
    offers: const [Offer('seaside', 4990), Offer('beachbox', 4890), Offer('breeze', 5090)],
    rating: 4.7, reviews: 88, material: 'Полиамид 82%, эластан 18%', fit: 'Вырез на талии',
    features: const ['Тропический принт', 'Мягкие чашки'],
    description: 'Монокини с тенями пальмовых листьев и вырезом на талии.',
    priceHistory: const [5290, 5190, 5090, 4990, 4990, 4890],
  ),
  Swimsuit(
    id: 's11', name: 'Lemon Splash', brand: 'Sol Mio', type: SwimType.bikini,
    colors: const [
      ColorVariant('Лимон', _sun, _mint, Print.dots),
      ColorVariant('Белый', _white, _sun, Print.dots),
    ],
    sizes: const ['XS', 'S', 'M'],
    offers: const [Offer('beachbox', 2790), Offer('aquastyle', 2890)],
    rating: 4.5, reviews: 64, material: 'Полиэстер 85%, эластан 15%', fit: 'Бандо',
    features: const ['Топ-бандо', 'Съёмные бретели'],
    description: 'Лимонный бикини с топом-бандо: ровный загар без следов от бретелей.',
    isNew: true, priceHistory: const [2990, 2990, 2890, 2890, 2790, 2790],
  ),
  Swimsuit(
    id: 's12', name: 'Deep Blue', brand: 'Azure Muse', type: SwimType.onePiece,
    colors: const [
      ColorVariant('Глубина', _ink, _lagoon, Print.solid),
      ColorVariant('Бирюза', _lagoon, _ink, Print.stripes),
    ],
    sizes: const ['S', 'M', 'L', 'XL'],
    offers: const [Offer('breeze', 5990), Offer('swimshop', 5790), Offer('seaside', 6090)],
    rating: 4.9, reviews: 121, material: 'Итальянская лайкра', fit: 'Корсетный',
    features: const ['Корсет', 'Премиум-ткань', 'UPF 50+'],
    description: 'Корсетный купальник с моделирующим эффектом. Подходит для фотосессий.',
    isHit: true, priceHistory: const [6490, 6290, 6190, 5990, 5890, 5790],
  ),
];

Swimsuit byId(String id) => catalog.firstWhere((s) => s.id == id);

class AppNotice {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final String? swimId;
  const AppNotice(this.icon, this.color, this.title, this.body, this.time, [this.swimId]);
}

const notices = <AppNotice>[
  AppNotice(Icons.trending_down_rounded, _mint, 'Цена снизилась', 'Lagoon Classic в магазине «Мода у моря» теперь 4 190 руб.', '2 ч назад', 's1'),
  AppNotice(Icons.local_shipping_outlined, _lagoon, 'Снова в наличии', 'Tropic Bloom появился в BeachBox, размеры S и M', '5 ч назад', 's2'),
  AppNotice(Icons.auto_awesome_rounded, _sun, 'Новинка бренда', 'Azure Muse выпустил коллекцию Azure Cut', 'вчера', 's4'),
  AppNotice(Icons.luggage_outlined, _coral, 'Собираем чемодан', 'До отпуска 14 дней: в списке «На отпуск» 3 вещи', '2 дня назад'),
  AppNotice(Icons.favorite_rounded, _pink, 'Ваш отзыв полезен', 'Отзыв о Pool Pro отметили 12 человек', '3 дня назад', 's5'),
];

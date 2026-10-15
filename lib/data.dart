import 'package:flutter/material.dart';

/// Демо-данные Lagoona. Бренды и магазины вымышленные.

enum SwimType { onePiece, bikini, monokini, sport }

extension SwimTypeX on SwimType {
  String get title => switch (this) {
        SwimType.onePiece => 'Слитные',
        SwimType.bikini => 'Бикини',
        SwimType.monokini => 'Монокини',
        SwimType.sport => 'Спортивные',
      };

  String get single => switch (this) {
        SwimType.onePiece => 'Слитный купальник',
        SwimType.bikini => 'Бикини',
        SwimType.monokini => 'Монокини',
        SwimType.sport => 'Спортивный купальник',
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
  final List<String> photos;
  /// Куда смещать кадр по вертикали: -1 верх фото, 1 низ.
  final double focus;
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
    required this.photos,
    this.focus = -0.2,
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

const brands = <String>['Caribe Sol', 'Bahía Swim', 'Mango Tango', 'Palma Brava', 'Ola Viva', 'Punta Coral'];

const sizes = <String>['XS', 'S', 'M', 'L', 'XL'];

const _coral = Color(0xFFFF6B6B);
const _lagoon = Color(0xFF00B4D8);
const _sun = Color(0xFFFFD166);
const _mint = Color(0xFF06D6A0);
const _ink = Color(0xFF1B2A41);
const _pink = Color(0xFFFF8FB1);
const _white = Color(0xFFFFFFFF);

Swimsuit _s({
  required String id,
  required String name,
  required String brand,
  required SwimType type,
  required String photo,
  double focus = -0.2,
  required ColorVariant color,
  required List<String> sizes,
  required List<Offer> offers,
  required double rating,
  required int reviews,
  required String material,
  required String fit,
  required List<String> features,
  required String description,
  bool isNew = false,
  bool isHit = false,
  required List<int> history,
}) =>
    Swimsuit(
      id: id,
      name: name,
      brand: brand,
      type: type,
      colors: [color],
      photos: ['assets/photos/$photo.jpg'],
      focus: focus,
      sizes: sizes,
      offers: offers,
      rating: rating,
      reviews: reviews,
      material: material,
      fit: fit,
      features: features,
      description: description,
      isNew: isNew,
      isHit: isHit,
      priceHistory: history,
    );

final catalog = <Swimsuit>[
  _s(
    id: 's1', name: 'Hibiscus', brand: 'Caribe Sol', type: SwimType.onePiece, photo: 'p032',
    color: const ColorVariant('Чёрный с гибискусом', _ink, _pink, Print.tropic),
    sizes: const ['XS', 'S', 'M', 'L', 'XL'],
    offers: const [Offer('breeze', 4290), Offer('aquastyle', 4490), Offer('seaside', 4190), Offer('swimshop', 4590, inStock: false)],
    rating: 4.8, reviews: 214, material: 'Полиамид 80%, эластан 20%', fit: 'Вырез на груди, средняя посадка',
    features: const ['UPF 50+', 'Съёмные чашки', 'Цветочный принт'],
    description: 'Слитный купальник с крупными цветами гибискуса на чёрном. Вырез-капля на груди и открытая спина.',
    isHit: true, history: const [4890, 4890, 4690, 4590, 4390, 4190],
  ),
  _s(
    id: 's2', name: 'Tropic Bloom', brand: 'Palma Brava', type: SwimType.bikini, photo: 'p019',
    color: const ColorVariant('Тропические листья', _mint, _ink, Print.tropic),
    sizes: const ['XS', 'S', 'M', 'L'],
    offers: const [Offer('aquastyle', 3290), Offer('beachbox', 3190), Offer('breeze', 3390)],
    rating: 4.7, reviews: 168, material: 'Переработанный нейлон', fit: 'Треугольный топ, средняя посадка',
    features: const ['Эко-ткань', 'Контрастный кант'],
    description: 'Бикини с принтом тропических листьев и неоновым кантом. Ткань из переработанного нейлона.',
    isHit: true, isNew: true, history: const [3590, 3590, 3490, 3390, 3290, 3190],
  ),
  _s(
    id: 's3', name: 'Mango Limón', brand: 'Mango Tango', type: SwimType.bikini, photo: 'p040',
    color: const ColorVariant('Лимонный', _sun, _ink, Print.dots),
    sizes: const ['XS', 'S', 'M'],
    offers: const [Offer('beachbox', 2790), Offer('aquastyle', 2890), Offer('seaside', 2990)],
    rating: 4.8, reviews: 132, material: 'Полиэстер 85%, эластан 15%', fit: 'Треугольный топ, высокий вырез бедра',
    features: const ['Яркий цвет', 'Быстро сохнет'],
    description: 'Сочный лимонный бикини с мелким принтом. Высокий вырез бедра визуально удлиняет ноги.',
    isHit: true, history: const [3190, 3090, 2990, 2890, 2790, 2790],
  ),
  _s(
    id: 's4', name: 'Coral Paisley', brand: 'Punta Coral', type: SwimType.bikini, photo: 'p116',
    color: const ColorVariant('Коралловый пейсли', _coral, _white, Print.waves),
    sizes: const ['XS', 'S', 'M', 'L'],
    offers: const [Offer('seaside', 3490), Offer('breeze', 3590), Offer('swimshop', 3390)],
    rating: 4.6, reviews: 97, material: 'Полиамид 82%, эластан 18%', fit: 'Топ с узлом, завязки на бёдрах',
    features: const ['Регулируемые завязки', 'Мягкие чашки'],
    description: 'Коралловый бикини с белым узором пейсли и узлом на топе. Завязки по бокам подгоняют посадку.',
    isNew: true, history: const [3690, 3690, 3590, 3490, 3390, 3390],
  ),
  _s(
    id: 's5', name: 'Polka Retro', brand: 'Caribe Sol', type: SwimType.bikini, photo: 'p015',
    color: const ColorVariant('Красный горошек', _coral, _white, Print.dots),
    sizes: const ['S', 'M', 'L', 'XL'],
    offers: const [Offer('aquastyle', 4790), Offer('seaside', 4690), Offer('beachbox', 4890)],
    rating: 4.9, reviews: 241, material: 'Полиамид 78%, эластан 22%', fit: 'Высокая талия, ретро',
    features: const ['Высокая талия', 'Утяжка живота'],
    description: 'Ретро-бикини в красный горошек: трусики с высокой талией и мягкой утяжкой, топ на широких бретелях.',
    isHit: true, history: const [4990, 4990, 4890, 4790, 4790, 4690],
  ),
  _s(
    id: 's6', name: 'Ruby Strap', brand: 'Ola Viva', type: SwimType.bikini, photo: 'p038',
    color: const ColorVariant('Рубиновый', Color(0xFFD7263D), _white, Print.solid),
    sizes: const ['XS', 'S', 'M', 'L'],
    offers: const [Offer('breeze', 3590), Offer('beachbox', 3490), Offer('swimshop', 3690)],
    rating: 4.7, reviews: 143, material: 'Полиамид 80%, эластан 20%', fit: 'Пуш-ап, стрепы на бёдрах',
    features: const ['Пуш-ап', 'Перекрёстные стрепы'],
    description: 'Рубиновый бикини с запахом на топе и перекрёстными стрепами на трусиках.',
    isHit: true, history: const [3890, 3790, 3690, 3590, 3590, 3490],
  ),
  _s(
    id: 's7', name: 'Flamenco Frill', brand: 'Bahía Swim', type: SwimType.bikini, photo: 'p008',
    color: const ColorVariant('Тёмно-синий с цветами', _ink, _pink, Print.tropic),
    sizes: const ['XS', 'S', 'M', 'L'],
    offers: const [Offer('swimshop', 3290), Offer('aquastyle', 3390)],
    rating: 4.6, reviews: 88, material: 'Полиэстер 82%, эластан 18%', fit: 'Топ с воланом, низкая посадка',
    features: const ['Волан', 'Цветочный принт'],
    description: 'Бикини с воланом на топе и розовыми цветами на тёмно-синем. Волан скрывает и добавляет объём.',
    isNew: true, history: const [3490, 3490, 3390, 3390, 3290, 3290],
  ),
  _s(
    id: 's8', name: 'Noche Floral', brand: 'Bahía Swim', type: SwimType.bikini, photo: 'p126',
    color: const ColorVariant('Чёрный с цветами', _ink, _coral, Print.tropic),
    sizes: const ['XS', 'S', 'M', 'L', 'XL'],
    offers: const [Offer('breeze', 3390), Offer('seaside', 3290), Offer('beachbox', 3490)],
    rating: 4.5, reviews: 76, material: 'Полиамид 80%, эластан 20%', fit: 'Топ с воланом, завязки',
    features: const ['Волан', 'Регулируемые бретели'],
    description: 'Чёрный бикини с коралловыми цветами и воланом. Подходит для отпуска и вечерней фотосессии.',
    history: const [3590, 3490, 3490, 3390, 3290, 3290],
  ),
  _s(
    id: 's9', name: 'Neon Pop', brand: 'Ola Viva', type: SwimType.bikini, photo: 'p041',
    color: const ColorVariant('Мята и розовый', _mint, _pink, Print.solid),
    sizes: const ['XS', 'S', 'M'],
    offers: const [Offer('beachbox', 2990), Offer('swimshop', 3090), Offer('aquastyle', 3190, inStock: false)],
    rating: 4.6, reviews: 112, material: 'Неопрен-лайт', fit: 'Топ на косточках, средняя посадка',
    features: const ['Колор-блок', 'Плотная ткань'],
    description: 'Колор-блок бикини: мятные трусики и топ с розовыми вставками. Плотная ткань держит форму.',
    isNew: true, history: const [3290, 3190, 3190, 3090, 2990, 2990],
  ),
  _s(
    id: 's10', name: 'Mint Cut', brand: 'Mango Tango', type: SwimType.monokini, photo: 'p042',
    color: const ColorVariant('Мятный', Color(0xFF5FE3A1), _ink, Print.solid),
    sizes: const ['XS', 'S', 'M', 'L'],
    offers: const [Offer('swimshop', 5490), Offer('aquastyle', 5290), Offer('beachbox', 5590)],
    rating: 4.9, reviews: 64, material: 'Итальянская лайкра', fit: 'Вырез на талии, высокий вырез бедра',
    features: const ['Премиум-ткань', 'Без косточек'],
    description: 'Мятный монокини с вырезом на талии. Цвет особенно эффектно смотрится на загаре.',
    isNew: true, history: const [5590, 5590, 5490, 5490, 5390, 5290],
  ),
  _s(
    id: 's11', name: 'Coral Sport', brand: 'Ola Viva', type: SwimType.sport, photo: 'p071', focus: 0.75,
    color: const ColorVariant('Розовый коралл', _pink, _white, Print.dots),
    sizes: const ['XS', 'S', 'M', 'L', 'XL'],
    offers: const [Offer('breeze', 2990), Offer('swimshop', 2890), Offer('seaside', 3090)],
    rating: 4.5, reviews: 311, material: 'PBT, хлор-стойкий', fit: 'Спортивная спина',
    features: const ['Для бассейна', 'Хлор-стойкий', 'Фиксация груди'],
    description: 'Спортивный купальник для бассейна и активного отдыха: держит форму после сотни заплывов.',
    isHit: true, history: const [3290, 3190, 3090, 2990, 2990, 2890],
  ),
  _s(
    id: 's12', name: 'Blanca Cut', brand: 'Punta Coral', type: SwimType.monokini, photo: 'p024',
    color: const ColorVariant('Белый', _white, _lagoon, Print.solid),
    sizes: const ['XS', 'S', 'M'],
    offers: const [Offer('seaside', 4990), Offer('beachbox', 4890), Offer('breeze', 5090)],
    rating: 4.7, reviews: 93, material: 'Полиамид 82%, эластан 18%', fit: 'Халтер, вырезы на талии',
    features: const ['Халтер', 'Не просвечивает'],
    description: 'Белоснежный монокини с халтером и фигурными вырезами. Двойной слой ткани не просвечивает.',
    isNew: true, history: const [5290, 5190, 5090, 4990, 4990, 4890],
  ),
  _s(
    id: 's13', name: 'Arcoíris Stripe', brand: 'Caribe Sol', type: SwimType.bikini, photo: 'p096',
    color: const ColorVariant('Радужная полоска', _sun, _coral, Print.stripes),
    sizes: const ['XS', 'S', 'M', 'L'],
    offers: const [Offer('aquastyle', 3190), Offer('breeze', 3290)],
    rating: 4.4, reviews: 58, material: 'Полиэстер 85%, эластан 15%', fit: 'Топ-бандо, низкая посадка',
    features: const ['Топ-бандо', 'Съёмные бретели'],
    description: 'Бикини в разноцветную полоску с топом-бандо: ровный загар без следов от бретелей.',
    history: const [3390, 3390, 3290, 3290, 3190, 3190],
  ),
  _s(
    id: 's14', name: 'Laguna Twist', brand: 'Palma Brava', type: SwimType.bikini, photo: 'p057',
    color: const ColorVariant('Лагуна', _lagoon, _pink, Print.tropic),
    sizes: const ['XS', 'S', 'M', 'L'],
    offers: const [Offer('beachbox', 3390), Offer('seaside', 3490), Offer('swimshop', 3590)],
    rating: 4.6, reviews: 71, material: 'Переработанный нейлон', fit: 'Твист-топ, классическая посадка',
    features: const ['Эко-ткань', 'Твист на топе'],
    description: 'Твист-топ с бирюзовым тропическим принтом и однотонные чёрные трусики.',
    history: const [3690, 3590, 3590, 3490, 3390, 3390],
  ),
  _s(
    id: 's15', name: 'Turquesa', brand: 'Bahía Swim', type: SwimType.onePiece, photo: 'p020',
    color: const ColorVariant('Бирюзовый', Color(0xFF0FA3A3), _ink, Print.solid),
    sizes: const ['S', 'M', 'L', 'XL'],
    offers: const [Offer('breeze', 5990), Offer('swimshop', 5790), Offer('seaside', 6090)],
    rating: 4.9, reviews: 121, material: 'Итальянская лайкра', fit: 'Высокий вырез бедра, глубокая спина',
    features: const ['Премиум-ткань', 'UPF 50+'],
    description: 'Бирюзовый слитный купальник с высоким вырезом бедра. Минимализм, который работает на загар.',
    isHit: true, history: const [6490, 6290, 6190, 5990, 5890, 5790],
  ),
  _s(
    id: 's16', name: 'Isla Floral', brand: 'Palma Brava', type: SwimType.bikini, photo: 'p120',
    color: const ColorVariant('Цветочный', _pink, _lagoon, Print.tropic),
    sizes: const ['XS', 'S', 'M'],
    offers: const [Offer('aquastyle', 2890), Offer('beachbox', 2790)],
    rating: 4.5, reviews: 49, material: 'Полиэстер 82%, эластан 18%', fit: 'Треугольный топ, завязки',
    features: const ['Лёгкая ткань', 'Завязки'],
    description: 'Лёгкий бикини с акварельными цветами. Завязки на шее, спине и бёдрах.',
    isNew: true, history: const [2990, 2990, 2890, 2890, 2790, 2790],
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
  AppNotice(Icons.trending_down_rounded, _mint, 'Цена снизилась', 'Hibiscus в магазине «Мода у моря» теперь 4 190 руб.', '2 ч назад', 's1'),
  AppNotice(Icons.local_shipping_outlined, _lagoon, 'Снова в наличии', 'Tropic Bloom появился в BeachBox, размеры S и M', '5 ч назад', 's2'),
  AppNotice(Icons.auto_awesome_rounded, _sun, 'Новинка бренда', 'Punta Coral выпустил монокини Blanca Cut', 'вчера', 's12'),
  AppNotice(Icons.luggage_outlined, _coral, 'Собираем чемодан', 'До отпуска 14 дней: в списке «На отпуск» 3 вещи', '2 дня назад'),
  AppNotice(Icons.favorite_rounded, _pink, 'Ваш отзыв полезен', 'Отзыв о Coral Sport отметили 12 человек', '3 дня назад', 's11'),
];

import 'package:app1/pages/basket_page.dart';
import 'package:app1/pages/favorite.dart';
import 'package:app1/pages/profile.dart';
import 'package:flutter/material.dart';
import 'models/note.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Вкусняшки',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  Set<Sweet> favoriteSweets = <Sweet>{};
  Set<Sweet> basketItems = <Sweet>{};

  static const List<Widget> _widgetTitles = [
    Text('Главная'),
    Text('Избранное'),
    Text('Корзина'),
    Text('Профиль'),
  ];

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    _widgetOptions = <Widget>[
      HomePage(
        favoriteSweets: favoriteSweets,
        onFavoriteChanged: _onFavoriteChanged,
        onAddToBasket: _addToBasket,
      ),
      FavoritePage(
        favoriteSweets: favoriteSweets,
        onFavoriteChanged: _onFavoriteChanged,
      ),
      BasketPage(
        basketItems: basketItems,
        onRemoveFromBasket: _removeFromBasket,
      ),
      const ProfilePage(),
    ];
  }

  void _onFavoriteChanged(Sweet sweet, bool isFavorite) {
    setState(() {
      if (isFavorite) {
        favoriteSweets.add(sweet);
      } else {
        favoriteSweets.remove(sweet);
      }
    });
  }

  void _addToBasket(Sweet sweet) {
    setState(() {
      basketItems.add(sweet);
    });
  }

  void _removeFromBasket(Sweet sweet) {
    setState(() {
      basketItems.remove(sweet);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 32, 100, 156),
        unselectedItemColor: const Color.fromARGB(255, 32, 100, 156),
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}

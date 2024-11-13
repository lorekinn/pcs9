import 'package:flutter/material.dart';
import '../models/note.dart';
import '../components/item_note.dart';
import '../pages/note_page.dart';
import '../api/api.dart';

class HomePage extends StatefulWidget {
  final Set<Sweet> favoriteSweets;
  final Function(Sweet, bool) onFavoriteChanged;
  final Function(Sweet) onAddToBasket;

  const HomePage({
    Key? key,
    required this.favoriteSweets,
    required this.onFavoriteChanged,
    required this.onAddToBasket,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  List<Sweet> sweets = [];

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandController = TextEditingController();
  final _flavorController = TextEditingController();
  final _ingredientsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final products = await apiService.getProducts();
      setState(() {
        sweets = products;
      });
    } catch (e) {
      print("Ошибка при загрузке продуктов: $e");
    }
  }

  Future<void> _deleteProduct(Sweet sweet) async {
    try {
      await apiService.deleteProduct(sweet.id);
      await fetchProducts();
    } catch (e) {
      print("Ошибка при удалении продукта: $e");
    }
  }

  void _toggleFavorite(Sweet sweet) {
    final isFavorite = widget.favoriteSweets.contains(sweet);
    widget.onFavoriteChanged(sweet, !isFavorite);
    setState(() {});
  }

  Future<void> _addNewSweet() async {
    final newSweet = Sweet(
      id: 0,
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: _imageUrlController.text,
      price: int.tryParse(_priceController.text) ?? 0,
      brand: _brandController.text,
      flavor: _flavorController.text,
      ingredients: _ingredientsController.text,
      isFavorite: false,
    );

    try {
      await apiService.createProduct(newSweet);
      await fetchProducts();
    } catch (e) {
      print("Ошибка при добавлении продукта: $e");
    }

    _nameController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
    _priceController.clear();
    _brandController.clear();
    _flavorController.clear();
    _ingredientsController.clear();
  }

  void _showAddSweetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Добавить новый товар'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Описание'),
                ),
                TextField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL изображения'),
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Цена'),
                ),
                TextField(
                  controller: _brandController,
                  decoration: const InputDecoration(labelText: 'Бренд'),
                ),
                TextField(
                  controller: _flavorController,
                  decoration: const InputDecoration(labelText: 'Вкус'),
                ),
                TextField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(labelText: 'Ингредиенты'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _addNewSweet();
                Navigator.of(context).pop();
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Вкусняшки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSweetDialog(context),
          ),
        ],
      ),
      body: sweets.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: sweets.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 2 / 3,
        ),
        itemBuilder: (context, index) {
          final sweet = sweets[index];
          final isFavorite = widget.favoriteSweets.contains(sweet);

          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        sweet: sweet,
                        onDelete: () async {
                          await _deleteProduct(sweet);
                          await fetchProducts();
                        },
                      ),
                    ),
                  );
                },
                child: Item(sweet: sweet),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    _toggleFavorite(sweet);
                    setState(() {});
                  },
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    widget.onAddToBasket(sweet);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${sweet.name} добавлен в корзину'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

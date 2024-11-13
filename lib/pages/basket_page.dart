import 'package:flutter/material.dart';
import '../models/note.dart';

class BasketPage extends StatefulWidget {
  final Set<Sweet> basketItems;
  final Function(Sweet) onRemoveFromBasket;

  const BasketPage({
    Key? key,
    required this.basketItems,
    required this.onRemoveFromBasket,
  }) : super(key: key);

  @override
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  int getTotalPrice() {
    return widget.basketItems.fold(
        0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _increaseQuantity(Sweet sweet) {
    setState(() {
      sweet.quantity++;
    });
  }

  void _decreaseQuantity(Sweet sweet) {
    setState(() {
      if (sweet.quantity > 1) {
        sweet.quantity--;
      } else {
        widget.onRemoveFromBasket(sweet);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = getTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: widget.basketItems.isEmpty
          ? const Center(child: Text("Ваша корзина пуста"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.basketItems.length,
              itemBuilder: (context, index) {
                final sweet = widget.basketItems.elementAt(index);
                return ListTile(
                  leading: Image.network(sweet.imageUrl, width: 50, height: 50),
                  title: Text(sweet.name),
                  subtitle: Text('${sweet.price} рублей x ${sweet.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _decreaseQuantity(sweet),
                      ),
                      Text(sweet.quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _increaseQuantity(sweet),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Общая сумма: $totalPrice рублей',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: widget.basketItems.isNotEmpty ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Оплата временно недоступна')),
                    );
                  } : null,
                  child: const Text('Оплатить'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

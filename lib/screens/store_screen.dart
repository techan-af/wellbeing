import 'package:flutter/material.dart';

class StoreScreen extends StatefulWidget {
  final int points;
  final Function(int)? onPointsUpdated;

  const StoreScreen({Key? key, required this.points, this.onPointsUpdated}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  // Sample products
  final List<Product> products = [
    Product(
      id: 1,
      name: 'Premium T-Shirt',
      description: 'Comfortable cotton t-shirt with wellbeing logo',
      price: 150,
      image: 'assets/store/tshirt.jpg',
    ),
    Product(
      id: 2,
      name: 'Designer Pen',
      description: 'Elegant ballpoint pen with ergonomic grip',
      price: 80,
      image: 'assets/store/pen.jpg',
    ),
    Product(
      id: 3,
      name: 'Journal Diary',
      description: 'Hardcover notebook for your daily reflections',
      price: 120,
      image: 'assets/store/diary.jpg',
    ),
    Product(
      id: 4,
      name: 'Water Bottle',
      description: 'Insulated stainless steel bottle',
      price: 200,
      image: 'assets/store/bottle.jpg',
    ),
    Product(
      id: 5,
      name: 'Sticker Pack',
      description: 'Set of motivational stickers',
      price: 50,
      image: 'assets/store/stickers.jpg',
    ),
    Product(
      id: 6,
      name: 'Coffee Mug',
      description: 'Ceramic mug with inspirational quote',
      price: 100,
      image: 'assets/store/mug.jpg',
    ),
  ];

  void _purchaseProduct(int productId) {
    final product = products.firstWhere((p) => p.id == productId);
    
    if (widget.points >= product.price) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Purchase Confirmation'),
          content: Text('Confirm purchase of ${product.name} for ${product.price} points?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
                if (widget.onPointsUpdated != null) {
                  widget.onPointsUpdated!(widget.points - product.price);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Purchased ${product.name}!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough points for ${product.name}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Store'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.points}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Points balance card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Balance:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    backgroundColor: Colors.amber[100],
                    label: Text(
                      '${widget.points} pts',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Product grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductCard(product);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final canAfford = widget.points >= product.price;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _purchaseProduct(product.id),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image placeholder
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  image: DecorationImage(
                    image: AssetImage(product.image),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                product.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      '${product.price} pts',
                      style: TextStyle(
                        color: canAfford ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: canAfford
                        ? Colors.green[50]
                        : Colors.red[50],
                  ),
                  Icon(
                    canAfford ? Icons.shopping_cart : Icons.lock,
                    color: canAfford ? Colors.green : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });
}
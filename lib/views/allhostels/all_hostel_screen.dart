import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  static const Color kGreen = Color(0xFF1D9E75);
  static const Color kBg = Color(0xFFF5F6FA);
  static const Color kCard = Colors.white;

  final List<Map<String, dynamic>> orders = [
    {
      'id': '#FTH001',
      'date': '16 May 2026',
      'amount': '₹320',
      'itemCount': 5,
      'image': 'https://cdn-icons-png.flaticon.com/512/135/135620.png',
      'products': [
        {'name': 'Tomato', 'qty': 2, 'price': 40, 'unit': 'kg'},
        {'name': 'Potato', 'qty': 1, 'price': 30, 'unit': 'kg'},
        {'name': 'Onion', 'qty': 3, 'price': 35, 'unit': 'kg'},
        {'name': 'Carrot', 'qty': 1, 'price': 45, 'unit': 'kg'},
        {'name': 'Cucumber', 'qty': 2, 'price': 25, 'unit': 'kg'},
      ],
    },
    {
      'id': '#FTH002',
      'date': '15 May 2026',
      'amount': '₹450',
      'itemCount': 4,
      'image': 'https://cdn-icons-png.flaticon.com/512/415/415682.png',
      'products': [
        {'name': 'Apple', 'qty': 2, 'price': 120, 'unit': 'kg'},
        {'name': 'Banana', 'qty': 2, 'price': 50, 'unit': 'dozen'},
        {'name': 'Orange', 'qty': 3, 'price': 80, 'unit': 'kg'},
        {'name': 'Grapes', 'qty': 1, 'price': 60, 'unit': 'kg'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kCard,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Order History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kGreen,
          ),
        ),
      ),
      body: _buildOrderList(orders),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders found',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (_, index) {
        final order = orders[index];
        final products = order['products'] as List;
        final displayProducts = products.take(2).toList();
        final remainingCount = products.length - 2;

        return GestureDetector(
          onTap: () => _showOrderDetailsModal(context, order),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAEAEA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.network(
                          order['image'],
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Order Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order ID
                          Text(
                            order['id'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2C2A),
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Number of items
                          Text(
                            '${order['itemCount']} items',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Product List with Qty (Show first 2 products)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              ...displayProducts.map(
                                (e) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${e['name']} x${e['qty']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF5F5E5A),
                                    ),
                                  ),
                                ),
                              ),
                              if (remainingCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '+$remainingCount more',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: kGreen,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Date + Amount
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order['date'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                order['amount'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // View Details Button
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 16,
                      color: kGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'View All Items',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOrderDetailsModal(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    final products = order['products'] as List;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order ${order['id']}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C2C2A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order['date'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Products List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final price = product['price'] ?? 0;
                    final total = price * (product['qty'] as int);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Product Icon/Placeholder
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.production_quantity_limits,
                              size: 30,
                              color: kGreen,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Product Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C2C2A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  product['unit'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quantity and Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Text(
                                  'x${product['qty']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (price > 0)
                                Text(
                                  '₹$total',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: kGreen,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Items',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '${order['itemCount']} items',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          order['amount'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

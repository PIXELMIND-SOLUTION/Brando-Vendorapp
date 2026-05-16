import 'package:brando_vendor/views/allhostels/all_hostel_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  int selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final List<Map<String, dynamic>> categories = [
    {'label': 'Vegetables', 'icon': '🥦'},
    {'label': 'Groceries', 'icon': '🛒'},
    {'label': 'Fruits', 'icon': '🍎'},
    {'label': 'Dairy', 'icon': '🥛'},
  ];

  // Add this method to your _GroceryScreenState class

  void _showDeliveryLocationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeliveryLocationSheet(),
    );
  }

  final List<Map<String, dynamic>> products = [
    {
      "category": "Vegetables",
      "name": "Tomato",
      "price": 40,
      "unit": "1 Kg",
      "image": "https://cdn-icons-png.flaticon.com/512/135/135620.png",
      "qty": 0,
    },
    {
      "category": "Vegetables",
      "name": "Potato",
      "price": 30,
      "unit": "1 Kg",
      "image": "https://cdn-icons-png.flaticon.com/512/765/765547.png",
      "qty": 0,
    },
    {
      "category": "Vegetables",
      "name": "Onion",
      "price": 25,
      "unit": "1 Kg",
      "image": "https://cdn-icons-png.flaticon.com/512/2153/2153790.png",
      "qty": 0,
    },
    {
      "category": "Groceries",
      "name": "Rice",
      "price": 60,
      "unit": "1 Kg",
      "image": "https://cdn-icons-png.flaticon.com/512/3081/3081967.png",
      "qty": 0,
    },
    {
      "category": "Groceries",
      "name": "Sugar",
      "price": 45,
      "unit": "1 Kg",
      "image": "https://cdn-icons-png.flaticon.com/512/1046/1046784.png",
      "qty": 0,
    },
    {
      "category": "Groceries",
      "name": "Salt",
      "price": 20,
      "unit": "1 Kg",
      "image": "https://cdn-icons-png.flaticon.com/512/1046/1046786.png",
      "qty": 0,
    },
    {
      "category": "Fruits",
      "name": "Apple",
      "price": 120,
      "unit": "1 Kg",
      "image": "https://cdn-icons-png.flaticon.com/512/415/415682.png",
      "qty": 0,
    },
    {
      "category": "Fruits",
      "name": "Banana",
      "price": 50,
      "unit": "1 Doz",
      "image": "https://cdn-icons-png.flaticon.com/512/2909/2909761.png",
      "qty": 0,
    },
    {
      "category": "Dairy",
      "name": "Milk",
      "price": 55,
      "unit": "1 L",
      "image": "https://cdn-icons-png.flaticon.com/512/3050/3050141.png",
      "qty": 0,
    },
    {
      "category": "Dairy",
      "name": "Curd",
      "price": 35,
      "unit": "400 g",
      "image": "https://cdn-icons-png.flaticon.com/512/3081/3081931.png",
      "qty": 0,
    },
  ];

  static const Color kGreen = Color(0xFF1D9E75);
  static const Color kGreenLight = Color(0xFFEAF3DE);
  static const Color kGreenDark = Color(0xFF0F6E56);
  static const Color kBg = Color(0xFFF5F6FA);
  static const Color kCard = Colors.white;

  List<Map<String, dynamic>> get filteredProducts {
    final catLabel = categories[selectedCategory]['label'] as String;
    return products.where((p) {
      final matchCat = p['category'] == catLabel;
      final matchSearch =
          searchQuery.isEmpty ||
          (p['name'] as String).toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
      return matchCat && matchSearch;
    }).toList();
  }

  List<Map<String, dynamic>> get cartItems =>
      products.where((p) => (p['qty'] as int) > 0).toList();

  int get totalItems => products.fold(0, (s, p) => s + (p['qty'] as int));

  double get totalPrice =>
      products.fold(0.0, (s, p) => s + (p['price'] as int) * (p['qty'] as int));

  void updateQty(String name, bool increase) {
    setState(() {
      final p = products.firstWhere((x) => x['name'] == name);
      if (increase) {
        p['qty']++;
      } else if ((p['qty'] as int) > 0) {
        p['qty']--;
      }
    });
  }

  void removeItem(String name) {
    setState(() {
      final p = products.firstWhere((x) => x['name'] == name);
      p['qty'] = 0;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCartModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Cart',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2A),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            for (var item in cartItems) {
                              item['qty'] = 0;
                            }
                          });
                          setModalState(() {});
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24, thickness: 0.5),
                // Cart items list
                Expanded(
                  child: cartItems.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 64,
                                color: Color(0xFFD3D1C7),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Your cart is empty',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFB4B2A9),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return _buildCartItemCard(item, setModalState);
                          },
                        ),
                ),
                // Total and Checkout
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kCard,
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFFEEEEEE),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C2C2A),
                            ),
                          ),
                          Text(
                            '₹${totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
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
                          onPressed: cartItems.isEmpty
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  // Add your checkout logic here
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Proceeding to checkout...',
                                      ),
                                      backgroundColor: kGreen,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreen,
                            disabledBackgroundColor: const Color(0xFFD3D1C7),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItemCard(
    Map<String, dynamic> item,
    StateSetter setModalState,
  ) {
    final qty = item['qty'] as int;
    final price = item['price'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['image'] as String,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFFD3D1C7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['unit'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888780),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹$price',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kGreenDark,
                  ),
                ),
              ],
            ),
          ),
          // Quantity controls and remove
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Remove button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        removeItem(item['name'] as String);
                      });
                      setModalState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Quantity controls
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _qtyButton(
                          icon: Icons.remove,
                          onTap: () {
                            setState(() {
                              updateQty(item['name'] as String, false);
                            });
                            setModalState(() {});
                          },
                          enabled: qty > 0,
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '$qty',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2C2A),
                            ),
                          ),
                        ),
                        _qtyButton(
                          icon: Icons.add,
                          onTap: () {
                            setState(() {
                              updateQty(item['name'] as String, true);
                            });
                            setModalState(() {});
                          },
                          enabled: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₹${price * qty}',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearch(),
          _buildCategories(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              categories[selectedCategory]['label'] as String,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888780),
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(child: _buildProductList()),
        ],
      ),
      bottomNavigationBar: _buildBottomPanel(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kCard,
      elevation: 0,
      centerTitle: true,
      leading: const BackButton(color: Colors.black),

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/home.png', height: 38, width: 38),

          const SizedBox(width: 8),

          const Text(
            'Farm to Home',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 9, 202, 13),
            ),
          ),
        ],
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderHistoryScreen(),
                  ),
                );
              },
              child: const Text(
                'My Orders',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],

      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0.5),
        child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFE0E0E0)),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(color: Color(0xFFB4B2A9), fontSize: 14),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFFB4B2A9),
            size: 20,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFFB4B2A9),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: kCard,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kGreen, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final isSelected = selectedCategory == i;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? kGreen : kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? kGreen : const Color(0xFFE0E0E0),
                  width: 0.5,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categories[i]['icon'] as String,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    categories[i]['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF5F5E5A),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList() {
    final list = filteredProducts;
    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFD3D1C7)),
            SizedBox(height: 12),
            Text(
              'No products found',
              style: TextStyle(color: Color(0xFFB4B2A9), fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildProductCard(list[i]),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final qty = product['qty'] as int;
    final hasQty = qty > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasQty ? const Color(0xFF9FE1CB) : const Color(0xFFEEEEEE),
          width: hasQty ? 1.0 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 95,
            height: 95,
            decoration: BoxDecoration(
              color: hasQty ? kGreenLight : const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.network(
                product['image'] as String,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFFD3D1C7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  product['unit'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888780),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '₹${product['price']}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kGreenDark,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _qtyButton(
                        icon: Icons.remove,
                        onTap: () =>
                            updateQty(product['name'] as String, false),
                        enabled: qty > 0,
                      ),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '$qty',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2A),
                          ),
                        ),
                      ),
                      _qtyButton(
                        icon: Icons.add,
                        onTap: () => updateQty(product['name'] as String, true),
                        enabled: true,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 42,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    qty > 0 ? '₹${(product['price'] as int) * qty}' : '₹0',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: qty > 0 ? kGreen : const Color(0xFFB4B2A9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? const Color(0xFF5F5E5A) : const Color(0xFFD3D1C7),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final cart = cartItems;
    final hasItems = cart.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: kCard,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basket header
              Row(
                children: [
                  const Text(
                    'Your basket',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF888780),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: hasItems ? kGreenLight : const Color(0xFFF1EFE8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$totalItems item${totalItems != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: hasItems
                            ? const Color(0xFF3B6D11)
                            : const Color(0xFF888780),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Cart chips or empty hint
              if (!hasItems)
                const Text(
                  'Add items to see them here',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB4B2A9),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cart.length,
                    itemBuilder: (_, i) {
                      final item = cart[i];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Image.network(
                                item['image'] as String,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const SizedBox(),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              item['name'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2C2C2A),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '×${item['qty']}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: kGreen,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 12),
              const Divider(
                height: 0.5,
                thickness: 0.5,
                color: Color(0xFFEEEEEE),
              ),
              const SizedBox(height: 12),

              // Total + View Button + Pay Button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB4B2A9),
                          ),
                        ),
                        Text(
                          '₹${totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C2C2A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // View Button
                  if (hasItems)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: OutlinedButton(
                        onPressed: _showCartModal,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kGreen,
                          side: const BorderSide(color: kGreen, width: 1.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: hasItems ? _showDeliveryLocationModal : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      disabledBackgroundColor: const Color(0xFFD3D1C7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Pay on Delivery',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
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

class _DeliveryLocationSheet extends StatefulWidget {
  @override
  State<_DeliveryLocationSheet> createState() => _DeliveryLocationSheetState();
}

class _DeliveryLocationSheetState extends State<_DeliveryLocationSheet> {
  static const Color kGreen = Color(0xFF1D9E75);

  bool _isFetchingLocation = false;
  String? _fetchedLocation;

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => _isFetchingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _isFetchingLocation = false;
        _fetchedLocation =
            'Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)}';
      });

      // Show confirmation and close
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location fetched: $_fetchedLocation'),
            backgroundColor: kGreen,
          ),
        );
        Navigator.pop(context);
        // TODO: proceed with order using position.latitude, position.longitude
      }
    } catch (e) {
      setState(() => _isFetchingLocation = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    }
  }

  void _showManualAddressModal() {
    Navigator.pop(context); // close current sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ManualAddressSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: kGreen,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Delivery Location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'How would you like to set your delivery address?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF888780),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Use Current Location button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isFetchingLocation ? null : _fetchCurrentLocation,
              icon: _isFetchingLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location_rounded, size: 18),
              label: Text(
                _isFetchingLocation
                    ? 'Fetching location...'
                    : 'Use Current Location',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // OR divider
          Row(
            children: const [
              Expanded(
                child: Divider(thickness: 0.5, color: Color(0xFFE0E0E0)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB4B2A9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Divider(thickness: 0.5, color: Color(0xFFE0E0E0)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Enter Manually button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showManualAddressModal,
              icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
              label: const Text(
                'Enter Address Manually',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: kGreen,
                side: const BorderSide(color: kGreen, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Manual Address Sheet ─────────────────────────────────────────────────────

class _ManualAddressSheet extends StatefulWidget {
  const _ManualAddressSheet();

  @override
  State<_ManualAddressSheet> createState() => _ManualAddressSheetState();
}

class _ManualAddressSheetState extends State<_ManualAddressSheet> {
  static const Color kGreen = Color(0xFF1D9E75);

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _flatCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  String _selectedType = 'Home';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _flatCtrl.dispose();
    _areaCtrl.dispose();
    _cityCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order placed to ${_flatCtrl.text}, ${_areaCtrl.text}, ${_cityCtrl.text}',
          ),
          backgroundColor: kGreen,
        ),
      );
      // TODO: use the address fields to place order
    }
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF888780), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFB4B2A9), size: 18),
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _DeliveryLocationSheet(),
                        );
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF2C2C2A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Enter Delivery Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Address Type selector
                const Text(
                  'Address Type',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888780),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Home', 'Work', 'Other'].map((type) {
                    final isSelected = _selectedType == type;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? kGreen : const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? kGreen
                                : const Color(0xFFE0E0E0),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF5F5E5A),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDecor(
                    'Full Name',
                    Icons.person_outline_rounded,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 12),

                // Phone
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecor('Phone Number', Icons.phone_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Enter phone number';
                    if (v.trim().length < 10) return 'Enter valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Flat / House No
                TextFormField(
                  controller: _flatCtrl,
                  decoration: _inputDecor(
                    'Flat / House No / Building',
                    Icons.home_outlined,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter flat/house no'
                      : null,
                ),
                const SizedBox(height: 12),

                // Area / Street
                TextFormField(
                  controller: _areaCtrl,
                  decoration: _inputDecor(
                    'Area / Street / Locality',
                    Icons.streetview_rounded,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter area/street'
                      : null,
                ),
                const SizedBox(height: 12),

                // City & Pincode side by side
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityCtrl,
                        decoration: _inputDecor(
                          'City',
                          Icons.location_city_outlined,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter city'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _pincodeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecor('Pincode', Icons.pin_outlined),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Enter pincode';
                          if (v.trim().length != 6) return 'Invalid pincode';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Confirm & Place Order',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

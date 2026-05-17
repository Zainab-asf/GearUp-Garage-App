import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';

class PartsPage extends StatefulWidget {
  const PartsPage({super.key});

  @override
  State<PartsPage> createState() => _PartsPageState();
}

class _PartsPageState extends State<PartsPage> {
  String _selectedCategory = 'All';
  String _selectedBrand = 'All';

  final List<String> _categories = [
    'All',
    'Engine Parts',
    'Brake System',
    'Suspension',
    'Electrical',
    'Body Parts',
    'Tires & Wheels',
  ];

  final List<String> _brands = [
    'All',
    'Honda',
    'Toyota',
    'Suzuki',
    'Hyundai',
    'KIA',
    'Nissan',
    'BMW',
    'Maserati',
    'Rolls Royce',
    'Lamborghini',
  ];

  final List<Map<String, dynamic>> _parts = [
    {
      'id': '1',
      'name': 'Honda Civic Brake Pads',
      'category': 'Brake System',
      'brand': 'Honda',
      'price': '8,500',
      'originalPrice': '12,000',
      'discount': '30%',
      'rating': 4.5,
      'inStock': true,
      'image': 'assets/images/breakpads.jpg',
      'description':
          'High quality ceramic brake pads for Honda Civic 2016-2021',
      'seller': 'AutoParts Hub',
      'location': 'Faisalabad',
    },
    {
      'id': '2',
      'name': 'Toyota Corolla Air Filter',
      'category': 'Engine Parts',
      'brand': 'Toyota',
      'price': '2,200',
      'originalPrice': '3,000',
      'discount': '25%',
      'rating': 4.3,
      'inStock': true,
      'image': 'assets/images/airfilter.jpg',
      'description': 'OEM quality air filter for Toyota Corolla 2014-2020',
      'seller': 'Parts World',
      'location': 'Lahore',
    },
    {
      'id': '3',
      'name': 'Universal LED Headlights',
      'category': 'Electrical',
      'brand': 'All',
      'price': '15,000',
      'originalPrice': '20,000',
      'discount': '25%',
      'rating': 4.7,
      'inStock': true,
      'image': 'assets/images/unversallights.jpg',
      'description':
          'High brightness LED headlights compatible with most vehicles',
      'seller': 'LED Auto Store',
      'location': 'Karachi',
    },
    {
      'id': '4',
      'name': 'Suzuki Alto Shock Absorbers',
      'category': 'Suspension',
      'brand': 'Suzuki',
      'price': '12,000',
      'originalPrice': '16,000',
      'discount': '25%',
      'rating': 4.2,
      'inStock': false,
      'image': 'assets/images/shcokabsorber.jpg',
      'description': 'Front shock absorbers for Suzuki Alto 2019-2022',
      'seller': 'Suzuki Parts Center',
      'location': 'Islamabad',
    },
    {
      'id': '5',
      'name': 'Car Battery 70AH',
      'category': 'Electrical',
      'brand': 'All',
      'price': '18,500',
      'originalPrice': '22,000',
      'discount': '15%',
      'rating': 4.6,
      'inStock': true,
      'image': 'assets/images/battery.jpg',
      'description': 'High performance 70AH car battery with 2 year warranty',
      'seller': 'Battery World',
      'location': 'Rawalpindi',
    },
    {
      'id': '6',
      'name': 'Alloy Wheels 15 inch',
      'category': 'Tires & Wheels',
      'brand': 'All',
      'price': '45,000',
      'originalPrice': '55,000',
      'discount': '18%',
      'rating': 4.8,
      'inStock': true,
      'image': 'assets/images/alloywhells.jpg',
      'description': 'Premium 15 inch alloy wheels set of 4 pieces',
      'seller': 'Wheel Hub',
      'location': 'Abbottabad',
    },
    {
      'id': '7',
      'name': 'BMW Engine Oil Filter',
      'category': 'Engine Parts',
      'brand': 'BMW',
      'price': '3,500',
      'originalPrice': '4,200',
      'discount': '17%',
      'rating': 4.6,
      'inStock': true,
      'image': 'assets/images/bmw.jpg',
      'description': 'Original BMW engine oil filter for 3 Series and 5 Series',
      'seller': 'BMW Parts Center',
      'location': 'Lahore',
    },
    {
      'id': '8',
      'name': 'Maserati Performance Parts',
      'category': 'Engine Parts',
      'brand': 'Maserati',
      'price': '85,000',
      'originalPrice': '100,000',
      'discount': '15%',
      'rating': 4.9,
      'inStock': true,
      'image': 'assets/images/Maserati.jpg',
      'description': 'High-performance engine components for Maserati vehicles',
      'seller': 'Luxury Auto Parts',
      'location': 'Karachi',
    },
    {
      'id': '9',
      'name': 'Rolls Royce Interior Parts',
      'category': 'Body Parts',
      'brand': 'Rolls Royce',
      'price': '150,000',
      'originalPrice': '180,000',
      'discount': '17%',
      'rating': 5.0,
      'inStock': false,
      'image': 'assets/images/RollsRoyce.jpg',
      'description': 'Premium interior components for Rolls Royce vehicles',
      'seller': 'Elite Auto Parts',
      'location': 'Islamabad',
    },
    {
      'id': '10',
      'name': 'Lamborghini Exhaust System',
      'category': 'Engine Parts',
      'brand': 'Lamborghini',
      'price': '250,000',
      'originalPrice': '300,000',
      'discount': '17%',
      'rating': 4.8,
      'inStock': true,
      'image': 'assets/images/lemborgini.jpg',
      'description': 'High-performance exhaust system for Lamborghini models',
      'seller': 'Supercar Parts',
      'location': 'Karachi',
    },
    {
      'id': '11',
      'name': 'Universal Car Accessories',
      'category': 'Body Parts',
      'brand': 'All',
      'price': '5,500',
      'originalPrice': '7,000',
      'discount': '21%',
      'rating': 4.4,
      'inStock': true,
      'image': 'assets/images/01.jpeg',
      'description': 'Complete set of universal car accessories and trim parts',
      'seller': 'Auto Accessories Hub',
      'location': 'Faisalabad',
    },
    {
      'id': '12',
      'name': 'Professional Car Tools',
      'category': 'Engine Parts',
      'brand': 'All',
      'price': '12,500',
      'originalPrice': '15,000',
      'discount': '17%',
      'rating': 4.5,
      'inStock': true,
      'image': 'assets/images/02.png',
      'description': 'Professional grade tools for car maintenance and repair',
      'seller': 'Tool Master',
      'location': 'Rawalpindi',
    },
    {
      'id': '13',
      'name': 'Car Inspection Kit',
      'category': 'Electrical',
      'brand': 'All',
      'price': '8,000',
      'originalPrice': '10,000',
      'discount': '20%',
      'rating': 4.3,
      'inStock': true,
      'image': 'assets/images/04.jpeg',
      'description': 'Complete car inspection and diagnostic equipment',
      'seller': 'Diagnostic Center',
      'location': 'Lahore',
    },
  ];

  List<Map<String, dynamic>> get _filteredParts {
    return _parts.where((part) {
      bool categoryMatch =
          _selectedCategory == 'All' || part['category'] == _selectedCategory;
      bool brandMatch =
          _selectedBrand == 'All' || part['brand'] == _selectedBrand;
      return categoryMatch && brandMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Auto Parts',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.surface,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBrand,
                        decoration: const InputDecoration(
                          labelText: 'Brand',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            _brands.map((brand) {
                              return DropdownMenuItem(
                                value: brand,
                                child: Text(brand),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBrand = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primary),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Found ${_filteredParts.length} parts',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Parts List
          Expanded(
            child:
                _filteredParts.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No parts found',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _filteredParts.length,
                      itemBuilder: (context, index) {
                        final part = _filteredParts[index];
                        return _buildPartCard(part);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartCard(Map<String, dynamic> part) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Part Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  // Actual part image
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      image: DecorationImage(
                        image: AssetImage(
                          part['image'] ?? 'assets/images/car.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (part['discount'] != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          part['discount'],
                          style: const TextStyle(
                            color: AppTheme.buttonText,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (!part['inStock'])
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.inputBorder,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Part Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    part['name'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < part['rating'].floor()
                              ? Icons.star
                              : Icons.star_border,
                          size: 12,
                          color: AppTheme.accent,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        '${part['rating']}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        'Rs. ${part['price']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      if (part['originalPrice'] != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          'Rs. ${part['originalPrice']}',
                          style: const TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          part['inStock']
                              ? () {
                                _showPartDetails(part);
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            part['inStock']
                                ? AppTheme.primary
                                : AppTheme.inputBorder,
                        foregroundColor: AppTheme.buttonText,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        part['inStock'] ? 'View Details' : 'Out of Stock',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.buttonText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPartDetails(Map<String, dynamic> part) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.inputBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Part name and price
                  Text(
                    part['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Rs. ${part['price']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      if (part['originalPrice'] != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Rs. ${part['originalPrice']}',
                          style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${part['discount']} OFF',
                            style: const TextStyle(
                              color: AppTheme.buttonText,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    part['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Seller info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.inputFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store, color: AppTheme.secondary),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              part['seller'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              part['location'],
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling ${part['seller']}'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Call Seller'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.success,
                            side: const BorderSide(color: AppTheme.success),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart!')),
                            );
                          },
                          icon: const Icon(
                            Icons.shopping_cart,
                            color: AppTheme.buttonText,
                          ),
                          label: const Text(
                            'Add to Cart',
                            style: TextStyle(color: AppTheme.buttonText),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.buttonText,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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

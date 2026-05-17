import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';

class BuySellPage extends StatefulWidget {
  const BuySellPage({super.key});

  @override
  State<BuySellPage> createState() => _BuySellPageState();
}

class _BuySellPageState extends State<BuySellPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _selectedPriceRange = 'All';

  final List<String> _categories = [
    'All',
    'Sedan',
    'SUV',
    'Hatchback',
    'Truck',
    'Motorcycle',
  ];
  final List<String> _priceRanges = [
    'All',
    'Under 10L',
    '10L-20L',
    '20L-50L',
    'Above 50L',
  ];

  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': '1',
      'title': '2020 Honda Civic',
      'category': 'Sedan',
      'price': '3,200,000',
      'location': 'Faisalabad',
      'year': '2020',
      'mileage': '45,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'image': 'assets/images/civic.jpg',
      'seller': 'Ahmad Ali',
      'phone': '+92 300 1234567',
      'type': 'sell',
    },
    {
      'id': '2',
      'title': '2019 Toyota Corolla',
      'category': 'Sedan',
      'price': '2,800,000',
      'location': 'Lahore',
      'year': '2019',
      'mileage': '60,000 km',
      'fuel': 'Petrol',
      'transmission': 'Manual',
      'image': 'assets/images/corolla.jpg',
      'seller': 'Sara Khan',
      'phone': '+92 300 2345678',
      'type': 'sell',
    },
    {
      'id': '3',
      'title': 'Looking for Honda City',
      'category': 'Sedan',
      'price': '2,500,000',
      'location': 'Karachi',
      'year': '2018-2020',
      'mileage': 'Under 80,000 km',
      'fuel': 'Petrol',
      'transmission': 'Any',
      'image': 'assets/images/city.jpg',
      'seller': 'Hassan Ahmed',
      'phone': '+92 300 3456789',
      'type': 'buy',
    },
    {
      'id': '4',
      'title': '2021 Suzuki Alto',
      'category': 'Hatchback',
      'price': '1,800,000',
      'location': 'Islamabad',
      'year': '2021',
      'mileage': '25,000 km',
      'fuel': 'Petrol',
      'transmission': 'Manual',
      'image': 'assets/images/alto.jpg',
      'seller': 'Fatima Sheikh',
      'phone': '+92 300 4567890',
      'type': 'sell',
    },
    {
      'id': '5',
      'title': '2020 Toyota Prado',
      'category': 'SUV',
      'price': '12,500,000',
      'location': 'Rawalpindi',
      'year': '2020',
      'mileage': '35,000 km',
      'fuel': 'Diesel',
      'transmission': 'Automatic',
      'image': 'assets/images/prado.jpg',
      'seller': 'Usman Malik',
      'phone': '+92 300 5678901',
      'type': 'sell',
    },
    {
      'id': '6',
      'title': 'Need Motorcycle 125cc',
      'category': 'Motorcycle',
      'price': '150,000',
      'location': 'Abbottabad',
      'year': '2019-2022',
      'mileage': 'Any',
      'fuel': 'Petrol',
      'transmission': 'Manual',
      'image': 'assets/images/bike.jpg',
      'seller': 'Ali Raza',
      'phone': '+92 300 6789012',
      'type': 'buy',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredVehicles {
    return _vehicles.where((vehicle) {
      bool categoryMatch =
          _selectedCategory == 'All' ||
          vehicle['category'] == _selectedCategory;
      bool priceMatch =
          _selectedPriceRange == 'All' ||
          _isPriceInRange(vehicle['price'], _selectedPriceRange);
      return categoryMatch && priceMatch;
    }).toList();
  }

  bool _isPriceInRange(String price, String range) {
    int priceValue = int.parse(
      price.replaceAll(',', '').replaceAll('Rs. ', ''),
    );
    switch (range) {
      case 'Under 10L':
        return priceValue < 1000000;
      case '10L-20L':
        return priceValue >= 1000000 && priceValue <= 2000000;
      case '20L-50L':
        return priceValue >= 2000000 && priceValue <= 5000000;
      case 'Above 50L':
        return priceValue > 5000000;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Buy & Sell Vehicles',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.surface,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'For Sale', icon: Icon(Icons.sell)),
            Tab(text: 'Looking to Buy', icon: Icon(Icons.shopping_cart)),
          ],
        ),
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
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
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
                        value: _selectedPriceRange,
                        decoration: const InputDecoration(
                          labelText: 'Price Range',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            _priceRanges.map((range) {
                              return DropdownMenuItem(
                                value: range,
                                child: Text(
                                  range,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPriceRange = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // For Sale Tab
                _buildVehicleList(
                  _filteredVehicles.where((v) => v['type'] == 'sell').toList(),
                ),
                // Looking to Buy Tab
                _buildVehicleList(
                  _filteredVehicles.where((v) => v['type'] == 'buy').toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post Ad feature coming soon!')),
          );
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.buttonText,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVehicleList(List<Map<String, dynamic>> vehicles) {
    if (vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No vehicles found',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCard(vehicle);
      },
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    bool isBuyRequest = vehicle['type'] == 'buy';
    final theme = Theme.of(context);
    final accentColor = isBuyRequest ? AppTheme.secondary : AppTheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Image Placeholder
                Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    isBuyRequest ? Icons.search : Icons.directions_car,
                    size: 40,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 16),

                // Vehicle Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              vehicle['title'],
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isBuyRequest
                                      ? AppTheme.accent
                                      : AppTheme.success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isBuyRequest ? 'WANTED' : 'FOR SALE',
                              style: const TextStyle(
                                color: AppTheme.buttonText,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs. ${vehicle['price']}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vehicle['location'],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vehicle['year'],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Vehicle specs
            Row(
              children: [
                _buildSpecChip('${vehicle['mileage']}', Icons.speed),
                const SizedBox(width: 8),
                _buildSpecChip(vehicle['fuel'], Icons.local_gas_station),
                const SizedBox(width: 8),
                _buildSpecChip(vehicle['transmission'], Icons.settings),
              ],
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${vehicle['seller']}')),
                      );
                    },
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.success,
                      side: const BorderSide(color: AppTheme.success),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Messaging ${vehicle['seller']}'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.message,
                      size: 16,
                      color: AppTheme.buttonText,
                    ),
                    label: const Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.buttonText,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.buttonText,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

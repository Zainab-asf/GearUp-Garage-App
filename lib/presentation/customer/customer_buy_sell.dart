import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/data/repositories/garage_repository.dart';

class BuySellPage extends StatefulWidget {
  const BuySellPage({super.key});

  @override
  State<BuySellPage> createState() => _BuySellPageState();
}

class _BuySellPageState extends State<BuySellPage>
    with SingleTickerProviderStateMixin {
  final GarageRepository _repository = GarageRepository();
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _selectedPriceRange = 'All';

  final List<String> _priceRanges = const [
    'All',
    'Under 10L',
    '10L-20L',
    '20L-50L',
    'Above 50L',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy & Sell Vehicles'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          tabs: const [
            Tab(text: 'For Sale', icon: Icon(Icons.sell)),
            Tab(text: 'Looking to Buy', icon: Icon(Icons.search)),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _repository.activeVehicleListings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.secondary),
            );
          }

          if (snapshot.hasError) {
            return const _EmptyState(
              icon: Icons.cloud_off,
              title: 'Could not load listings',
              message: 'Check your connection and try again.',
            );
          }

          final listings =
              snapshot.data?.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList() ??
              [];
          final categories = _valuesFrom(listings, 'category');
          final filtered =
              listings.where((listing) {
                final category = listing['category']?.toString() ?? '';
                return (_selectedCategory == 'All' ||
                        category == _selectedCategory) &&
                    (_selectedPriceRange == 'All' ||
                        _isPriceInRange(listing['price'], _selectedPriceRange));
              }).toList();

          return Column(
            children: [
              _Filters(
                categories: categories,
                priceRanges: _priceRanges,
                selectedCategory: _selectedCategory,
                selectedPriceRange: _selectedPriceRange,
                onCategoryChanged:
                    (value) => setState(() => _selectedCategory = value),
                onPriceRangeChanged:
                    (value) => setState(() => _selectedPriceRange = value),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _VehicleList(
                      listings:
                          filtered
                              .where((item) => item['type'] == 'sell')
                              .toList(),
                    ),
                    _VehicleList(
                      listings:
                          filtered
                              .where((item) => item['type'] == 'buy')
                              .toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showListingDialog,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.buttonText,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<String> _valuesFrom(List<Map<String, dynamic>> items, String field) {
    final values =
        items
            .map((item) => item[field]?.toString().trim() ?? '')
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...values];
  }

  bool _isPriceInRange(Object? price, String range) {
    final priceValue = _parseInt(price);
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

  Future<void> _showListingDialog() async {
    final title = TextEditingController();
    final price = TextEditingController();
    final location = TextEditingController();
    final year = TextEditingController();
    final mileage = TextEditingController();
    final fuel = TextEditingController();
    final transmission = TextEditingController();
    final category = TextEditingController();
    final seller = TextEditingController();
    final phone = TextEditingController();
    String type = 'sell';

    final created = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Post vehicle listing'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'sell',
                              label: Text('For sale'),
                              icon: Icon(Icons.sell),
                            ),
                            ButtonSegment(
                              value: 'buy',
                              label: Text('Wanted'),
                              icon: Icon(Icons.search),
                            ),
                          ],
                          selected: {type},
                          onSelectionChanged:
                              (value) =>
                                  setDialogState(() => type = value.first),
                        ),
                        const SizedBox(height: 12),
                        _field(title, 'Title'),
                        _field(price, 'Price', TextInputType.number),
                        _field(location, 'Location'),
                        _field(year, 'Year'),
                        _field(mileage, 'Mileage'),
                        _field(fuel, 'Fuel'),
                        _field(transmission, 'Transmission'),
                        _field(category, 'Category'),
                        _field(seller, 'Seller name'),
                        _field(phone, 'Phone', TextInputType.phone),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (title.text.trim().isEmpty ||
                            price.text.trim().isEmpty ||
                            phone.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Title, price, and phone are required.',
                              ),
                            ),
                          );
                          return;
                        }
                        await _repository.createVehicleListing({
                          'type': type,
                          'title': title.text.trim(),
                          'price': _parseInt(price.text),
                          'location': location.text.trim(),
                          'year': year.text.trim(),
                          'mileage': mileage.text.trim(),
                          'fuel': fuel.text.trim(),
                          'transmission': transmission.text.trim(),
                          'category':
                              category.text.trim().isEmpty
                                  ? 'General'
                                  : category.text.trim(),
                          'seller': seller.text.trim(),
                          'phone': phone.text.trim(),
                        });
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext, true);
                      },
                      child: const Text('Post'),
                    ),
                  ],
                ),
          ),
    );

    for (final controller in [
      title,
      price,
      location,
      year,
      mileage,
      fuel,
      transmission,
      category,
      seller,
      phone,
    ]) {
      controller.dispose();
    }

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle listing posted.'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.categories,
    required this.priceRanges,
    required this.selectedCategory,
    required this.selectedPriceRange,
    required this.onCategoryChanged,
    required this.onPriceRangeChanged,
  });

  final List<String> categories;
  final List<String> priceRanges;
  final String selectedCategory;
  final String selectedPriceRange;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onPriceRangeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surface,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value:
                  categories.contains(selectedCategory)
                      ? selectedCategory
                      : 'All',
              decoration: const InputDecoration(labelText: 'Category'),
              items:
                  categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
              onChanged:
                  (value) => value == null ? null : onCategoryChanged(value),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedPriceRange,
              decoration: const InputDecoration(labelText: 'Price'),
              items:
                  priceRanges
                      .map(
                        (range) => DropdownMenuItem(
                          value: range,
                          child: Text(range, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
              onChanged:
                  (value) => value == null ? null : onPriceRangeChanged(value),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleList extends StatelessWidget {
  const _VehicleList({required this.listings});

  final List<Map<String, dynamic>> listings;

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return const _EmptyState(
        icon: Icons.search_off,
        title: 'No vehicles found',
        message: 'Listings posted by users will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listings.length,
      itemBuilder: (context, index) => _VehicleCard(listing: listings[index]),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.listing});

  final Map<String, dynamic> listing;

  @override
  Widget build(BuildContext context) {
    final isBuyRequest = listing['type'] == 'buy';
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
                Container(
                  width: 92,
                  height: 78,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: Icon(
                    isBuyRequest ? Icons.search : Icons.directions_car,
                    size: 38,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing['title']?.toString() ?? 'Vehicle',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs. ${_formatPrice(listing['price'])}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${listing['location'] ?? 'Location not set'} • ${listing['year'] ?? 'Year N/A'}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(isBuyRequest ? 'WANTED' : 'FOR SALE'),
                  backgroundColor:
                      isBuyRequest ? AppTheme.accent : AppTheme.success,
                  labelStyle: const TextStyle(
                    color: AppTheme.buttonText,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SpecChip(
                  text: listing['mileage']?.toString() ?? 'Mileage N/A',
                  icon: Icons.speed,
                ),
                _SpecChip(
                  text: listing['fuel']?.toString() ?? 'Fuel N/A',
                  icon: Icons.local_gas_station,
                ),
                _SpecChip(
                  text:
                      listing['transmission']?.toString() ?? 'Transmission N/A',
                  icon: Icons.settings,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Call ${listing['phone'] ?? listing['seller'] ?? 'seller'}',
                            ),
                          ),
                        ),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Message request saved for ${listing['seller'] ?? 'seller'}',
                            ),
                          ),
                        ),
                    icon: const Icon(Icons.message, size: 16),
                    label: const Text('Message'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14, color: AppTheme.textSecondary),
      label: Text(text),
      backgroundColor: AppTheme.inputFill,
      side: const BorderSide(color: AppTheme.inputBorder),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

int _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(
        value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '',
      ) ??
      0;
}

String _formatPrice(Object? value) {
  final price = _parseInt(value).toString();
  final buffer = StringBuffer();
  for (var i = 0; i < price.length; i++) {
    final reverseIndex = price.length - i;
    buffer.write(price[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

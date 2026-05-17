import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/data/repositories/garage_repository.dart';

class PartsPage extends StatefulWidget {
  const PartsPage({super.key});

  @override
  State<PartsPage> createState() => _PartsPageState();
}

class _PartsPageState extends State<PartsPage> {
  final GarageRepository _repository = GarageRepository();
  String _selectedCategory = 'All';
  String _selectedBrand = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Parts')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _repository.activeParts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.secondary),
            );
          }

          if (snapshot.hasError) {
            return const _EmptyState(
              icon: Icons.cloud_off,
              title: 'Could not load parts',
              message: 'Check your connection and try again.',
            );
          }

          final parts =
              snapshot.data?.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList() ??
              [];
          final categories = _valuesFrom(parts, 'category');
          final brands = _valuesFrom(parts, 'brand');
          final filtered =
              parts.where((part) {
                final category = part['category']?.toString() ?? '';
                final brand = part['brand']?.toString() ?? '';
                return (_selectedCategory == 'All' ||
                        category == _selectedCategory) &&
                    (_selectedBrand == 'All' || brand == _selectedBrand);
              }).toList();

          return Column(
            children: [
              _Filters(
                categories: categories,
                brands: brands,
                selectedCategory: _selectedCategory,
                selectedBrand: _selectedBrand,
                onCategoryChanged:
                    (value) => setState(() => _selectedCategory = value),
                onBrandChanged:
                    (value) => setState(() => _selectedBrand = value),
                resultCount: filtered.length,
              ),
              Expanded(
                child:
                    filtered.isEmpty
                        ? const _EmptyState(
                          icon: Icons.search_off,
                          title: 'No parts found',
                          message: 'Try another category or brand.',
                        )
                        : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: filtered.length,
                          itemBuilder:
                              (context, index) => _PartCard(
                                part: filtered[index],
                                onTap:
                                    () => _showPartDetails(
                                      context,
                                      filtered[index],
                                    ),
                              ),
                        ),
              ),
            ],
          );
        },
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

  void _showPartDetails(BuildContext context, Map<String, dynamic> part) {
    final inStock = part['inStock'] != false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.45,
            maxChildSize: 0.9,
            builder:
                (context, controller) => Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _PartImage(imagePath: part['image']?.toString()),
                      const SizedBox(height: 16),
                      Text(
                        part['name']?.toString() ?? 'Part',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rs. ${_priceText(part['price'])}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        part['description']?.toString() ??
                            'No description provided.',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(
                              part['category']?.toString() ?? 'General',
                            ),
                          ),
                          Chip(
                            label: Text(
                              part['brand']?.toString() ?? 'Any brand',
                            ),
                          ),
                          Chip(
                            label: Text(inStock ? 'In stock' : 'Out of stock'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Seller: ${part['seller'] ?? part['sellerName'] ?? 'Marketplace seller'}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      Text(
                        'Location: ${part['location'] ?? 'Not specified'}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed:
                            inStock
                                ? () async {
                                  await _repository.addToCart(
                                    itemId: part['id'].toString(),
                                    itemType: 'part',
                                    item: part,
                                  );
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Part added to cart.'),
                                      backgroundColor: AppTheme.success,
                                    ),
                                  );
                                }
                                : null,
                        icon: const Icon(Icons.shopping_cart),
                        label: Text(inStock ? 'Add to cart' : 'Out of stock'),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.categories,
    required this.brands,
    required this.selectedCategory,
    required this.selectedBrand,
    required this.onCategoryChanged,
    required this.onBrandChanged,
    required this.resultCount,
  });

  final List<String> categories;
  final List<String> brands;
  final String selectedCategory;
  final String selectedBrand;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onBrandChanged;
  final int resultCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surface,
      child: Column(
        children: [
          Row(
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
                      (value) =>
                          value == null ? null : onCategoryChanged(value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: brands.contains(selectedBrand) ? selectedBrand : 'All',
                  decoration: const InputDecoration(labelText: 'Brand'),
                  items:
                      brands
                          .map(
                            (brand) => DropdownMenuItem(
                              value: brand,
                              child: Text(
                                brand,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) => value == null ? null : onBrandChanged(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$resultCount part${resultCount == 1 ? '' : 's'} found',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartCard extends StatelessWidget {
  const _PartCard({required this.part, required this.onTap});

  final Map<String, dynamic> part;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inStock = part['inStock'] != false;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _PartImage(imagePath: part['image']?.toString()),
                  if (!inStock)
                    Container(
                      color: Colors.black.withOpacity(0.45),
                      alignment: Alignment.center,
                      child: const Text(
                        'Out of stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    part['name']?.toString() ?? 'Part',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${_priceText(part['price'])}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    part['seller']?.toString() ??
                        part['sellerName']?.toString() ??
                        'Marketplace seller',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartImage extends StatelessWidget {
  const _PartImage({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final image = imagePath ?? 'assets/images/car.png';
    final provider =
        image.startsWith('http')
            ? NetworkImage(image) as ImageProvider
            : AssetImage(image);
    return Image(
      image: provider,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => Container(
            color: AppTheme.inputFill,
            child: const Icon(Icons.image_not_supported, size: 44),
          ),
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

String _priceText(Object? value) {
  if (value is num) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }
  return value?.toString() ?? '0';
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/data/repositories/garage_repository.dart';
import 'package:gearup_garage/presentation/customer/customer_bookings.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final GarageRepository _repository = GarageRepository();
  String _selectedCity = 'All';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Services')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _repository.activeServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.secondary),
            );
          }

          if (snapshot.hasError) {
            return _EmptyState(
              icon: Icons.cloud_off,
              title: 'Could not load services',
              message: 'Check your connection and try again.',
            );
          }

          final services =
              snapshot.data?.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }).toList() ??
              [];

          final cities = _valuesFrom(services, 'city');
          final categories = _valuesFrom(services, 'category');
          final filtered =
              services.where((service) {
                final city = service['city']?.toString() ?? '';
                final category = service['category']?.toString() ?? '';
                return (_selectedCity == 'All' || city == _selectedCity) &&
                    (_selectedCategory == 'All' ||
                        category == _selectedCategory);
              }).toList();

          return Column(
            children: [
              _Filters(
                cities: cities,
                categories: categories,
                selectedCity: _selectedCity,
                selectedCategory: _selectedCategory,
                onCityChanged: (value) => setState(() => _selectedCity = value),
                onCategoryChanged:
                    (value) => setState(() => _selectedCategory = value),
              ),
              Expanded(
                child:
                    filtered.isEmpty
                        ? _EmptyState(
                          icon: Icons.search_off,
                          title: 'No services found',
                          message: 'Try another city or category.',
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder:
                              (context, index) => _ServiceCard(
                                service: filtered[index],
                                onTap:
                                    () => _showServiceDetails(
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

  void _showServiceDetails(BuildContext context, Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.72,
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
                      Text(
                        service['name']?.toString() ?? 'Service',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service['description']?.toString() ??
                            'No description provided.',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.category,
                            text: service['category']?.toString() ?? 'General',
                          ),
                          _InfoChip(
                            icon: Icons.access_time,
                            text: service['duration']?.toString() ?? 'N/A',
                          ),
                          _InfoChip(
                            icon: Icons.payments,
                            text: 'Rs. ${_priceText(service['price'])}',
                          ),
                          if ((service['city']?.toString() ?? '').isNotEmpty)
                            _InfoChip(
                              icon: Icons.location_city,
                              text: service['city'].toString(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if ((service['businessName']?.toString() ?? '')
                          .isNotEmpty)
                        _DetailRow(
                          icon: Icons.garage,
                          label: 'Garage',
                          value: service['businessName'].toString(),
                        ),
                      if ((service['address']?.toString() ?? '').isNotEmpty)
                        _DetailRow(
                          icon: Icons.location_on,
                          label: 'Address',
                          value: service['address'].toString(),
                        ),
                      if ((service['phone']?.toString() ?? '').isNotEmpty)
                        _DetailRow(
                          icon: Icons.phone,
                          label: 'Phone',
                          value: service['phone'].toString(),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BookingPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Book this service'),
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
    required this.cities,
    required this.categories,
    required this.selectedCity,
    required this.selectedCategory,
    required this.onCityChanged,
    required this.onCategoryChanged,
  });

  final List<String> cities;
  final List<String> categories;
  final String selectedCity;
  final String selectedCategory;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surface,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: cities.contains(selectedCity) ? selectedCity : 'All',
              decoration: const InputDecoration(labelText: 'City'),
              items:
                  cities
                      .map(
                        (city) =>
                            DropdownMenuItem(value: city, child: Text(city)),
                      )
                      .toList(),
              onChanged: (value) => value == null ? null : onCityChanged(value),
            ),
          ),
          const SizedBox(width: 12),
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
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});

  final Map<String, dynamic> service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.card,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.inputFill,
          child: Icon(Icons.build_circle, color: AppTheme.primary),
        ),
        title: Text(
          service['name']?.toString() ?? 'Service',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          [
            service['businessName'] ?? service['providerName'],
            service['city'],
            service['category'],
          ].whereType<Object>().map((value) => value.toString()).join(' • '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rs. ${_priceText(service['price'])}',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppTheme.primary),
      label: Text(text),
      backgroundColor: AppTheme.inputFill,
      side: const BorderSide(color: AppTheme.inputBorder),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
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

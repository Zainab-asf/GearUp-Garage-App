import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';
import 'package:gearup_garage/data/repositories/garage_repository.dart';
import 'package:gearup_garage/presentation/customer/customer_bookings.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final GarageRepository _repository = GarageRepository();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Search')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _repository.activeServices(),
        builder: (context, snapshot) {
          final services =
              snapshot.data?.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList() ??
              [];
          final categories = _categoriesFrom(services);
          final query = _searchController.text.trim().toLowerCase();
          final results =
              services.where((item) {
                final name = item['name']?.toString().toLowerCase() ?? '';
                final garage =
                    (item['businessName'] ?? item['providerName'])
                        ?.toString()
                        .toLowerCase() ??
                    '';
                final category = item['category']?.toString() ?? '';
                final matchesQuery =
                    query.isEmpty ||
                    name.contains(query) ||
                    garage.contains(query) ||
                    category.toLowerCase().contains(query);
                final matchesCategory =
                    _selectedCategory == 'All' || category == _selectedCategory;
                return matchesQuery && matchesCategory;
              }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search services or garages',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: category == _selectedCategory,
                              onSelected:
                                  (_) => setState(
                                    () => _selectedCategory = category,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    snapshot.connectionState == ConnectionState.waiting
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.secondary,
                          ),
                        )
                        : results.isEmpty
                        ? const _EmptyState()
                        : ListView.builder(
                          itemCount: results.length,
                          itemBuilder:
                              (context, index) =>
                                  _ResultTile(service: results[index]),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _categoriesFrom(List<Map<String, dynamic>> services) {
    final categories =
        services
            .map((item) => item['category']?.toString().trim() ?? '')
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...categories];
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.service});

  final Map<String, dynamic> service;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.inputFill,
          child: Icon(Icons.build, color: AppTheme.primary),
        ),
        title: Text(
          service['name']?.toString() ?? 'Service',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          [
            service['businessName'] ?? service['providerName'],
            service['category'],
            service['city'],
          ].whereType<Object>().map((value) => value.toString()).join(' • '),
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: Text(
          'Rs. ${_priceText(service['price'])}',
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingPage()),
            ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No matching services found.',
        style: TextStyle(color: AppTheme.textSecondary),
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

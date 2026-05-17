import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Car Wash',
    'Detailing',
    'Waxing',
    'Interior Cleaning',
  ];

  final List<Map<String, String>> _searchResults = [
    {
      'title': 'Premium Car Wash',
      'price': 'PKR 1,500',
      'location': 'Lahore',
      'category': 'Car Wash',
      'image': 'assets/images/bmw.jpg',
    },
    {
      'title': 'Full Car Detailing',
      'price': 'PKR 3,500',
      'location': 'Karachi',
      'category': 'Detailing',
      'image': 'assets/images/car.png',
    },
    {
      'title': 'Car Waxing Service',
      'price': 'PKR 2,000',
      'location': 'Islamabad',
      'category': 'Waxing',
      'image': 'assets/images/lemborgini.jpg',
    },
    {
      'title': 'Interior Deep Clean',
      'price': 'PKR 2,500',
      'location': 'Faisalabad',
      'category': 'Interior Cleaning',
      'image': 'assets/images/car.png',
    },
    {
      'title': 'Car Wash Service',
      'price': 'PKR 1,500',
      'location': 'Lahore',
      'category': 'Services',
      'image': 'assets/images/car.png',
    },
  ];

  List<Map<String, String>> get filteredResults {
    if (_selectedCategory == 'All') {
      return _searchResults;
    }
    return _searchResults
        .where((item) => item['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search car care services...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredResults.length,
              itemBuilder: (context, index) {
                final item = filteredResults[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item['image']!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: AppTheme.inputFill,
                              child: const Icon(Icons.image_not_supported),
                            ),
                      ),
                    ),
                    title: Text(
                      item['title']!,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          item['price']!,
                          style: const TextStyle(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item['location']!,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(item['category']!),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Viewing ${item['title']}'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


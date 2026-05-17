import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRadius = '5 km';

  final List<String> _radiusOptions = [
    '1 km',
    '5 km',
    '10 km',
    '25 km',
    '50 km',
  ];

  final List<Map<String, dynamic>> _nearbyPlaces = [
    // Gas Stations
    {
      'id': '1',
      'name': 'PSO Petrol Station',
      'type': 'Gas Station',
      'category': 'fuel',
      'distance': '0.8 km',
      'rating': 4.2,
      'address': 'Main Boulevard, Kohinoor City',
      'phone': '+92 300 1111111',
      'isOpen': true,
      'openTime': '24/7',
      'services': ['Petrol', 'Diesel', 'CNG', 'Car Wash'],
    },
    {
      'id': '2',
      'name': 'Shell Fuel Station',
      'type': 'Gas Station',
      'category': 'fuel',
      'distance': '1.2 km',
      'rating': 4.5,
      'address': 'Jaranwala Road, Near University',
      'phone': '+92 300 2222222',
      'isOpen': true,
      'openTime': '6:00 AM - 12:00 AM',
      'services': ['Petrol', 'Diesel', 'Convenience Store'],
    },
    // Parking
    {
      'id': '3',
      'name': 'City Center Parking',
      'type': 'Parking',
      'category': 'parking',
      'distance': '2.1 km',
      'rating': 4.0,
      'address': 'D Ground, City Center',
      'phone': '+92 300 3333333',
      'isOpen': true,
      'openTime': '24/7',
      'services': ['Covered Parking', 'Security', 'CCTV'],
    },
    {
      'id': '4',
      'name': 'Mall Parking Plaza',
      'type': 'Parking',
      'category': 'parking',
      'distance': '3.5 km',
      'rating': 4.3,
      'address': 'Centaurus Mall, F-8',
      'phone': '+92 300 4444444',
      'isOpen': true,
      'openTime': '8:00 AM - 11:00 PM',
      'services': ['Multi-level', 'Valet Service', 'Electric Charging'],
    },
    // Car Wash
    {
      'id': '5',
      'name': 'Quick Wash Center',
      'type': 'Car Wash',
      'category': 'wash',
      'distance': '1.8 km',
      'rating': 4.4,
      'address': 'Canal Road, Near Bridge',
      'phone': '+92 300 5555555',
      'isOpen': true,
      'openTime': '7:00 AM - 9:00 PM',
      'services': ['Exterior Wash', 'Interior Cleaning', 'Wax Service'],
    },
    {
      'id': '6',
      'name': 'Premium Auto Spa',
      'type': 'Car Wash',
      'category': 'wash',
      'distance': '4.2 km',
      'rating': 4.7,
      'address': 'DHA Phase 1, Main Road',
      'phone': '+92 300 6666666',
      'isOpen': false,
      'openTime': '8:00 AM - 8:00 PM',
      'services': ['Full Detailing', 'Steam Wash', 'Paint Protection'],
    },
    // Mechanics
    {
      'id': '7',
      'name': 'Express Auto Repair',
      'type': 'Mechanic',
      'category': 'mechanic',
      'distance': '2.8 km',
      'rating': 4.1,
      'address': 'Industrial Area, Workshop 15',
      'phone': '+92 300 7777777',
      'isOpen': true,
      'openTime': '8:00 AM - 6:00 PM',
      'services': ['Engine Repair', 'Brake Service', 'Oil Change'],
    },
    {
      'id': '8',
      'name': 'Master Mechanic Shop',
      'type': 'Mechanic',
      'category': 'mechanic',
      'distance': '3.9 km',
      'rating': 4.6,
      'address': 'GT Road, Near Flyover',
      'phone': '+92 300 8888888',
      'isOpen': true,
      'openTime': '9:00 AM - 7:00 PM',
      'services': ['AC Repair', 'Electrical Work', 'Body Work'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredPlaces(String category) {
    if (category == 'all') return _nearbyPlaces;
    return _nearbyPlaces
        .where((place) => place['category'] == category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Nearby Places',
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
          isScrollable: true,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.location_on, size: 20)),
            Tab(text: 'Fuel', icon: Icon(Icons.local_gas_station, size: 20)),
            Tab(text: 'Parking', icon: Icon(Icons.local_parking, size: 20)),
            Tab(text: 'Services', icon: Icon(Icons.build, size: 20)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surface,
            child: Row(
              children: [
                const Icon(Icons.my_location, color: AppTheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Search within: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRadius,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    items:
                        _radiusOptions.map((radius) {
                          return DropdownMenuItem(
                            value: radius,
                            child: Text(radius),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRadius = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Refreshing location...')),
                    );
                  },
                  icon: const Icon(
                    Icons.refresh,
                    size: 16,
                    color: AppTheme.buttonText,
                  ),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.buttonText,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlacesList(_getFilteredPlaces('all')),
                _buildPlacesList(_getFilteredPlaces('fuel')),
                _buildPlacesList(_getFilteredPlaces('parking')),
                _buildPlacesList([
                  ..._getFilteredPlaces('wash'),
                  ..._getFilteredPlaces('mechanic'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesList(List<Map<String, dynamic>> places) {
    if (places.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No places found nearby',
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
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return _buildPlaceCard(place);
      },
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    final theme = Theme.of(context);
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
                // Place Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      place['category'],
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getCategoryColor(
                        place['category'],
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    _getCategoryIcon(place['category']),
                    size: 30,
                    color: _getCategoryColor(place['category']),
                  ),
                ),
                const SizedBox(width: 16),

                // Place Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              place['name'],
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
                                  place['isOpen']
                                      ? AppTheme.success
                                      : AppTheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              place['isOpen'] ? 'OPEN' : 'CLOSED',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place['type'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
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
                          Expanded(
                            child: Text(
                              place['address'],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.directions,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place['distance'],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ...List.generate(5, (index) {
                            return Icon(
                              index < place['rating'].floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 12,
                              color: AppTheme.accent,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            '${place['rating']}',
                            style: const TextStyle(
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

            // Services
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  (place['services'] as List<String>).take(3).map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          place['category'],
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getCategoryColor(
                            place['category'],
                          ).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        service,
                        style: TextStyle(
                          color: _getCategoryColor(place['category']),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Getting directions to ${place['name']}',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text(
                      'Directions',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.secondary,
                      side: const BorderSide(color: AppTheme.secondary),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${place['name']}')),
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
                    onPressed: () => _showPlaceDetails(place),
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text(
                      'Details',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getCategoryColor(place['category']),
                      foregroundColor: _getCategoryOnColor(place['category']),
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'fuel':
        return Icons.local_gas_station;
      case 'parking':
        return Icons.local_parking;
      case 'wash':
        return Icons.local_car_wash;
      case 'mechanic':
        return Icons.build;
      default:
        return Icons.location_on;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'fuel':
        return AppTheme.primary;
      case 'parking':
        return AppTheme.secondary;
      case 'wash':
        return AppTheme.accent;
      case 'mechanic':
        return AppTheme.success;
      default:
        return AppTheme.primary;
    }
  }

  Color _getCategoryOnColor(String category) {
    if (category == 'wash') {
      return AppTheme.buttonText;
    }

    return AppTheme.textPrimary;
  }

  void _showPlaceDetails(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);

        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
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

                // Place name and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        place['name'],
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            place['isOpen'] ? AppTheme.success : AppTheme.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        place['isOpen'] ? 'OPEN' : 'CLOSED',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  '${place['type']} • ${place['distance']} away',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Hours: ${place['openTime']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                // Services offered
                const Text(
                  'Services:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      (place['services'] as List<String>).map((service) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              place['category'],
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getCategoryColor(place['category']),
                            ),
                          ),
                          child: Text(
                            service,
                            style: TextStyle(
                              color: _getCategoryColor(place['category']),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                ),

                const Spacer(),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Getting directions to ${place['name']}',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.directions,
                          color: AppTheme.buttonText,
                        ),
                        label: const Text(
                          'Get Directions',
                          style: TextStyle(color: AppTheme.buttonText),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.buttonText,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling ${place['name']}')),
                          );
                        },
                        icon: const Icon(
                          Icons.phone,
                          color: AppTheme.buttonText,
                        ),
                        label: const Text(
                          'Call',
                          style: TextStyle(color: AppTheme.buttonText),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: AppTheme.buttonText,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
      },
    );
  }
}

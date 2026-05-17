import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  String _selectedCity = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Garages')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance
                .collection('service_providers')
                .where('isVerified', isEqualTo: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.secondary),
            );
          }

          if (snapshot.hasError) {
            return const _EmptyState(
              icon: Icons.cloud_off,
              message: 'Could not load garages.',
            );
          }

          final garages =
              snapshot.data?.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList() ??
              [];
          final cities = _citiesFrom(garages);
          final filtered =
              garages.where((garage) {
                final city = garage['city']?.toString() ?? '';
                return _selectedCity == 'All' || city == _selectedCity;
              }).toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.surface,
                child: DropdownButtonFormField<String>(
                  value: cities.contains(_selectedCity) ? _selectedCity : 'All',
                  decoration: const InputDecoration(
                    labelText: 'Filter by city',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items:
                      cities
                          .map(
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) => setState(() => _selectedCity = value ?? 'All'),
                ),
              ),
              Expanded(
                child:
                    filtered.isEmpty
                        ? const _EmptyState(
                          icon: Icons.location_off,
                          message: 'Verified garages will appear here.',
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder:
                              (context, index) =>
                                  _GarageCard(garage: filtered[index]),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _citiesFrom(List<Map<String, dynamic>> garages) {
    final cities =
        garages
            .map((garage) => garage['city']?.toString().trim() ?? '')
            .where((city) => city.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...cities];
  }
}

class _GarageCard extends StatelessWidget {
  const _GarageCard({required this.garage});

  final Map<String, dynamic> garage;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.inputFill,
                  child: Icon(Icons.garage, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        garage['businessName']?.toString() ?? 'Garage',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        garage['ownerName']?.toString() ?? 'Verified provider',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  label: Text('Verified'),
                  backgroundColor: AppTheme.success,
                  labelStyle: TextStyle(color: AppTheme.buttonText),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.location_on,
              text: garage['address']?.toString() ?? 'Address not provided',
            ),
            _InfoRow(
              icon: Icons.location_city,
              text: garage['city']?.toString() ?? 'City not provided',
            ),
            _InfoRow(
              icon: Icons.phone,
              text: garage['phone']?.toString() ?? 'Phone not provided',
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance
                      .collection('services')
                      .where('providerId', isEqualTo: garage['id'])
                      .where('isActive', isEqualTo: true)
                      .snapshots(),
              builder: (context, snapshot) {
                final services =
                    snapshot.data?.docs
                        .map((doc) => doc.data()['name']?.toString() ?? '')
                        .where((name) => name.isNotEmpty)
                        .take(4)
                        .toList() ??
                    [];
                if (services.isEmpty) {
                  return const Text(
                    'No active services listed yet.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      services
                          .map(
                            (service) => Chip(
                              label: Text(service),
                              backgroundColor: AppTheme.inputFill,
                            ),
                          )
                          .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

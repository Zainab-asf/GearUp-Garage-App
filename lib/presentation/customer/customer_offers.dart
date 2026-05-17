import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/data/repositories/garage_repository.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage>
    with SingleTickerProviderStateMixin {
  final GarageRepository _repository = GarageRepository();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Special Offers'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.local_offer, size: 20)),
            Tab(text: 'Services', icon: Icon(Icons.build, size: 20)),
            Tab(text: 'Parts', icon: Icon(Icons.settings, size: 20)),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _repository.activeOffers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.secondary),
            );
          }

          if (snapshot.hasError) {
            return const _EmptyState(
              icon: Icons.cloud_off,
              title: 'Could not load offers',
              message: 'Check your connection and try again.',
            );
          }

          final offers =
              snapshot.data?.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .where(_isCurrentOffer)
                  .toList() ??
              [];

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.local_offer,
                      size: 40,
                      color: AppTheme.buttonText,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Live marketplace offers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.buttonText,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OffersList(
                      offers: offers,
                      onClaim: _claimOffer,
                      onDetails: _showOfferDetails,
                    ),
                    _OffersList(
                      offers:
                          offers
                              .where((offer) => offer['category'] == 'service')
                              .toList(),
                      onClaim: _claimOffer,
                      onDetails: _showOfferDetails,
                    ),
                    _OffersList(
                      offers:
                          offers
                              .where((offer) => offer['category'] == 'parts')
                              .toList(),
                      onClaim: _claimOffer,
                      onDetails: _showOfferDetails,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isCurrentOffer(Map<String, dynamic> offer) {
    final validUntil = _dateFrom(offer['validUntil']);
    return validUntil == null ||
        validUntil.isAfter(DateTime.now().subtract(const Duration(days: 1)));
  }

  void _showOfferDetails(Map<String, dynamic> offer) {
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
                      Text(
                        offer['title']?.toString() ?? 'Offer',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        offer['description']?.toString() ??
                            'No description provided.',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _InfoRow(
                        icon: Icons.garage,
                        text:
                            offer['garage']?.toString() ??
                            offer['businessName']?.toString() ??
                            'Partner garage',
                      ),
                      _InfoRow(
                        icon: Icons.location_on,
                        text: offer['location']?.toString() ?? 'All areas',
                      ),
                      _InfoRow(
                        icon: Icons.schedule,
                        text: 'Valid until ${_dateText(offer['validUntil'])}',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        offer['terms']?.toString() ??
                            'No additional terms provided.',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _claimOffer(offer);
                        },
                        icon: const Icon(Icons.local_offer),
                        label: const Text('Claim this offer'),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _claimOffer(Map<String, dynamic> offer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Claim offer'),
            content: Text(
              'Generate a coupon for ${offer['title'] ?? 'this offer'}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Claim'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    final couponCode = await _repository.claimOffer(
      offerId: offer['id'].toString(),
      offer: offer,
    );

    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Offer claimed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 56,
                  color: AppTheme.success,
                ),
                const SizedBox(height: 16),
                const Text('Your coupon code is:'),
                const SizedBox(height: 8),
                SelectableText(
                  couponCode,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }
}

class _OffersList extends StatelessWidget {
  const _OffersList({
    required this.offers,
    required this.onClaim,
    required this.onDetails,
  });

  final List<Map<String, dynamic>> offers;
  final ValueChanged<Map<String, dynamic>> onClaim;
  final ValueChanged<Map<String, dynamic>> onDetails;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return const _EmptyState(
        icon: Icons.local_offer_outlined,
        title: 'No offers available',
        message: 'Active offers created in Firestore will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder:
          (context, index) => _OfferCard(
            offer: offers[index],
            onClaim: () => onClaim(offers[index]),
            onDetails: () => onDetails(offers[index]),
          ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.onClaim,
    required this.onDetails,
  });

  final Map<String, dynamic> offer;
  final VoidCallback onClaim;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final category = offer['category']?.toString() ?? 'service';
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: category == 'parts' ? AppTheme.secondary : AppTheme.primary,
            child: Row(
              children: [
                Icon(
                  category == 'parts' ? Icons.settings : Icons.build,
                  color: AppTheme.buttonText,
                  size: 34,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['title']?.toString() ?? 'Offer',
                        style: const TextStyle(
                          color: AppTheme.buttonText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        offer['garage']?.toString() ??
                            offer['businessName']?.toString() ??
                            'Partner garage',
                        style: TextStyle(
                          color: AppTheme.buttonText.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text('${offer['discount'] ?? 'Deal'}'),
                  backgroundColor: AppTheme.error,
                  labelStyle: const TextStyle(color: AppTheme.buttonText),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer['description']?.toString() ??
                      'No description provided.',
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      _offerPrice(offer),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _dateText(offer['validUntil']),
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDetails,
                        icon: const Icon(Icons.info, size: 16),
                        label: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onClaim,
                        icon: const Icon(Icons.local_offer, size: 16),
                        label: const Text('Claim'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
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

String _offerPrice(Map<String, dynamic> offer) {
  final discounted = offer['discountedPrice']?.toString();
  if (discounted != null && discounted.trim().isNotEmpty) {
    return discounted.toUpperCase() == 'FREE' ? 'FREE' : 'Rs. $discounted';
  }
  final percent = offer['discount']?.toString();
  return percent == null ? 'Special offer' : '$percent OFF';
}

DateTime? _dateFrom(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

String _dateText(Object? value) {
  final date = _dateFrom(value);
  if (date == null) return 'No expiry';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

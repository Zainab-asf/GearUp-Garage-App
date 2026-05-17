import 'package:flutter/material.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _offers = [
    {
      'id': '1',
      'title': '50% OFF Oil Change',
      'description': 'Get 50% discount on oil change service for all vehicles',
      'originalPrice': '4,000',
      'discountedPrice': '2,000',
      'discount': '50%',
      'validUntil': '2024-02-15',
      'garage': 'GearUp Auto Service',
      'location': 'Faisalabad',
      'category': 'service',
      'terms':
          'Valid for synthetic oil only. Cannot be combined with other offers.',
      'isActive': true,
      'image': 'assets/images/oil_change_offer.jpg',
    },
    {
      'id': '2',
      'title': 'Free Car Wash with Service',
      'description':
          'Get complimentary car wash with any service above Rs. 5,000',
      'originalPrice': '1,500',
      'discountedPrice': 'FREE',
      'discount': '100%',
      'validUntil': '2024-02-20',
      'garage': 'Elite Car Care',
      'location': 'Lahore',
      'category': 'service',
      'terms': 'Minimum service amount Rs. 5,000 required. Exterior wash only.',
      'isActive': true,
      'image': 'assets/images/car_wash_offer.jpg',
    },
    {
      'id': '3',
      'title': 'Buy 2 Get 1 Free Brake Pads',
      'description': 'Purchase 2 brake pads and get 1 absolutely free',
      'originalPrice': '25,500',
      'discountedPrice': '17,000',
      'discount': '33%',
      'validUntil': '2024-02-10',
      'garage': 'AutoParts Hub',
      'location': 'Karachi',
      'category': 'parts',
      'terms':
          'Valid for same model brake pads only. Installation charges separate.',
      'isActive': true,
      'image': 'assets/images/brake_pads_offer.jpg',
    },
    {
      'id': '4',
      'title': '25% OFF All Tires',
      'description': 'Get 25% discount on all tire brands and sizes',
      'originalPrice': '40,000',
      'discountedPrice': '30,000',
      'discount': '25%',
      'validUntil': '2024-01-31',
      'garage': 'Tire World',
      'location': 'Islamabad',
      'category': 'parts',
      'terms':
          'Valid for set of 4 tires. Balancing and alignment charges extra.',
      'isActive': false,
      'image': 'assets/images/tire_offer.jpg',
    },
    {
      'id': '5',
      'title': 'Engine Checkup for Rs. 999',
      'description': 'Complete engine diagnostic and checkup at special price',
      'originalPrice': '2,500',
      'discountedPrice': '999',
      'discount': '60%',
      'validUntil': '2024-02-25',
      'garage': 'Master Mechanic',
      'location': 'Rawalpindi',
      'category': 'service',
      'terms': 'Diagnostic only. Repair charges separate as per requirement.',
      'isActive': true,
      'image': 'assets/images/engine_checkup_offer.jpg',
    },
    {
      'id': '6',
      'title': 'New Customer Special - 30% OFF',
      'description': 'First-time customers get 30% off on any service',
      'originalPrice': 'Variable',
      'discountedPrice': '30% OFF',
      'discount': '30%',
      'validUntil': '2024-03-01',
      'garage': 'All Partner Garages',
      'location': 'All Cities',
      'category': 'service',
      'terms': 'Valid for new customers only. ID verification required.',
      'isActive': true,
      'image': 'assets/images/new_customer_offer.jpg',
    },
  ];

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

  List<Map<String, dynamic>> _getFilteredOffers(String filter) {
    switch (filter) {
      case 'active':
        return _offers.where((offer) => offer['isActive']).toList();
      case 'service':
        return _offers
            .where(
              (offer) => offer['category'] == 'service' && offer['isActive'],
            )
            .toList();
      case 'parts':
        return _offers
            .where((offer) => offer['category'] == 'parts' && offer['isActive'])
            .toList();
      default:
        return _offers.where((offer) => offer['isActive']).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Special Offers',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Offers', icon: Icon(Icons.local_offer, size: 20)),
            Tab(text: 'Services', icon: Icon(Icons.build, size: 20)),
            Tab(text: 'Parts', icon: Icon(Icons.settings, size: 20)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[400]!, Colors.red[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.local_offer, size: 40, color: Colors.white),
                const SizedBox(height: 8),
                const Text(
                  'Limited Time Offers!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Save up to 60% on services and parts',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
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
                _buildOffersList(_getFilteredOffers('active')),
                _buildOffersList(_getFilteredOffers('service')),
                _buildOffersList(_getFilteredOffers('parts')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersList(List<Map<String, dynamic>> offers) {
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No offers available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return _buildOfferCard(offer);
      },
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final isExpired = DateTime.parse(
      offer['validUntil'],
    ).isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    offer['category'] == 'service'
                        ? Colors.blue[500]
                        : Colors.green[500],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      offer['category'] == 'service'
                          ? Icons.build
                          : Icons.settings,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer['garage'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${offer['discount']} OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Offer Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2C3E50),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Price Section
                  Row(
                    children: [
                      if (offer['originalPrice'] != 'Variable') ...[
                        Text(
                          'Rs. ${offer['originalPrice']}',
                          style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        offer['discountedPrice'] == 'FREE'
                            ? 'FREE'
                            : offer['discountedPrice'].contains('%')
                            ? offer['discountedPrice']
                            : 'Rs. ${offer['discountedPrice']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              offer['discountedPrice'] == 'FREE'
                                  ? Colors.green
                                  : const Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Location and Validity
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        offer['location'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Valid until ${offer['validUntil']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isExpired ? Colors.red : Colors.grey[600],
                          fontWeight:
                              isExpired ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Terms
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            offer['terms'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showOfferDetails(offer);
                          },
                          icon: const Icon(Icons.info, size: 16),
                          label: const Text(
                            'Details',
                            style: TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2196F3),
                            side: const BorderSide(color: Color(0xFF2196F3)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              isExpired
                                  ? null
                                  : () {
                                    _claimOffer(offer);
                                  },
                          icon: Icon(
                            isExpired ? Icons.schedule : Icons.local_offer,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            isExpired ? 'Expired' : 'Claim Offer',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isExpired
                                    ? Colors.grey
                                    : const Color(0xFF2196F3),
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
          ],
        ),
      ),
    );
  }

  void _showOfferDetails(Map<String, dynamic> offer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
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
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Offer title
                  Text(
                    offer['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Offer details
                  Text(
                    'Description:',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offer['description'],
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Terms & Conditions:',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offer['terms'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 20),

                  // Garage info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available at:',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          offer['garage'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        Text(
                          offer['location'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _claimOffer(offer);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Claim This Offer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _claimOffer(Map<String, dynamic> offer) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Claim Offer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You are about to claim: ${offer['title']}'),
                const SizedBox(height: 16),
                const Text(
                  'This will generate a unique coupon code that you can use at the garage.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _generateCoupon(offer);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                ),
                child: const Text(
                  'Claim Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _generateCoupon(Map<String, dynamic> offer) {
    final couponCode =
        'AUTO${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Offer Claimed!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                const Text('Your coupon code is:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    couponCode,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Show this code at ${offer['garage']} to avail the discount.',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

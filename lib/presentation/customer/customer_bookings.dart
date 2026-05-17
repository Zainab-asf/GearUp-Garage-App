import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:gearup_garage/presentation/customer/customer_chat.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> services = [
    {
      'name': 'Oil Change',
      'duration': '45 mins',
      'price': 49.99,
      'garage': 'AutoCare Garage',
      'description': 'Full synthetic oil change with filter replacement.',
    },
    {
      'name': 'Tire Rotation & Balancing',
      'duration': '30 mins',
      'price': 29.99,
      'garage': 'Premium Motors',
      'description': 'Ensure even tire wear and extend tire life.',
    },
    {
      'name': 'Brake Inspection',
      'duration': '60 mins',
      'price': 75.00,
      'garage': 'QuickFix Auto',
      'description': 'Complete check of brake pads, rotors, and fluids.',
    },
    {
      'name': 'AC Service',
      'duration': '40 mins',
      'price': 55.00,
      'garage': 'CoolAuto Services',
      'description': 'AC gas refill, leakage check, and performance testing.',
    },
    {
      'name': 'Car Wash & Vacuum',
      'duration': '25 mins',
      'price': 15.00,
      'garage': 'Sparkle Station',
      'description': 'Interior vacuuming and exterior foam wash.',
    },
    {
      'name': 'Engine Diagnostics',
      'duration': '50 mins',
      'price': 89.00,
      'garage': 'MotorCheck Hub',
      'description': 'Full engine diagnostics using OBD-II scanner.',
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

  Future<void> bookService(Map<String, dynamic> service) async {
    // Show dialog to collect user information
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController vehicleController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Model',
                  hintText: 'e.g., Toyota Camry 2020',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    vehicleController.text.isNotEmpty) {
                  Navigator.of(context).pop({
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'vehicle': vehicleController.text,
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Confirm Booking'),
            ),
          ],
        );
      },
    );

    if (result == null) return; // User cancelled

    final now = DateTime.now();
    final currentUser = FirebaseAuth.instance.currentUser;

    // Get provider information - ENSURE every booking has a provider
    String providerId = service['providerId'] ?? '';
    String providerName = 'GearUp Service';

    // If no specific provider, find any verified provider
    if (providerId.isEmpty || providerId == '') {
      try {
        final providerQuery =
            await FirebaseFirestore.instance
                .collection('service_providers')
                .where('isVerified', isEqualTo: true)
                .limit(1)
                .get();

        if (providerQuery.docs.isNotEmpty) {
          final providerDoc = providerQuery.docs.first;
          providerId = providerDoc.id;
          final providerData = providerDoc.data();
          providerName = providerData['businessName'] ?? 'GearUp Service';
          print('Assigned booking to provider: $providerId ($providerName)');
        } else {
          // If no verified providers, assign to admin
          providerId = 'admin_provider';
          providerName = 'GearUp Admin Service';
          print('No verified providers found, assigned to admin');
        }
      } catch (e) {
        print('Error finding provider: $e');
        providerId = 'admin_provider';
        providerName = 'GearUp Admin Service';
      }
    } else {
      // Get specific provider info
      try {
        final providerDoc =
            await FirebaseFirestore.instance
                .collection('service_providers')
                .doc(providerId)
                .get();
        if (providerDoc.exists) {
          final providerData = providerDoc.data() as Map<String, dynamic>;
          providerName = providerData['businessName'] ?? 'GearUp Service';
          print('Using specific provider: $providerId ($providerName)');
        }
      } catch (e) {
        print('Error fetching provider: $e');
      }
    }

    final booking = {
      'service': service['name'],
      'duration': service['duration'],
      'price': service['price'],
      'garage': providerName,
      'description': service['description'],
      'status': 'Pending',
      'date': DateFormat('yyyy-MM-dd').format(now),
      'time': DateFormat('hh:mm a').format(now),
      'timestamp': now,
      'customerName': result['name'],
      'customerPhone': result['phone'],
      'customerEmail': currentUser?.email ?? '',
      'customerUid': currentUser?.uid ?? '',
      'vehicleModel': result['vehicle'],
      'providerId': providerId,
      'providerName': providerName,
      'category': service['category'] ?? 'General',
    };

    print('Creating booking with data: $booking'); // Debug log

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('bookings')
          .add(booking);
      print('Booking created successfully with ID: ${docRef.id}'); // Debug log

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Service booked successfully! Provider: $providerName',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error creating booking: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error booking service: $e')));
      }
    }
  }

  Future<void> cancelBooking(String docId) async {
    await FirebaseFirestore.instance.collection('bookings').doc(docId).delete();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
    }
  }

  Widget buildRealServiceCard(Map<String, dynamic> service) {
    // Get service image based on service name or category
    String getServiceImage(String serviceName, String category) {
      final name = serviceName.toLowerCase();
      final cat = category.toLowerCase();

      if (name.contains('oil') || name.contains('change')) {
        return 'assets/images/01.jpeg';
      }
      if (name.contains('brake') || name.contains('pad')) {
        return 'assets/images/breakpads.jpg';
      }
      if (name.contains('battery')) {
        return 'assets/images/battery.jpg';
      }
      if (name.contains('air') || name.contains('filter')) {
        return 'assets/images/airfilter.jpg';
      }
      if (name.contains('wheel') || name.contains('alloy')) {
        return 'assets/images/alloywhells.jpg';
      }
      if (name.contains('shock') || name.contains('absorber')) {
        return 'assets/images/shcokabsorber.jpg';
      }
      if (name.contains('light') || name.contains('universal')) {
        return 'assets/images/unversallights.jpg';
      }
      if (cat.contains('maintenance')) {
        return 'assets/images/02.png';
      }
      if (cat.contains('repair')) {
        return 'assets/images/03.jpeg';
      }
      if (cat.contains('inspection')) {
        return 'assets/images/04.jpeg';
      }

      // Default images
      return 'assets/images/car.png';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.inputBorder.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.inputBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(
                  getServiceImage(
                    service['name'] ?? '',
                    service['category'] ?? '',
                  ),
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            service['name'] ?? 'Service',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service['description'] ?? 'Service description',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppTheme.secondary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                service['duration'] ?? '30 mins',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.local_offer_rounded,
                color: AppTheme.secondary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '\$${(service['price'] ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Category: ${service['category'] ?? 'General'}",
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => bookService(service),
              icon: const Icon(Icons.add),
              label: const Text(
                "Book",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildServiceCard(Map<String, dynamic> service) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('services')
              .where('isActive', isEqualTo: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.inputBorder),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.secondary),
            ),
          );
        }

        // Use real service data if available, otherwise use hardcoded data
        final realServices = snapshot.data!.docs;
        final serviceData =
            realServices.isNotEmpty
                ? realServices.first.data() as Map<String, dynamic>
                : service;

        // Use serviceData for display
        final displayService = serviceData;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            boxShadow: [
              BoxShadow(
                color: AppTheme.inputBorder.withOpacity(0.6),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.inputBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayService['name'] ?? 'Service',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                displayService['description'] ?? 'Service description',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: AppTheme.secondary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    displayService['duration'] ?? '30 mins',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.local_offer_rounded,
                    color: AppTheme.secondary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '\$${(displayService['price'] ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Category: ${displayService['category'] ?? 'General'}",
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => bookService(displayService),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    "Book",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildBookingCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Get booking image based on service name
    String getBookingImage(String serviceName) {
      final name = serviceName.toLowerCase();

      if (name.contains('oil') || name.contains('change')) {
        return 'assets/images/01.jpeg';
      }
      if (name.contains('brake') || name.contains('pad')) {
        return 'assets/images/breakpads.jpg';
      }
      if (name.contains('battery')) {
        return 'assets/images/battery.jpg';
      }
      if (name.contains('air') || name.contains('filter')) {
        return 'assets/images/airfilter.jpg';
      }
      if (name.contains('wheel') || name.contains('alloy')) {
        return 'assets/images/alloywhells.jpg';
      }
      if (name.contains('shock') || name.contains('absorber')) {
        return 'assets/images/shcokabsorber.jpg';
      }
      if (name.contains('light') || name.contains('universal')) {
        return 'assets/images/unversallights.jpg';
      }

      // Default images
      return 'assets/images/car.png';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.inputBorder.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.inputBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking Image
          Container(
            width: double.infinity,
            height: 150,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(getBookingImage(data['service'] ?? '')),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            "Booking: ${data['service']}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Garage: ${data['garage']}",
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          Text(
            "Date: ${data['date']} at ${data['time']}",
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          Text(
            "Status: ${data['status']}",
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "Price: \$${data['price']}",
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chat Button
              if (data['providerId'] != null &&
                  data['providerId'].toString().isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CustomerChatScreen(
                              bookingId: doc.id,
                              providerId: data['providerId'] ?? '',
                              providerName:
                                  data['providerName'] ??
                                  data['garage'] ??
                                  'Service Provider',
                            ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat, color: AppTheme.primary),
                  label: const Text(
                    "Chat",
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              // Cancel Button
              TextButton.icon(
                onPressed: () => cancelBooking(doc.id),
                icon: const Icon(Icons.cancel, color: AppTheme.error),
                label: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget servicesTab() {
    return Column(
      children: [
        // Services List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('services')
                    .where('isActive', isEqualTo: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.secondary),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: AppTheme.error),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please check your connection and try again',
                        style: TextStyle(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {}); // Trigger rebuild
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.build_outlined,
                        size: 64,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No services available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Services will appear here once providers are approved',
                        style: TextStyle(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final realServices = snapshot.data!.docs;

              return ListView.builder(
                itemCount: realServices.length,
                itemBuilder: (context, index) {
                  final serviceData =
                      realServices[index].data() as Map<String, dynamic>;
                  serviceData['id'] = realServices[index].id; // Add document ID
                  return buildRealServiceCard(serviceData);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget myBookingsTab() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(
        child: Text(
          'Please log in to view your bookings',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('bookings')
              .snapshots(), // Get all bookings and filter manually
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading bookings',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.secondary),
          );
        }

        final allBookings = snapshot.data!.docs;

        // Filter bookings for current user
        final bookings =
            allBookings.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final customerEmail = data['customerEmail'] as String?;
              final customerUid = data['customerUid'] as String?;

              // Match by email, UID, or if no email field exists, show all for now
              return customerEmail == currentUser.email ||
                  customerUid == currentUser.uid ||
                  customerEmail ==
                      null; // Fallback for old bookings without email
            }).toList();

        // Sort bookings by timestamp manually
        bookings.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTimestamp = aData['timestamp'] as Timestamp?;
          final bTimestamp = bData['timestamp'] as Timestamp?;

          if (aTimestamp == null && bTimestamp == null) return 0;
          if (aTimestamp == null) return 1;
          if (bTimestamp == null) return -1;

          return bTimestamp.compareTo(aTimestamp); // Descending order
        });

        if (bookings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'No bookings found',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your bookings will appear here',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView(
          children: bookings.map((doc) => buildBookingCard(doc)).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppTheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            tabs: const [Tab(text: 'Services'), Tab(text: 'My Bookings')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [servicesTab(), myBookingsTab()],
          ),
        ),
      ],
    );
  }
}

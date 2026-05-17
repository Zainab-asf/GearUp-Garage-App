import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gearup_garage/presentation/customer/customer_bookings.dart';
import 'package:gearup_garage/presentation/customer/customer_messages.dart';
import 'package:gearup_garage/presentation/customer/customer_profile.dart';
import 'package:gearup_garage/presentation/customer/customer_search.dart';
import 'package:gearup_garage/presentation/customer/customer_services.dart';
import 'package:gearup_garage/presentation/customer/customer_buy_sell.dart';
import 'package:gearup_garage/presentation/customer/customer_parts.dart';
import 'package:gearup_garage/presentation/customer/customer_nearby_garages.dart';
import 'package:gearup_garage/presentation/customer/customer_book_service.dart';
import 'package:gearup_garage/presentation/customer/customer_offers.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});
  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int _selectedIndex = 0;

  // User data for drawer header
  String _drawerUserName = 'Atta Noor';
  String _drawerUserEmail = 'Attanoor922@gmail.com';
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final List<Widget> _pages = [
    MainHomeContent(),
    const BookingPage(),
    const CustomerMessagesPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadDrawerUserData();
  }

  Future<void> _loadDrawerUserData() async {
    if (_currentUser == null) return;

    try {
      // Get user data from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser.uid)
              .get();

      if (userDoc.exists) {
        Map<String, dynamic> firestoreData =
            userDoc.data() as Map<String, dynamic>;

        setState(() {
          String firstName = firestoreData['firstName'] ?? '';
          String lastName = firestoreData['lastName'] ?? '';
          _drawerUserName = '$firstName $lastName'.trim();
          if (_drawerUserName.isEmpty) {
            _drawerUserName = _currentUser.displayName ?? 'User';
          }
          _drawerUserEmail = _currentUser.email ?? 'No email';
        });
      } else {
        // If no Firestore document exists, use Firebase Auth data
        setState(() {
          _drawerUserName = _currentUser.displayName ?? 'User';
          _drawerUserEmail = _currentUser.email ?? 'No email';
        });
      }
    } catch (e) {
      // Keep default values if error occurs
      // ignore: avoid_print
      print('Error loading drawer user data: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppTheme.primary.withOpacity(0.15)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text(
            'Logout',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, 'login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: AppTheme.textPrimary,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  final List<IconData> _icons = [
    Icons.home,
    Icons.calendar_today,
    Icons.chat,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('GearUp Garage')),

      drawer: Drawer(
        backgroundColor: AppTheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppTheme.surface),
              accountName: Text(
                _drawerUserName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              accountEmail: Text(
                _drawerUserEmail,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppTheme.card,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/atta.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              onDetailsPressed: () => _onItemTapped(3),
            ),
            _buildDrawerItem(
              icon: Icons.garage,
              title: 'Home',
              isSelected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            _buildDrawerItem(
              icon: Icons.car_repair,
              title: 'Bookings',
              isSelected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            _buildDrawerItem(
              icon: Icons.chat,
              title: 'Messages',
              isSelected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            _buildDrawerItem(
              icon: Icons.account_circle,
              title: 'Profile',
              isSelected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            Divider(
              color: AppTheme.textSecondary.withOpacity(0.3),
              thickness: 1,
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              isSelected: false,
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.exit_to_app,
              title: 'Logout',
              isSelected: false,
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),

      body: _pages[_selectedIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        },
        backgroundColor:
            Theme.of(context).floatingActionButtonTheme.backgroundColor,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppTheme.buttonText, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Custom Elite Bottom Navigation Bar - Full Width
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (index) {
              final isSelected = _selectedIndex == index;
              final List<String> labels = [
                'Home',
                'Bookings',
                'Messages',
                'Profile',
              ];
              final Color selectedColor =
                  Theme.of(context).bottomNavigationBarTheme.selectedItemColor!;
              final Color unselectedColor =
                  Theme.of(
                    context,
                  ).bottomNavigationBarTheme.unselectedItemColor!;
              return Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _icons[index],
                          size: 24,
                          color: isSelected ? selectedColor : unselectedColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? selectedColor : unselectedColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class MainHomeContent extends StatelessWidget {
  final List<Map<String, String>> featuredCars = [
    {
      'title': 'Rolls Royce 2025',
      'price': 'PKR 5,100,000',
      'location': 'Faisalabad',
      'image': 'assets/images/RollsRoyce.jpg',
    },
    {
      'title': 'Maseriti V12 2025',
      'price': 'PKR 4,200,000',
      'location': 'Faisalabad',
      'image': 'assets/images/Maserati.jpg',
    },
    {
      'title': 'BMW Bike 3 2025',
      'price': 'PKR 9,350,000',
      'location': 'Karachi',
      'image': 'assets/images/bmw.jpg',
    },
    {
      'title': 'Lamborghini Bike 2022',
      'price': 'PKR 2,700,000',
      'location': 'Karachi',
      'image': 'assets/images/lemborgini.jpg',
    },
  ];

  MainHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to GearUp Garage',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Premium care. Fast bookings. Trusted garages.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search services or garages',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(height: 20),
          SectionTitle('Featured Cars'),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featuredCars.length,
              itemBuilder: (context, index) {
                final car = featuredCars[index];
                return FeaturedCarCard(
                  title: car['title']!,
                  price: car['price']!,
                  location: car['location']!,
                  imageUrl: car['image']!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    QuickAccessItem(icon: Icons.build, label: 'Services'),
                    QuickAccessItem(
                      icon: Icons.directions_car,
                      label: 'Buy/Sell',
                    ),
                    QuickAccessItem(icon: Icons.settings, label: 'Parts'),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    QuickAccessItem(icon: Icons.location_on, label: 'Nearby'),
                    QuickAccessItem(icon: Icons.calendar_today, label: 'Book'),
                    QuickAccessItem(icon: Icons.local_offer, label: 'Offers'),
                  ],
                ),
              ],
            ),
          ),
          SectionTitle('Popular Services'),
          SizedBox(
            height: 120,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  ServiceCard(service: 'Oil Change'),
                  ServiceCard(service: 'Brake Replacement'),
                  ServiceCard(service: 'Battery Check'),
                  ServiceCard(service: 'AC Repair'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedCarCard extends StatelessWidget {
  final String title;
  final String price;
  final String location;
  final String imageUrl;

  const FeaturedCarCard({
    super.key,
    required this.title,
    required this.price,
    required this.location,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => DashboardScreen(
                  title: title,
                  price: price,
                  location: location,
                  imageUrl: imageUrl,
                ),
          ),
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.inputBorder.withOpacity(0.6),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          height: 130,
                          color: AppTheme.inputFill,
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'FEATURED',
                      style: TextStyle(
                        color: AppTheme.buttonText,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(color: AppTheme.secondary, fontSize: 14),
                  ),
                  SizedBox(height: 2),
                  Text(
                    location,
                    style: TextStyle(color: AppTheme.textSecondary),
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

class DashboardScreen extends StatelessWidget {
  final String title;
  final String price;
  final String location;
  final String imageUrl;

  const DashboardScreen({
    super.key,
    required this.title,
    required this.price,
    required this.location,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    height: 250,
                    color: AppTheme.inputFill,
                    child: const Icon(Icons.image_not_supported, size: 80),
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: $price',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Location: $location',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Add to Cart'),
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

class QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const QuickAccessItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case 'Services':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ServicesPage()),
            );
            break;
          case 'Buy/Sell':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BuySellPage()),
            );
            break;
          case 'Parts':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PartsPage()),
            );
            break;
          case 'Nearby':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NearbyPage()),
            );
            break;
          case 'Book':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookPage()),
            );
            break;
          case 'Offers':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OffersPage()),
            );
            break;
          default:
            // Show coming soon for any other features
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label feature coming soon!'),
                backgroundColor: AppTheme.primary,
              ),
            );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.inputBorder.withOpacity(0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 28, color: AppTheme.primary),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String service;
  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$service service coming soon!'),
            backgroundColor: AppTheme.primary,
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.inputBorder),
          boxShadow: [
            BoxShadow(
              color: AppTheme.inputBorder.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              service,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

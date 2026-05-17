import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfilePage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> _user = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Get user data from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser.uid)
              .get();

      // Get booking statistics
      QuerySnapshot bookingsSnapshot =
          await FirebaseFirestore.instance
              .collection('bookings')
              .where('customerEmail', isEqualTo: _currentUser.email)
              .get();

      // If no customerEmail field, try with customerName (fallback)
      if (bookingsSnapshot.docs.isEmpty) {
        // Try to get bookings by matching customer name if available
        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          String fullName =
              '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
                  .trim();
          if (fullName.isNotEmpty) {
            bookingsSnapshot =
                await FirebaseFirestore.instance
                    .collection('bookings')
                    .where('customerName', isEqualTo: fullName)
                    .get();
          }
        }
      }

      int totalBookings = bookingsSnapshot.docs.length;
      int completedServices =
          bookingsSnapshot.docs
              .where(
                (doc) =>
                    (doc.data() as Map<String, dynamic>)['status'] ==
                    'Completed',
              )
              .length;

      if (userDoc.exists) {
        Map<String, dynamic> firestoreData =
            userDoc.data() as Map<String, dynamic>;

        setState(() {
          _user = {
            'name':
                '${firestoreData['firstName'] ?? ''} ${firestoreData['lastName'] ?? ''}'
                    .trim(),
            'email': _currentUser.email ?? 'No email',
            'phone': firestoreData['phone'] ?? '',
            'joinDate': firestoreData['createdAt']?.toDate() ?? DateTime.now(),
            'profileImage': firestoreData['profileImage'],
            'address': firestoreData['address'] ?? 'No address provided',
            'totalBookings': totalBookings,
            'completedServices': completedServices,
            'vehicles': firestoreData['vehicles'] ?? [],
          };
          _isLoading = false;
        });
      } else {
        // If no Firestore document exists, use Firebase Auth data
        setState(() {
          _user = {
            'name': _currentUser.displayName ?? 'User',
            'email': _currentUser.email ?? 'No email',
            'phone': '',
            'joinDate': _currentUser.metadata.creationTime ?? DateTime.now(),
            'profileImage': _currentUser.photoURL,
            'address': 'No address provided',
            'totalBookings': totalBookings,
            'completedServices': completedServices,
            'vehicles': [],
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.buttonPrimary),
      );
    }

    if (_currentUser == null) {
      return const Center(
        child: Text(
          'Please log in to view your profile',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      color: AppTheme.buttonPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(theme),
            const SizedBox(height: 24),
            _buildQuickStats(theme),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuSection(
                    title: 'My Vehicles',
                    icon: Icons.directions_car,
                    children: [_buildVehiclesSection()],
                  ),
                  const SizedBox(height: 24),
                  _buildMenuSection(
                    title: 'Account Settings',
                    icon: Icons.settings,
                    children: [
                      _buildSettingItem(
                        icon: Icons.person,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        onTap: _editProfile,
                      ),
                      _buildSettingItem(
                        icon: Icons.location_on,
                        title: 'Address Book',
                        subtitle: 'Manage your addresses',
                        onTap: _manageAddresses,
                      ),
                      _buildSettingItem(
                        icon: Icons.payment,
                        title: 'Payment Methods',
                        subtitle: 'Manage cards and payment options',
                        onTap: _managePayments,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildMenuSection(
                    title: 'Support & Legal',
                    icon: Icons.help_outline,
                    children: [
                      _buildSettingItem(
                        icon: Icons.help,
                        title: 'Help & Support',
                        subtitle: 'Get help and contact support',
                        onTap: _openSupport,
                      ),
                      _buildSettingItem(
                        icon: Icons.star,
                        title: 'Rate App',
                        subtitle: 'Rate us on the app store',
                        onTap: _rateApp,
                      ),
                      _buildSettingItem(
                        icon: Icons.privacy_tip,
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy',
                        onTap: _openPrivacyPolicy,
                      ),
                      _buildSettingItem(
                        icon: Icons.description,
                        title: 'Terms of Service',
                        subtitle: 'Read our terms and conditions',
                        onTap: _openTerms,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        foregroundColor: AppTheme.buttonText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                child:
                    _user['profileImage'] != null
                        ? ClipOval(
                          child: Image.network(
                            _user['profileImage'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Icon(
                          Icons.person,
                          size: 50,
                          color: AppTheme.buttonPrimary,
                        ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.buttonPrimary,
                  child: IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    onPressed: _changeProfilePicture,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _user['name'] ?? 'User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user['email'] ?? 'No email',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Member since ${(_user['joinDate'] as DateTime?)?.year ?? DateTime.now().year}',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Bookings',
              (_user['totalBookings'] ?? 0).toString(),
              Icons.calendar_today,
              AppTheme.buttonPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Completed',
              (_user['completedServices'] ?? 0).toString(),
              Icons.check_circle,
              AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildVehiclesSection() {
    final vehicles = _user['vehicles'] as List? ?? [];

    return Column(
      children: [
        if (vehicles.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.inputBorder, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  size: 48,
                  color: AppTheme.secondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No vehicles added yet',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your vehicles to track services and bookings',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...vehicles.map(
            (vehicle) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.inputBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.inputBorder.withOpacity(0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.inputFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.inputBorder, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          vehicle['image'] != null
                              ? Image.network(
                                vehicle['image'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.directions_car,
                                      size: 35,
                                      color: AppTheme.primary,
                                    ),
                              )
                              : Icon(
                                Icons.directions_car,
                                size: 35,
                                color: AppTheme.primary,
                              ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle['make'] ?? 'Unknown'} ${vehicle['model'] ?? 'Model'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: AppTheme.buttonPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${vehicle['year'] ?? 'N/A'}',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.palette,
                              size: 14,
                              color: AppTheme.buttonPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${vehicle['color'] ?? 'N/A'}',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.confirmation_number,
                              size: 14,
                              color: AppTheme.buttonPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${vehicle['plate'] ?? 'N/A'}',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.speed,
                              size: 14,
                              color: AppTheme.buttonPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${vehicle['mileage'] ?? 'N/A'}',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.inputFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit, color: AppTheme.primary, size: 20),
                      onPressed: () => _editVehicle(vehicle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.inputBorder, width: 1.5),
          ),
          child: OutlinedButton.icon(
            onPressed: _addVehicle,
            icon: Icon(Icons.add, color: AppTheme.primary),
            label: Text(
              'Add Vehicle',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide.none,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _changeProfilePicture() => _showDialog(
    'Change Profile Picture',
    'Choose how you want to update your profile picture',
  );
  void _editProfile() =>
      _showDialog('Edit Profile', 'Navigate to edit profile screen');
  void _manageAddresses() =>
      _showDialog('Address Book', 'Navigate to address management screen');
  void _managePayments() =>
      _showDialog('Payment Methods', 'Navigate to payment methods screen');
  Future<void> _addVehicle() async {
    final make = TextEditingController();
    final model = TextEditingController();
    final year = TextEditingController();
    final plate = TextEditingController();
    final color = TextEditingController();
    final mileage = TextEditingController();

    final vehicle = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Vehicle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _vehicleField(make, 'Make'),
                  _vehicleField(model, 'Model'),
                  _vehicleField(year, 'Year', TextInputType.number),
                  _vehicleField(plate, 'Plate'),
                  _vehicleField(color, 'Color'),
                  _vehicleField(mileage, 'Mileage'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (make.text.trim().isEmpty || model.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Make and model are required.'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'make': make.text.trim(),
                    'model': model.text.trim(),
                    'year': year.text.trim(),
                    'plate': plate.text.trim(),
                    'color': color.text.trim(),
                    'mileage': mileage.text.trim(),
                    'image': null,
                  });
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );

    for (final controller in [make, model, year, plate, color, mileage]) {
      controller.dispose();
    }

    if (vehicle == null || _currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .set({
          'vehicles': FieldValue.arrayUnion([vehicle]),
        }, SetOptions(merge: true));

    await _loadUserData();
  }

  Widget _vehicleField(
    TextEditingController controller,
    String label, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  void _editVehicle(Map<String, dynamic> v) => _showDialog(
    'Edit ${v['make']} ${v['model']}',
    'Navigate to edit vehicle screen',
  );
  void _openSupport() =>
      _showDialog('Help & Support', 'Navigate to support screen or open chat');
  void _rateApp() => _showDialog('Rate App', 'Rate us on the app store');
  void _openPrivacyPolicy() =>
      _showDialog('Privacy Policy', 'Navigate to privacy policy screen');
  void _openTerms() =>
      _showDialog('Terms of Service', 'Navigate to terms of service screen');

  void _logout() {
    final rootContext = context;
    showDialog(
      context: rootContext,
      builder:
          (context) => AlertDialog(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: AppTheme.buttonText,
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await FirebaseAuth.instance.signOut();
                  if (!rootContext.mounted) return;
                  Navigator.pushReplacementNamed(rootContext, 'login');
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }
}

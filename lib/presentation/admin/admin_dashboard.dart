import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  // Approve or reject a service provider
  Future<void> updateStatus(
    String docId,
    bool isApproved,
    BuildContext context,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('service_providers')
          .doc(docId)
          .update({
            'isVerified': isApproved,
            'approvedAt': FieldValue.serverTimestamp(),
          });

      if (isApproved) {
        // When approved, create default services for the provider
        await _createDefaultServices(docId);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApproved
                ? 'Service Provider Approved!'
                : 'Service Provider Rejected!',
          ),
          backgroundColor: isApproved ? AppTheme.success : AppTheme.error,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update status')));
    }
  }

  // Create default services when a provider is approved
  Future<void> _createDefaultServices(String providerId) async {
    final defaultServices = [
      {
        'name': 'Oil Change',
        'description': 'Full synthetic oil change with filter replacement',
        'price': 49.99,
        'duration': '45 mins',
        'category': 'Maintenance',
        'isActive': true,
        'providerId': providerId,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Brake Inspection',
        'description': 'Complete check of brake pads, rotors, and fluids',
        'price': 75.00,
        'duration': '60 mins',
        'category': 'Safety',
        'isActive': true,
        'providerId': providerId,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Tire Rotation',
        'description': 'Ensure even tire wear and extend tire life',
        'price': 29.99,
        'duration': '30 mins',
        'category': 'Maintenance',
        'isActive': true,
        'providerId': providerId,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (final service in defaultServices) {
      final docRef = FirebaseFirestore.instance.collection('services').doc();
      batch.set(docRef, service);
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, 'login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: AppTheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primary,
              tabs: const [
                Tab(
                  text: 'Pending Approvals',
                  icon: Icon(Icons.pending_actions),
                ),
                Tab(text: 'All Providers', icon: Icon(Icons.business)),
                Tab(text: 'Services', icon: Icon(Icons.build)),
                Tab(text: 'Bookings', icon: Icon(Icons.calendar_today)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingApprovals(),
                _buildAllProviders(),
                _buildServicesManagement(),
                _buildBookingsManagement(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovals() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('service_providers')
              .where('isVerified', isEqualTo: false)
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
                  'Error loading pending approvals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your internet connection and try again',
                  style: const TextStyle(color: AppTheme.textSecondary),
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
                Icon(Icons.check_circle, size: 64, color: AppTheme.success),
                SizedBox(height: 16),
                Text(
                  'No pending approvals',
                  style: TextStyle(fontSize: 18, color: AppTheme.textPrimary),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Sort manually by creation time (most recent first)
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['createdAt'] as Timestamp?;
          final bTime = bData['createdAt'] as Timestamp?;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime); // Descending order
        });

        return ListView(
          children: docs.map((doc) => _buildProviderCard(doc, true)).toList(),
        );
      },
    );
  }

  Widget _buildAllProviders() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('service_providers')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.secondary),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No service providers found',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Sort manually by creation time (most recent first)
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['createdAt'] as Timestamp?;
          final bTime = bData['createdAt'] as Timestamp?;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime); // Descending order
        });

        return ListView(
          children: docs.map((doc) => _buildProviderCard(doc, false)).toList(),
        );
      },
    );
  }

  Widget _buildServicesManagement() {
    return Column(
      children: [
        // Add Service Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showAddServiceDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.buttonText,
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add New Service'),
          ),
        ),
        // Services List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('services').snapshots(),
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
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
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
                        Icons.build,
                        size: 64,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No services found',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add services to get started',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView(
                children: docs.map((doc) => _buildServiceCard(doc)).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: AppTheme.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['name'] ?? 'Unknown Service',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Switch(
                  value: data['isActive'] ?? false,
                  onChanged: (value) => _toggleServiceStatus(doc.id, value),
                  activeColor: AppTheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data['description'] ?? 'No description',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                  Icons.attach_money,
                  '\$${data['price']?.toStringAsFixed(2) ?? '0.00'}',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.access_time, data['duration'] ?? 'N/A'),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.category, data['category'] ?? 'General'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editService(doc),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteService(doc.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddServiceDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    final categoryController = TextEditingController();

    final rootContext = context;

    await showDialog(
      context: rootContext,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Add New Service'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (e.g., 45 mins)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    await FirebaseFirestore.instance.collection('services').add({
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'duration': durationController.text,
                      'category':
                          categoryController.text.isEmpty
                              ? 'General'
                              : categoryController.text,
                      'isActive': true,
                      'providerId':
                          '', // Admin-created services have no specific provider
                      'createdAt': FieldValue.serverTimestamp(),
                      'createdBy': 'admin',
                    });
                    if (!rootContext.mounted) return;
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      const SnackBar(
                        content: Text('Service added successfully!'),
                      ),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _editService(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final nameController = TextEditingController(text: data['name']);
    final descriptionController = TextEditingController(
      text: data['description'],
    );
    final priceController = TextEditingController(
      text: data['price']?.toString(),
    );
    final durationController = TextEditingController(text: data['duration']);
    final categoryController = TextEditingController(text: data['category']);

    final rootContext = context;

    await showDialog(
      context: rootContext,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Edit Service'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(labelText: 'Duration'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('services')
                      .doc(doc.id)
                      .update({
                        'name': nameController.text,
                        'description': descriptionController.text,
                        'price': double.tryParse(priceController.text) ?? 0.0,
                        'duration': durationController.text,
                        'category': categoryController.text,
                        'updatedAt': FieldValue.serverTimestamp(),
                      });
                  if (!rootContext.mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(
                      content: Text('Service updated successfully!'),
                    ),
                  );
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  Future<void> _toggleServiceStatus(String serviceId, bool isActive) async {
    await FirebaseFirestore.instance
        .collection('services')
        .doc(serviceId)
        .update({
          'isActive': isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _deleteService(String serviceId) async {
    final rootContext = context;
    final confirmed = await showDialog<bool>(
      context: rootContext,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Service'),
            content: const Text(
              'Are you sure you want to delete this service?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: AppTheme.buttonText,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .delete();
      if (!rootContext.mounted) return;
      ScaffoldMessenger.of(rootContext).showSnackBar(
        const SnackBar(content: Text('Service deleted successfully!')),
      );
    }
  }

  Widget _buildBookingsManagement() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.secondary),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No bookings found',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Sort manually by timestamp (most recent first)
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['timestamp'] as Timestamp?;
          final bTime = bData['timestamp'] as Timestamp?;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime); // Descending order
        });

        return ListView(
          children: docs.map((doc) => _buildBookingCard(doc)).toList(),
        );
      },
    );
  }

  Widget _buildProviderCard(DocumentSnapshot doc, bool isPending) {
    final data = doc.data() as Map<String, dynamic>;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: AppTheme.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['businessName'] ?? 'Unknown Business',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (!isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          data['isVerified'] == true
                              ? AppTheme.success
                              : AppTheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data['isVerified'] == true ? 'Approved' : 'Rejected',
                      style: const TextStyle(
                        color: AppTheme.buttonText,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'Owner', data['ownerName'] ?? 'N/A'),
            _buildInfoRow(Icons.email, 'Email', data['email'] ?? 'N/A'),
            _buildInfoRow(Icons.phone, 'Phone', data['phone'] ?? 'N/A'),
            _buildInfoRow(
              Icons.location_on,
              'Address',
              data['address'] ?? 'N/A',
            ),
            const SizedBox(height: 16),
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => updateStatus(doc.id, true, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: AppTheme.buttonText,
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => updateStatus(doc.id, false, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        foregroundColor: AppTheme.buttonText,
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['service'] ?? 'Unknown Service',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(data['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['status'] ?? 'Unknown',
                    style: const TextStyle(
                      color: AppTheme.buttonText,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.person,
              'Customer',
              data['customerName'] ?? 'N/A',
            ),
            _buildInfoRow(Icons.email, 'Email', data['customerEmail'] ?? 'N/A'),
            _buildInfoRow(Icons.phone, 'Phone', data['customerPhone'] ?? 'N/A'),
            _buildInfoRow(Icons.calendar_today, 'Date', data['date'] ?? 'N/A'),
            _buildInfoRow(Icons.access_time, 'Time', data['time'] ?? 'N/A'),
            _buildInfoRow(
              Icons.attach_money,
              'Price',
              '\$${data['price'] ?? 'N/A'}',
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return AppTheme.primary;
      case 'Confirmed':
        return AppTheme.secondary;
      case 'In Progress':
        return AppTheme.accent;
      case 'Completed':
        return AppTheme.success;
      case 'Cancelled':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }
}

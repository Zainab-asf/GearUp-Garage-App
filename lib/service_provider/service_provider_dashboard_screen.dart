import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'provider_chat.dart';

class ServiceProviderDashboard extends StatefulWidget {
  const ServiceProviderDashboard({super.key});

  @override
  State<ServiceProviderDashboard> createState() =>
      _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends State<ServiceProviderDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? currentProviderId;
  String selectedStatus = 'All';

  final List<String> statusFilters = [
    'All',
    'Pending',
    'Confirmed',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getCurrentProviderId();
    _listenForNewBookings();
  }

  void _listenForNewBookings() {
    // Listen for new pending bookings and show notifications
    if (currentProviderId != null) {
      FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: currentProviderId)
          .where('status', isEqualTo: 'Pending')
          .snapshots()
          .listen((snapshot) {
            if (mounted && snapshot.docs.isNotEmpty) {
              // Show notification for new bookings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'You have ${snapshot.docs.length} pending booking(s)',
                  ),
                  backgroundColor: Colors.orange,
                  action: SnackBarAction(
                    label: 'View',
                    textColor: Colors.white,
                    onPressed: () {
                      _tabController.animateTo(1); // Switch to bookings tab
                    },
                  ),
                ),
              );
            }
          });
    }
  }

  Future<void> _getCurrentProviderId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        print(
          'Looking for provider with email: ${currentUser.email}',
        ); // Debug log

        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('service_providers')
                .where('email', isEqualTo: currentUser.email)
                .limit(1)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          final providerId = querySnapshot.docs.first.id;

          setState(() {
            currentProviderId = providerId;
          });
        } else {
          // Create a default provider for testing
          try {
            final docRef = await FirebaseFirestore.instance
                .collection('service_providers')
                .add({
                  'businessName': 'Test Service Provider',
                  'ownerName': 'Test Owner',
                  'email': currentUser.email,
                  'phone': '123-456-7890',
                  'address': 'Test Address',
                  'isVerified': true,
                  'createdAt': FieldValue.serverTimestamp(),
                });

            setState(() {
              currentProviderId = docRef.id;
            });
          } catch (e) {
            // Handle error silently or show user-friendly message
          }
        }
      } catch (e) {
        // Handle error silently or show user-friendly message
      }
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> updateBookingStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(docId).update(
        {'status': newStatus, 'updatedAt': FieldValue.serverTimestamp()},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating booking: $e')));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Provider Dashboard'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(text: 'Services', icon: Icon(Icons.build)),
                Tab(text: 'Bookings', icon: Icon(Icons.calendar_today)),
                Tab(text: 'Messages', icon: Icon(Icons.chat)),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildServicesTab(),
                _buildBookingsTab(),
                _buildMessagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return Column(
      children: [
        // Add Service Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showAddServiceDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
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
                FirebaseFirestore.instance
                    .collection('services')
                    .where('isActive', isEqualTo: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('Error loading services'),
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
                      Icon(Icons.build, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No services found'),
                      SizedBox(height: 8),
                      Text('Add services to get started'),
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
    final theme = Theme.of(context);

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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            Container(
              width: double.infinity,
              height: 180,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(
                    getServiceImage(data['name'] ?? '', data['category'] ?? ''),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.build, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['name'] ?? 'Unknown Service',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                        data['isActive'] == true ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['isActive'] == true ? 'Active' : 'Inactive',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data['description'] ?? 'No description',
              style: TextStyle(color: Colors.grey[600]),
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
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

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      currentProviderId != null) {
                    final serviceData = {
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'duration': durationController.text,
                      'category':
                          categoryController.text.isEmpty
                              ? 'General'
                              : categoryController.text,
                      'isActive': true,
                      'providerId': currentProviderId,
                      'createdAt': FieldValue.serverTimestamp(),
                      'createdBy': 'provider',
                    };

                    try {
                      await FirebaseFirestore.instance
                          .collection('services')
                          .add(serviceData);

                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Service "${nameController.text}" added successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error adding service: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please fill in service name and ensure you are logged in',
                        ),
                        backgroundColor: Colors.orange,
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

  Widget _buildBookingsTab() {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Filter by Status: ',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: selectedStatus,
                  isExpanded: true,
                  items:
                      statusFilters.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedStatus = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // Bookings List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                currentProviderId != null
                    ? (selectedStatus == 'All'
                        ? FirebaseFirestore.instance
                            .collection('bookings')
                            .where('providerId', isEqualTo: currentProviderId)
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('bookings')
                            .where('providerId', isEqualTo: currentProviderId)
                            .where('status', isEqualTo: selectedStatus)
                            .snapshots())
                    : const Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bookings found',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return buildBookingCard(snapshot.data!.docs[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          currentProviderId != null
              ? FirebaseFirestore.instance
                  .collection('chats')
                  .where('providerId', isEqualTo: currentProviderId)
                  .snapshots()
              : const Stream.empty(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Error loading messages'),
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
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No messages yet'),
                SizedBox(height: 8),
                Text('Messages with customers will appear here'),
              ],
            ),
          );
        }

        final chats = snapshot.data!.docs;

        // Sort manually by lastMessageTime (most recent first)
        chats.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['lastMessageTime'] as Timestamp?;
          final bTime = bData['lastMessageTime'] as Timestamp?;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime); // Descending order
        });

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chatData = chats[index].data() as Map<String, dynamic>;
            return _buildChatTile(chatData);
          },
        );
      },
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chatData) {
    final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;
    final timeString =
        lastMessageTime != null ? _formatTime(lastMessageTime.toDate()) : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            (chatData['customerName'] ?? 'C')[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          chatData['customerName'] ?? 'Customer',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          chatData['lastMessage'] ?? 'No messages yet',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeString,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProviderChatScreen(
                    bookingId: chatData['bookingId'] ?? '',
                    customerId: chatData['customerId'] ?? '',
                    customerName: chatData['customerName'] ?? 'Customer',
                  ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget buildBookingCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['service'] ?? 'Unknown Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(data['status'] ?? 'pending'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['status'] ?? 'Pending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Info
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Customer: ${data['customerName'] ?? 'Anonymous'}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Contact Info
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Phone: ${data['customerPhone'] ?? 'Not provided'}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Vehicle Info
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Vehicle: ${data['vehicleModel'] ?? 'Not specified'}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Service Details
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${data['duration'] ?? 'N/A'}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Price: \$${data['price']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date and Time
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Date: ${data['date'] ?? 'N/A'}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Time: ${data['time'] ?? 'N/A'}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            if (data['status'] == 'Pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => updateBookingStatus(doc.id, 'Confirmed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => updateBookingStatus(doc.id, 'Cancelled'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),

            if (data['status'] == 'Confirmed')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => updateBookingStatus(doc.id, 'In Progress'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Start Service'),
                    ),
                  ),
                ],
              ),

            if (data['status'] == 'In Progress')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => updateBookingStatus(doc.id, 'Completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Mark Complete'),
                    ),
                  ),
                ],
              ),

            // Chat Button - Always visible
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProviderChatScreen(
                                bookingId: doc.id,
                                customerId: data['customerUid'] ?? '',
                                customerName:
                                    data['customerName'] ?? 'Customer',
                              ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat with Customer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

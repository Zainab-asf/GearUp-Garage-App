import 'package:flutter/material.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeSlot = '';
  String _selectedService = '';

  final List<String> _services = [
    'Oil Change',
    'Brake Service',
    'Engine Checkup',
    'AC Service',
    'Tire Replacement',
    'Car Wash',
    'Full Service',
    'Battery Check',
  ];

  final List<String> _timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  final List<Map<String, dynamic>> _myBookings = [
    {
      'id': '1',
      'service': 'Oil Change',
      'garage': 'GearUp Auto Service',
      'date': '2024-01-15',
      'time': '10:00 AM',
      'status': 'Confirmed',
      'price': '3,500',
      'address': 'Main Boulevard, Kohinoor City',
      'phone': '+92 300 1234567',
    },
    {
      'id': '2',
      'service': 'Brake Service',
      'garage': 'Quick Fix Motors',
      'date': '2024-01-18',
      'time': '2:00 PM',
      'status': 'Pending',
      'price': '8,500',
      'address': 'Jaranwala Road, Near University',
      'phone': '+92 300 2345678',
    },
    {
      'id': '3',
      'service': 'Car Wash',
      'garage': 'Elite Car Care',
      'date': '2024-01-12',
      'time': '11:00 AM',
      'status': 'Completed',
      'price': '1,200',
      'address': 'Canal Road, DHA Phase 1',
      'phone': '+92 300 3456789',
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Book New', icon: Icon(Icons.add_circle_outline)),
            Tab(text: 'My Bookings', icon: Icon(Icons.list_alt)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBookNewTab(), _buildMyBookingsTab()],
      ),
    );
  }

  Widget _buildBookNewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Selection
          const Text(
            'Select Service',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.inputBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedService.isEmpty ? null : _selectedService,
              decoration: const InputDecoration(
                hintText: 'Choose a service',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items:
                  _services.map((service) {
                    return DropdownMenuItem(
                      value: service,
                      child: Text(service),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedService = value!;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Date Selection
          const Text(
            'Select Date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border.all(color: AppTheme.inputBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: AppTheme.primary,
              ),
              title: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
          ),

          const SizedBox(height: 24),

          // Time Slot Selection
          const Text(
            'Select Time Slot',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final timeSlot = _timeSlots[index];
              final isSelected = _selectedTimeSlot == timeSlot;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeSlot = timeSlot;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.surface,
                    border: Border.all(
                      color:
                          isSelected ? AppTheme.primary : AppTheme.inputBorder,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      timeSlot,
                      style: TextStyle(
                        color:
                            isSelected
                                ? AppTheme.buttonText
                                : AppTheme.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Book Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canBook() ? _bookService : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Book Service',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.buttonText,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You will receive a confirmation call within 30 minutes of booking.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBookingsTab() {
    if (_myBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Book your first service to see it here',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myBookings.length,
      itemBuilder: (context, index) {
        final booking = _myBookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    Color statusColor;
    IconData statusIcon;

    switch (booking['status']) {
      case 'Confirmed':
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle;
        break;
      case 'Pending':
        statusColor = AppTheme.primary;
        statusIcon = Icons.schedule;
        break;
      case 'Completed':
        statusColor = AppTheme.secondary;
        statusIcon = Icons.done_all;
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.surface,
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
                    booking['service'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: AppTheme.buttonText),
                      const SizedBox(width: 4),
                      Text(
                        booking['status'],
                        style: const TextStyle(
                          color: AppTheme.buttonText,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              booking['garage'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.secondary,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  booking['date'],
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  booking['time'],
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking['address'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rs. ${booking['price']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                Row(
                  children: [
                    if (booking['status'] == 'Confirmed' ||
                        booking['status'] == 'Pending') ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ${booking['garage']}'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text(
                          'Call',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.success,
                          side: const BorderSide(color: AppTheme.success),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (booking['status'] == 'Pending')
                      OutlinedButton.icon(
                        onPressed: () {
                          _showCancelDialog(booking);
                        },
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                    if (booking['status'] == 'Completed')
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Review feature coming soon!'),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.star,
                          size: 16,
                          color: AppTheme.buttonText,
                        ),
                        label: const Text(
                          'Review',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.buttonText,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canBook() {
    return _selectedService.isNotEmpty && _selectedTimeSlot.isNotEmpty;
  }

  void _bookService() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Booking'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Service: $_selectedService'),
                Text(
                  'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                Text('Time: $_selectedTimeSlot'),
                const SizedBox(height: 16),
                const Text(
                  'You will receive a confirmation call within 30 minutes.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Booking confirmed! You will receive a call soon.',
                      ),
                    ),
                  );
                  // Reset form
                  setState(() {
                    _selectedService = '';
                    _selectedTimeSlot = '';
                    _selectedDate = DateTime.now();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.buttonText,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Booking'),
            content: Text(
              'Are you sure you want to cancel your ${booking['service']} booking?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking cancelled successfully'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: AppTheme.textPrimary,
                ),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
    );
  }
}

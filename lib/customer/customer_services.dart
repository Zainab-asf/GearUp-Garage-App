import 'package:flutter/material.dart';
import '../theme.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  String _selectedCity = 'Faisalabad';
  String _selectedServiceType = 'All Services';

  final List<String> _cities = [
    'Faisalabad',
    'Lahore',
    'Karachi',
    'Islamabad',
    'Rawalpindi',
    'Abbottabad',
  ];

  final List<String> _serviceTypes = [
    'All Services',
    'Full Service Garage',
    'Quick Service',
    'Premium Service',
    'Emergency Service',
  ];

  // Sample garage/service locations
  final List<Map<String, dynamic>> _serviceLocations = [
    {
      'id': 'garage1',
      'name': 'GearUp Auto Service',
      'type': 'Full Service Garage',
      'city': 'Faisalabad',
      'address': 'Main Boulevard, Kohinoor City',
      'distance': '2.5 km',
      'rating': 4.5,
      'services': ['Oil Change', 'Brake Repair', 'Engine Service'],
      'phone': '+92 300 1234567',
    },
    {
      'id': 'garage2',
      'name': 'Quick Fix Motors',
      'type': 'Quick Service',
      'city': 'Faisalabad',
      'address': 'Jaranwala Road, Near University',
      'distance': '3.2 km',
      'rating': 4.2,
      'services': ['Tire Change', 'Battery Service', 'AC Repair'],
      'phone': '+92 300 2345678',
    },
    {
      'id': 'garage3',
      'name': 'Elite Car Care',
      'type': 'Premium Service',
      'city': 'Faisalabad',
      'address': 'Canal Road, DHA Phase 1',
      'distance': '4.1 km',
      'rating': 4.8,
      'services': ['Full Detailing', 'Paint Work', 'Interior Cleaning'],
      'phone': '+92 300 3456789',
    },
    {
      'id': 'garage4',
      'name': 'Roadside Assistance',
      'type': 'Emergency Service',
      'city': 'Faisalabad',
      'address': '24/7 Mobile Service',
      'distance': '1.8 km',
      'rating': 4.0,
      'services': ['Towing', 'Jump Start', 'Flat Tire'],
      'phone': '+92 300 4567890',
    },
    {
      'id': 'garage5',
      'name': 'Metro Auto Workshop',
      'type': 'Full Service Garage',
      'city': 'Lahore',
      'address': 'MM Alam Road, Gulberg',
      'distance': '5.2 km',
      'rating': 4.3,
      'services': ['Engine Repair', 'Transmission', 'Electrical'],
      'phone': '+92 300 5678901',
    },
    {
      'id': 'garage6',
      'name': 'Speed Auto Care',
      'type': 'Quick Service',
      'city': 'Lahore',
      'address': 'Liberty Market, Main Boulevard',
      'distance': '3.8 km',
      'rating': 4.1,
      'services': ['Oil Change', 'Tire Service', 'Battery Check'],
      'phone': '+92 300 6789012',
    },
    {
      'id': 'garage7',
      'name': 'Premium Car Detailing',
      'type': 'Premium Service',
      'city': 'Lahore',
      'address': 'DHA Phase 5, Y Block',
      'distance': '6.5 km',
      'rating': 4.7,
      'services': ['Car Wash', 'Interior Detailing', 'Paint Protection'],
      'phone': '+92 300 7890123',
    },
    // Karachi Services
    {
      'id': 'garage8',
      'name': 'Karachi Auto Hub',
      'type': 'Full Service Garage',
      'city': 'Karachi',
      'address': 'Clifton Block 2, Main Khayaban',
      'distance': '4.2 km',
      'rating': 4.4,
      'services': ['Engine Service', 'AC Repair', 'Brake Service'],
      'phone': '+92 300 8901234',
    },
    {
      'id': 'garage9',
      'name': 'Quick Fix Karachi',
      'type': 'Quick Service',
      'city': 'Karachi',
      'address': 'Gulshan-e-Iqbal, Block 13',
      'distance': '2.9 km',
      'rating': 4.0,
      'services': ['Tire Change', 'Oil Service', 'Battery Replacement'],
      'phone': '+92 300 9012345',
    },
    {
      'id': 'garage10',
      'name': 'Coastal Emergency Service',
      'type': 'Emergency Service',
      'city': 'Karachi',
      'address': '24/7 Mobile Service - All Areas',
      'distance': '1.5 km',
      'rating': 4.2,
      'services': ['Towing', 'Jump Start', 'Emergency Repair'],
      'phone': '+92 300 0123456',
    },
    // Islamabad Services
    {
      'id': 'garage11',
      'name': 'Capital Auto Service',
      'type': 'Full Service Garage',
      'city': 'Islamabad',
      'address': 'F-7 Markaz, Jinnah Avenue',
      'distance': '3.1 km',
      'rating': 4.6,
      'services': ['Complete Service', 'Engine Overhaul', 'Transmission'],
      'phone': '+92 300 1234567',
    },
    {
      'id': 'garage12',
      'name': 'Blue Area Motors',
      'type': 'Premium Service',
      'city': 'Islamabad',
      'address': 'Blue Area, Fazal Haq Road',
      'distance': '2.7 km',
      'rating': 4.8,
      'services': ['Luxury Car Service', 'Paint Work', 'Interior Care'],
      'phone': '+92 300 2345678',
    },
    {
      'id': 'garage13',
      'name': 'Express Auto Fix',
      'type': 'Quick Service',
      'city': 'Islamabad',
      'address': 'G-9 Markaz, Kashmir Highway',
      'distance': '4.3 km',
      'rating': 4.1,
      'services': ['Quick Oil Change', 'Tire Service', 'AC Service'],
      'phone': '+92 300 3456789',
    },
    // Rawalpindi Services
    {
      'id': 'garage14',
      'name': 'Pindi Auto Works',
      'type': 'Full Service Garage',
      'city': 'Rawalpindi',
      'address': 'Saddar Bazaar, Committee Chowk',
      'distance': '2.8 km',
      'rating': 4.3,
      'services': ['Engine Repair', 'Body Work', 'Electrical'],
      'phone': '+92 300 4567890',
    },
    {
      'id': 'garage15',
      'name': 'Cantonment Car Care',
      'type': 'Premium Service',
      'city': 'Rawalpindi',
      'address': 'Mall Road, Cantonment',
      'distance': '3.5 km',
      'rating': 4.5,
      'services': ['Premium Wash', 'Detailing', 'Paint Protection'],
      'phone': '+92 300 5678901',
    },
    {
      'id': 'garage16',
      'name': 'Rapid Response Service',
      'type': 'Emergency Service',
      'city': 'Rawalpindi',
      'address': '24/7 Mobile Service',
      'distance': '1.2 km',
      'rating': 4.0,
      'services': ['Emergency Towing', 'Roadside Assistance', 'Jump Start'],
      'phone': '+92 300 6789012',
    },
    // Abbottabad Services
    {
      'id': 'garage17',
      'name': 'Mountain Auto Service',
      'type': 'Full Service Garage',
      'city': 'Abbottabad',
      'address': 'Mansehra Road, Near Ayub Park',
      'distance': '2.1 km',
      'rating': 4.4,
      'services': ['Engine Service', 'Brake Repair', 'AC Service'],
      'phone': '+92 300 7890123',
    },
    {
      'id': 'garage18',
      'name': 'Hill Station Motors',
      'type': 'Quick Service',
      'city': 'Abbottabad',
      'address': 'Supply Bazaar, Main GT Road',
      'distance': '1.8 km',
      'rating': 4.2,
      'services': ['Oil Change', 'Tire Service', 'Battery Check'],
      'phone': '+92 300 8901234',
    },
    {
      'id': 'garage19',
      'name': 'Alpine Car Care',
      'type': 'Premium Service',
      'city': 'Abbottabad',
      'address': 'Jinnahabad, Main Circular Road',
      'distance': '3.2 km',
      'rating': 4.6,
      'services': ['Car Detailing', 'Interior Cleaning', 'Wax Service'],
      'phone': '+92 300 9012345',
    },
    {
      'id': 'garage20',
      'name': 'Valley Emergency Service',
      'type': 'Emergency Service',
      'city': 'Abbottabad',
      'address': '24/7 Mobile Service - All Areas',
      'distance': '0.9 km',
      'rating': 4.1,
      'services': ['Emergency Repair', 'Towing', 'Roadside Help'],
      'phone': '+92 300 0123456',
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    return _serviceLocations.where((service) {
      bool cityMatch = service['city'] == _selectedCity;
      bool typeMatch =
          _selectedServiceType == 'All Services' ||
          service['type'] == _selectedServiceType;
      return cityMatch && typeMatch;
    }).toList();
  }

  void _showServiceDetails(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Service name and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.buttonPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${service['rating']}⭐',
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
                    service['type'],
                    style: TextStyle(fontSize: 16, color: AppTheme.primary),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          service['address'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Services offered
                  const Text(
                    'Services Offered:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        (service['services'] as List<String>).map((
                          serviceItem,
                        ) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF2196F3,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2196F3),
                              ),
                            ),
                            child: Text(
                              serviceItem,
                              style: const TextStyle(
                                color: Color(0xFF2196F3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Contact and action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling ${service['phone']}'),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.phone,
                            color: AppTheme.buttonPrimary,
                          ),
                          label: const Text(
                            'Call',
                            style: TextStyle(color: AppTheme.textPrimary),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
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
                              const SnackBar(
                                content: Text('Booking feature coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.calendar_today,
                            color: AppTheme.buttonPrimary,
                          ),
                          label: const Text(
                            'Book',
                            style: TextStyle(color: AppTheme.textPrimary),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
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
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nearby Services',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.inputFill,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'Select City',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            _cities.map((city) {
                              return DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedServiceType,
                        decoration: const InputDecoration(
                          labelText: 'Service Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            _serviceTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedServiceType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Services List
          Expanded(
            child:
                _filteredServices.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppTheme.inputFill,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No services found',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try selecting a different city or service type',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = _filteredServices[index];
                        return _buildServiceCard(service);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _showServiceDetails(service),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Image Placeholder
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.inputFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.inputFill),
                    ),
                    child: Icon(
                      Icons.build_circle,
                      size: 28,
                      color: AppTheme.buttonPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Service Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                service['name'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.buttonPrimary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${service['rating']}⭐',
                                style: const TextStyle(
                                  color: AppTheme.buttonText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          service['type'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 13,
                              color: AppTheme.secondary,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                service['address'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.directions,
                              size: 13,
                              color: AppTheme.secondary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              service['distance'],
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Services offered
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children:
                    (service['services'] as List<String>).take(3).map((
                      serviceItem,
                    ) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.inputFill,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.inputFill),
                        ),
                        child: Text(
                          serviceItem,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 8),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling ${service['phone']}'),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.phone,
                        size: 14,
                        color: AppTheme.buttonPrimary,
                      ),
                      label: const Text(
                        'Call',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.buttonPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.buttonPrimary,
                        side: BorderSide(color: AppTheme.buttonPrimary),
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showServiceDetails(service),
                      icon: Icon(
                        Icons.info,
                        size: 14,
                        color: AppTheme.buttonText,
                      ),
                      label: const Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.buttonText,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.buttonPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 7),
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
      ),
    );
  }
}

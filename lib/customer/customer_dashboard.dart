import 'package:flutter/material.dart';
import '../theme.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image section
            (imageUrl.startsWith('http') || imageUrl.startsWith('https'))
                ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 250,
                        color: AppTheme.inputFill,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: AppTheme.primary,
                        ),
                      ),
                )
                : Image.asset(
                  imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 250,
                        color: AppTheme.inputFill,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: AppTheme.primary,
                        ),
                      ),
                ),

            // Content section
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppTheme.textPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.textPrimary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    'Price: $price',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF74B9FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Text(
                    'Location: $location',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textPrimary.withOpacity(0.8),
                    ),
                  ),

                  SizedBox(height: 16),
                  Divider(),

                  // Features
                  Text(
                    "Features",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Engine: 2000cc Electric Motor\n"
                    "• Battery: Lithium-ion\n"
                    "• Top Speed: 180 km/h\n"
                    "• Range: 350 km\n"
                    "• Transmission: Automatic",
                    style: TextStyle(fontSize: 16),
                  ),

                  SizedBox(height: 16),
                  Divider(),

                  // Registration details
                  Text(
                    "Registration Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Registered: Yes\n"
                    "• Year: 2025\n"
                    "• City: Karachi\n"
                    "• Token Paid: Yes",
                    style: TextStyle(fontSize: 16),
                  ),

                  SizedBox(height: 16),
                  Divider(),

                  // Seller Comments
                  Text(
                    "Seller Comments",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "This is a brand new $title with excellent performance, great battery timing, "
                    "and modern features. Price is slightly negotiable.",
                    style: TextStyle(fontSize: 16),
                  ),

                  SizedBox(height: 24),

                  // Add to Cart Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added to cart')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.buttonPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        Icons.shopping_cart,
                        color: AppTheme.buttonPrimary,
                      ),
                      label: Text(
                        "Add to Cart",
                        style: TextStyle(color: AppTheme.primary),
                      ),
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

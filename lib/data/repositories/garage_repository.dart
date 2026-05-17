import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GarageRepository {
  GarageRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get services =>
      _firestore.collection('services');
  CollectionReference<Map<String, dynamic>> get parts =>
      _firestore.collection('parts');
  CollectionReference<Map<String, dynamic>> get vehicleListings =>
      _firestore.collection('vehicle_listings');
  CollectionReference<Map<String, dynamic>> get offers =>
      _firestore.collection('offers');
  CollectionReference<Map<String, dynamic>> get carts =>
      _firestore.collection('carts');
  CollectionReference<Map<String, dynamic>> get offerClaims =>
      _firestore.collection('offer_claims');
  CollectionReference<Map<String, dynamic>> get bookings =>
      _firestore.collection('bookings');

  User? get currentUser => _auth.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>> activeServices() {
    return services.where('isActive', isEqualTo: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> activeParts() {
    return parts.where('isActive', isEqualTo: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> activeVehicleListings() {
    return vehicleListings.where('isActive', isEqualTo: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> activeOffers() {
    return offers.where('isActive', isEqualTo: true).snapshots();
  }

  Future<void> addToCart({
    required String itemId,
    required String itemType,
    required Map<String, dynamic> item,
  }) async {
    final user = currentUser;
    await carts.add({
      'userId': user?.uid,
      'userEmail': user?.email,
      'itemId': itemId,
      'itemType': itemType,
      'item': item,
      'quantity': 1,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> claimOffer({
    required String offerId,
    required Map<String, dynamic> offer,
  }) async {
    final user = currentUser;
    final couponCode =
        'AUTO${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    await offerClaims.add({
      'offerId': offerId,
      'offerTitle': offer['title'] ?? 'Offer',
      'couponCode': couponCode,
      'userId': user?.uid,
      'userEmail': user?.email,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return couponCode;
  }

  Future<void> createVehicleListing(Map<String, dynamic> listing) async {
    final user = currentUser;
    await vehicleListings.add({
      ...listing,
      'sellerId': user?.uid,
      'sellerEmail': user?.email,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

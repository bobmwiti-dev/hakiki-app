import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/product_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/vendor_model.dart';
import '../../data/models/report_model.dart';
import '../../data/models/fraud_report_model.dart';
import '../utils/logger.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _usersCollection = 'users';
  static const String _productsCollection = 'products';
  static const String _vendorsCollection = 'vendors';
  static const String _reportsCollection = 'reports';
  static const String _fraudReportsCollection = 'fraud_reports';

  // User operations
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get user: $e');
      return null;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toJson());
      Logger.info('User created successfully: ${user.id}');
    } catch (e) {
      Logger.error('Failed to create user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update(data);
      Logger.info('User updated successfully: $userId');
    } catch (e) {
      Logger.error('Failed to update user: $e');
      rethrow;
    }
  }

  // Product operations
  Future<ProductModel?> getProduct(String productId) async {
    try {
      final doc =
          await _firestore.collection(_productsCollection).doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get product: $e');
      return null;
    }
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final query =
          await _firestore
              .collection(_productsCollection)
              .where('barcode', isEqualTo: barcode)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        return ProductModel.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get product by barcode: $e');
      return null;
    }
  }

  Future<ProductModel?> getProductByQRCode(String qrCode) async {
    try {
      final query =
          await _firestore
              .collection(_productsCollection)
              .where('qrCode', isEqualTo: qrCode)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        return ProductModel.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get product by QR code: $e');
      return null;
    }
  }

  Future<List<ProductModel>> getProducts({int limit = 20}) async {
    try {
      final query =
          await _firestore.collection(_productsCollection).limit(limit).get();

      return query.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      Logger.error('Failed to get products: $e');
      return [];
    }
  }

  Future<void> createProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(product.id)
          .set(product.toJson());
      Logger.info('Product created successfully: ${product.id}');
    } catch (e) {
      Logger.error('Failed to create product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .update(data);
      Logger.info('Product updated successfully: $productId');
    } catch (e) {
      Logger.error('Failed to update product: $e');
      rethrow;
    }
  }

  // Vendor operations
  Future<VendorModel?> getVendor(String vendorId) async {
    try {
      final doc =
          await _firestore.collection(_vendorsCollection).doc(vendorId).get();
      if (doc.exists) {
        return VendorModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get vendor: $e');
      return null;
    }
  }

  Future<List<VendorModel>> getVendors({int limit = 20}) async {
    try {
      final query =
          await _firestore.collection(_vendorsCollection).limit(limit).get();

      return query.docs.map((doc) => VendorModel.fromJson(doc.data())).toList();
    } catch (e) {
      Logger.error('Failed to get vendors: $e');
      return [];
    }
  }

  Future<VendorModel?> getVendorByUserId(String userId) async {
    try {
      final query =
          await _firestore
              .collection(_vendorsCollection)
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        return VendorModel.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get vendor by user ID: $e');
      return null;
    }
  }

  Future<List<VendorModel>> getPendingVendors() async {
    try {
      final query =
          await _firestore
              .collection(_vendorsCollection)
              .where('status', isEqualTo: 'pending')
              .get();

      return query.docs.map((doc) => VendorModel.fromJson(doc.data())).toList();
    } catch (e) {
      Logger.error('Failed to get pending vendors: $e');
      return [];
    }
  }

  Future<void> createVendor(VendorModel vendor) async {
    try {
      await _firestore
          .collection(_vendorsCollection)
          .doc(vendor.id)
          .set(vendor.toJson());
      Logger.info('Vendor created successfully: ${vendor.id}');
    } catch (e) {
      Logger.error('Failed to create vendor: $e');
      rethrow;
    }
  }

  Future<void> updateVendor(String vendorId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(_vendorsCollection)
          .doc(vendorId)
          .update(data);
      Logger.info('Vendor updated successfully: $vendorId');
    } catch (e) {
      Logger.error('Failed to update vendor: $e');
      rethrow;
    }
  }

  Future<List<VendorModel>> getVendorsByStatus(
    String status, {
    int? limit,
  }) async {
    try {
      Logger.debug(
        'Getting vendors by status: $status',
        tag: 'FirestoreService',
      );

      Query query = _firestore
          .collection(_vendorsCollection)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      final vendors =
          snapshot.docs
              .map(
                (doc) =>
                    VendorModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

      Logger.debug(
        'Found ${vendors.length} vendors with status: $status',
        tag: 'FirestoreService',
      );
      return vendors;
    } catch (e) {
      Logger.error(
        'Failed to get vendors by status: $e',
        tag: 'FirestoreService',
      );
      return [];
    }
  }

  Future<List<VendorModel>> searchVendors(String query, {int? limit}) async {
    try {
      Logger.debug(
        'Searching vendors with query: $query',
        tag: 'FirestoreService',
      );

      // For Firestore text search, we'll search by business name
      // Note: Firestore doesn't have full-text search, this is a basic implementation
      final snapshot =
          await _firestore
              .collection(_vendorsCollection)
              .where('businessName', isGreaterThanOrEqualTo: query)
              .where('businessName', isLessThan: '$query\uf8ff')
              .limit(limit ?? 20)
              .get();

      final vendors =
          snapshot.docs.map((doc) => VendorModel.fromJson(doc.data())).toList();

      Logger.debug(
        'Found ${vendors.length} vendors matching query: $query',
        tag: 'FirestoreService',
      );
      return vendors;
    } catch (e) {
      Logger.error('Failed to search vendors: $e', tag: 'FirestoreService');
      return [];
    }
  }

  Future<List<UserModel>> getAllUsers({int? limit}) async {
    try {
      Logger.debug('Getting all users', tag: 'FirestoreService');

      Query query = _firestore
          .collection(_usersCollection)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      final users =
          snapshot.docs
              .map(
                (doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

      Logger.debug('Retrieved ${users.length} users', tag: 'FirestoreService');
      return users;
    } catch (e) {
      Logger.error('Failed to get all users: $e', tag: 'FirestoreService');
      return [];
    }
  }

  // Report operations
  Future<void> createReport(ReportModel report) async {
    try {
      await _firestore
          .collection(_reportsCollection)
          .doc(report.id)
          .set(report.toJson());
      Logger.info('Report created successfully: ${report.id}');
    } catch (e) {
      Logger.error('Failed to create report: $e');
      rethrow;
    }
  }

  Future<List<ReportModel>> getReports({int limit = 20}) async {
    try {
      final query =
          await _firestore.collection(_reportsCollection).limit(limit).get();

      return query.docs.map((doc) => ReportModel.fromJson(doc.data())).toList();
    } catch (e) {
      Logger.error('Failed to get reports: $e');
      return [];
    }
  }

  Stream<List<ReportModel>> getReportsByUser(String userId) {
    try {
      return _firestore
          .collection(_reportsCollection)
          .where('reporterId', isEqualTo: userId)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => ReportModel.fromJson(doc.data()))
                    .toList(),
          );
    } catch (e) {
      Logger.error('Failed to get reports by user: $e');
      return Stream.value([]);
    }
  }

  // Fraud report operations
  Future<void> createFraudReport(FraudReportModel fraudReport) async {
    try {
      await _firestore
          .collection(_fraudReportsCollection)
          .doc(fraudReport.id)
          .set(fraudReport.toJson());
      Logger.info('Fraud report created successfully: ${fraudReport.id}');
    } catch (e) {
      Logger.error('Failed to create fraud report: $e');
      rethrow;
    }
  }

  Future<List<FraudReportModel>> getFraudReports({int limit = 20}) async {
    try {
      final query =
          await _firestore
              .collection(_fraudReportsCollection)
              .limit(limit)
              .get();

      return query.docs
          .map((doc) => FraudReportModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      Logger.error('Failed to get fraud reports: $e');
      return [];
    }
  }

  // Generic operations
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
      Logger.info('Document deleted successfully: $collection/$documentId');
    } catch (e) {
      Logger.error('Failed to delete document: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  Stream<DocumentSnapshot> getDocumentStream(
    String collection,
    String documentId,
  ) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }
}

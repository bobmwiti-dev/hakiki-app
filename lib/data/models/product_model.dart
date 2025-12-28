import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final String category;
  final String brand;
  final String model;
  final String serialNumber;
  final String? barcode;
  final String? qrCode;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final Map<String, dynamic> specifications;
  final bool isVerified;
  final bool isActive;
  final int verificationCount;
  final int reportCount;
  final double averageRating;
  final int totalRatings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const ProductModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    required this.model,
    required this.serialNumber,
    this.barcode,
    this.qrCode,
    required this.price,
    required this.currency,
    required this.imageUrls,
    required this.specifications,
    required this.isVerified,
    required this.isActive,
    required this.verificationCount,
    required this.reportCount,
    required this.averageRating,
    required this.totalRatings,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = Timestamp.fromDate(createdAt);
    json['updatedAt'] = Timestamp.fromDate(updatedAt);
    return json;
  }

  ProductModel copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    String? category,
    String? brand,
    String? model,
    String? serialNumber,
    String? barcode,
    String? qrCode,
    double? price,
    String? currency,
    List<String>? imageUrls,
    Map<String, dynamic>? specifications,
    bool? isVerified,
    bool? isActive,
    int? verificationCount,
    int? reportCount,
    double? averageRating,
    int? totalRatings,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ProductModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      barcode: barcode ?? this.barcode,
      qrCode: qrCode ?? this.qrCode,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      imageUrls: imageUrls ?? this.imageUrls,
      specifications: specifications ?? this.specifications,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      verificationCount: verificationCount ?? this.verificationCount,
      reportCount: reportCount ?? this.reportCount,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  String get trustLevel {
    if (reportCount > verificationCount * 2) return 'Low';
    if (verificationCount > 10 && reportCount == 0) return 'High';
    if (verificationCount > 5) return 'Medium';
    return 'Unknown';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          vendorId == other.vendorId;

  @override
  int get hashCode => id.hashCode ^ vendorId.hashCode;

  @override
  String toString() {
    return 'ProductModel{id: $id, name: $name, brand: $brand, isVerified: $isVerified, trustLevel: $trustLevel}';
  }
}

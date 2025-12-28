// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String,
      vendorId: json['vendorId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      serialNumber: json['serialNumber'] as String,
      barcode: json['barcode'] as String?,
      qrCode: json['qrCode'] as String?,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      specifications: json['specifications'] as Map<String, dynamic>,
      isVerified: json['isVerified'] as bool,
      isActive: json['isActive'] as bool,
      verificationCount: (json['verificationCount'] as num).toInt(),
      reportCount: (json['reportCount'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
      totalRatings: (json['totalRatings'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vendorId': instance.vendorId,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'brand': instance.brand,
      'model': instance.model,
      'serialNumber': instance.serialNumber,
      'barcode': instance.barcode,
      'qrCode': instance.qrCode,
      'price': instance.price,
      'currency': instance.currency,
      'imageUrls': instance.imageUrls,
      'specifications': instance.specifications,
      'isVerified': instance.isVerified,
      'isActive': instance.isActive,
      'verificationCount': instance.verificationCount,
      'reportCount': instance.reportCount,
      'averageRating': instance.averageRating,
      'totalRatings': instance.totalRatings,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

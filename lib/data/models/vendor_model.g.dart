// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorModel _$VendorModelFromJson(Map<String, dynamic> json) => VendorModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      businessName: json['businessName'] as String,
      businessType: json['businessType'] as String,
      businessDescription: json['businessDescription'] as String?,
      businessAddress: json['businessAddress'] as String,
      businessPhone: json['businessPhone'] as String?,
      businessEmail: json['businessEmail'] as String?,
      businessWebsite: json['businessWebsite'] as String?,
      registrationNumber: json['registrationNumber'] as String,
      taxId: json['taxId'] as String,
      documentUrls: (json['documentUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      verificationStatus: json['verificationStatus'] as String,
      rejectionReason: json['rejectionReason'] as String?,
      trustScore: (json['trustScore'] as num).toInt(),
      totalProducts: (json['totalProducts'] as num).toInt(),
      totalReports: (json['totalReports'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      approvedBy: json['approvedBy'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$VendorModelToJson(VendorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'businessName': instance.businessName,
      'businessType': instance.businessType,
      'businessDescription': instance.businessDescription,
      'businessAddress': instance.businessAddress,
      'businessPhone': instance.businessPhone,
      'businessEmail': instance.businessEmail,
      'businessWebsite': instance.businessWebsite,
      'registrationNumber': instance.registrationNumber,
      'taxId': instance.taxId,
      'documentUrls': instance.documentUrls,
      'verificationStatus': instance.verificationStatus,
      'rejectionReason': instance.rejectionReason,
      'trustScore': instance.trustScore,
      'totalProducts': instance.totalProducts,
      'totalReports': instance.totalReports,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'approvedBy': instance.approvedBy,
      'metadata': instance.metadata,
    };

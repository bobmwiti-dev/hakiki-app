// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fraud_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FraudReportModel _$FraudReportModelFromJson(Map<String, dynamic> json) =>
    FraudReportModel(
      id: json['id'] as String,
      reporterId: json['reporterId'] as String,
      productId: json['productId'] as String?,
      vendorId: json['vendorId'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      mediaUrls:
          (json['mediaUrls'] as List<dynamic>).map((e) => e as String).toList(),
      status: json['status'] as String,
      resolution: json['resolution'] as String?,
      assignedTo: json['assignedTo'] as String?,
      severity: (json['severity'] as num).toInt(),
      isAnonymous: json['isAnonymous'] as bool,
      evidence: json['evidence'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FraudReportModelToJson(FraudReportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reporterId': instance.reporterId,
      'productId': instance.productId,
      'vendorId': instance.vendorId,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'mediaUrls': instance.mediaUrls,
      'status': instance.status,
      'resolution': instance.resolution,
      'assignedTo': instance.assignedTo,
      'severity': instance.severity,
      'isAnonymous': instance.isAnonymous,
      'evidence': instance.evidence,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

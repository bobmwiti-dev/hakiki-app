import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vendor_model.g.dart';

@JsonSerializable()
class VendorModel {
  final String id;
  final String userId;
  final String businessName;
  final String businessType;
  final String? businessDescription;
  final String businessAddress;
  final String? businessPhone;
  final String? businessEmail;
  final String? businessWebsite;
  final String registrationNumber;
  final String taxId;
  final List<String> documentUrls;
  final String verificationStatus; // pending, approved, rejected, suspended
  final String? rejectionReason;
  final int trustScore;
  final int totalProducts;
  final int totalReports;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final Map<String, dynamic>? metadata;

  const VendorModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessType,
    this.businessDescription,
    required this.businessAddress,
    this.businessPhone,
    this.businessEmail,
    this.businessWebsite,
    required this.registrationNumber,
    required this.taxId,
    required this.documentUrls,
    required this.verificationStatus,
    this.rejectionReason,
    required this.trustScore,
    required this.totalProducts,
    required this.totalReports,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.approvedBy,
    this.metadata,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) => _$VendorModelFromJson(json);
  Map<String, dynamic> toJson() => _$VendorModelToJson(this);

  factory VendorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VendorModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
      'approvedAt': data['approvedAt'] != null 
          ? (data['approvedAt'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = Timestamp.fromDate(createdAt);
    json['updatedAt'] = Timestamp.fromDate(updatedAt);
    if (approvedAt != null) {
      json['approvedAt'] = Timestamp.fromDate(approvedAt!);
    }
    return json;
  }

  VendorModel copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? businessType,
    String? businessDescription,
    String? businessAddress,
    String? businessPhone,
    String? businessEmail,
    String? businessWebsite,
    String? registrationNumber,
    String? taxId,
    List<String>? documentUrls,
    String? verificationStatus,
    String? rejectionReason,
    int? trustScore,
    int? totalProducts,
    int? totalReports,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    String? approvedBy,
    Map<String, dynamic>? metadata,
  }) {
    return VendorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      businessDescription: businessDescription ?? this.businessDescription,
      businessAddress: businessAddress ?? this.businessAddress,
      businessPhone: businessPhone ?? this.businessPhone,
      businessEmail: businessEmail ?? this.businessEmail,
      businessWebsite: businessWebsite ?? this.businessWebsite,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      taxId: taxId ?? this.taxId,
      documentUrls: documentUrls ?? this.documentUrls,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      trustScore: trustScore ?? this.trustScore,
      totalProducts: totalProducts ?? this.totalProducts,
      totalReports: totalReports ?? this.totalReports,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isApproved => verificationStatus == 'approved';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';
  bool get isSuspended => verificationStatus == 'suspended';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VendorModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;

  @override
  String toString() {
    return 'VendorModel{id: $id, businessName: $businessName, verificationStatus: $verificationStatus, trustScore: $trustScore}';
  }
}

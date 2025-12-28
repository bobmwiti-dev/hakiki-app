import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_model.g.dart';

@JsonSerializable()
class ReportModel {
  final String id;
  final String reporterId;
  final String? productId;
  final String? vendorId;
  final String type; // fraud, fake_product, scam, other
  final String title;
  final String description;
  final List<String> mediaUrls;
  final String status; // pending, investigating, resolved, dismissed
  final String? resolution;
  final String? assignedTo;
  final int severity; // 1-5 scale
  final bool isAnonymous;
  final Map<String, dynamic> evidence;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final Map<String, dynamic>? metadata;

  const ReportModel({
    required this.id,
    required this.reporterId,
    this.productId,
    this.vendorId,
    required this.type,
    required this.title,
    required this.description,
    required this.mediaUrls,
    required this.status,
    this.resolution,
    this.assignedTo,
    required this.severity,
    required this.isAnonymous,
    required this.evidence,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.metadata,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => _$ReportModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReportModelToJson(this);

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
      'resolvedAt': data['resolvedAt'] != null 
          ? (data['resolvedAt'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = Timestamp.fromDate(createdAt);
    json['updatedAt'] = Timestamp.fromDate(updatedAt);
    if (resolvedAt != null) {
      json['resolvedAt'] = Timestamp.fromDate(resolvedAt!);
    }
    return json;
  }

  ReportModel copyWith({
    String? id,
    String? reporterId,
    String? productId,
    String? vendorId,
    String? type,
    String? title,
    String? description,
    List<String>? mediaUrls,
    String? status,
    String? resolution,
    String? assignedTo,
    int? severity,
    bool? isAnonymous,
    Map<String, dynamic>? evidence,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      productId: productId ?? this.productId,
      vendorId: vendorId ?? this.vendorId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      status: status ?? this.status,
      resolution: resolution ?? this.resolution,
      assignedTo: assignedTo ?? this.assignedTo,
      severity: severity ?? this.severity,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      evidence: evidence ?? this.evidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isPending => status == 'pending';
  bool get isInvestigating => status == 'investigating';
  bool get isResolved => status == 'resolved';
  bool get isDismissed => status == 'dismissed';

  String get severityText {
    switch (severity) {
      case 1:
        return 'Low';
      case 2:
        return 'Minor';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          reporterId == other.reporterId;

  @override
  int get hashCode => id.hashCode ^ reporterId.hashCode;

  @override
  String toString() {
    return 'ReportModel{id: $id, type: $type, status: $status, severity: $severity}';
  }
}

class ProductVerificationModel {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String category;
  final String sku;
  final String priceRange;
  final String imageUrl;
  final VerificationStatus verificationStatus;
  final double confidenceScore;
  final List<VerificationHistoryModel> verificationHistory;
  final List<RiskIndicatorModel> riskIndicators;
  final List<SimilarReportModel> similarReports;
  final FraudPatternsModel fraudPatterns;

  ProductVerificationModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.category,
    required this.sku,
    required this.priceRange,
    required this.imageUrl,
    required this.verificationStatus,
    required this.confidenceScore,
    required this.verificationHistory,
    required this.riskIndicators,
    required this.similarReports,
    required this.fraudPatterns,
  });

  factory ProductVerificationModel.fromJson(Map<String, dynamic> json) {
    return ProductVerificationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      category: json['category'] ?? '',
      sku: json['sku'] ?? '',
      priceRange: json['priceRange'] ?? '',
      imageUrl: json['image'] ?? '',
      verificationStatus: VerificationStatus.fromString(json['verificationStatus'] ?? 'unknown'),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      verificationHistory: (json['verificationHistory'] as List<dynamic>?)
              ?.map((item) => VerificationHistoryModel.fromJson(item))
              .toList() ??
          [],
      riskIndicators: (json['riskIndicators'] as List<dynamic>?)
              ?.map((item) => RiskIndicatorModel.fromJson(item))
              .toList() ??
          [],
      similarReports: (json['similarReports'] as List<dynamic>?)
              ?.map((item) => SimilarReportModel.fromJson(item))
              .toList() ??
          [],
      fraudPatterns: FraudPatternsModel.fromJson(json['fraudPatterns'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'category': category,
      'sku': sku,
      'priceRange': priceRange,
      'image': imageUrl,
      'verificationStatus': verificationStatus.value,
      'confidenceScore': confidenceScore,
      'verificationHistory': verificationHistory.map((item) => item.toJson()).toList(),
      'riskIndicators': riskIndicators.map((item) => item.toJson()).toList(),
      'similarReports': similarReports.map((item) => item.toJson()).toList(),
      'fraudPatterns': fraudPatterns.toJson(),
    };
  }

  ProductVerificationModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? category,
    String? sku,
    String? priceRange,
    String? imageUrl,
    VerificationStatus? verificationStatus,
    double? confidenceScore,
    List<VerificationHistoryModel>? verificationHistory,
    List<RiskIndicatorModel>? riskIndicators,
    List<SimilarReportModel>? similarReports,
    FraudPatternsModel? fraudPatterns,
  }) {
    return ProductVerificationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      priceRange: priceRange ?? this.priceRange,
      imageUrl: imageUrl ?? this.imageUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      verificationHistory: verificationHistory ?? this.verificationHistory,
      riskIndicators: riskIndicators ?? this.riskIndicators,
      similarReports: similarReports ?? this.similarReports,
      fraudPatterns: fraudPatterns ?? this.fraudPatterns,
    );
  }
}

enum VerificationStatus {
  authentic('authentic'),
  suspicious('suspicious'),
  unknown('unknown');

  const VerificationStatus(this.value);
  final String value;

  static VerificationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'authentic':
        return VerificationStatus.authentic;
      case 'suspicious':
        return VerificationStatus.suspicious;
      case 'unknown':
      default:
        return VerificationStatus.unknown;
    }
  }
}

class VerificationHistoryModel {
  final int id;
  final String verifierName;
  final double trustScore;
  final DateTime timestamp;
  final VerificationMethod method;
  final String location;

  VerificationHistoryModel({
    required this.id,
    required this.verifierName,
    required this.trustScore,
    required this.timestamp,
    required this.method,
    required this.location,
  });

  factory VerificationHistoryModel.fromJson(Map<String, dynamic> json) {
    return VerificationHistoryModel(
      id: json['id'] ?? 0,
      verifierName: json['verifierName'] ?? '',
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      method: VerificationMethod.fromString(json['method'] ?? 'qr'),
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verifierName': verifierName,
      'trustScore': trustScore,
      'timestamp': timestamp.toIso8601String(),
      'method': method.value,
      'location': location,
    };
  }
}

enum VerificationMethod {
  qr('qr'),
  barcode('barcode');

  const VerificationMethod(this.value);
  final String value;

  static VerificationMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'qr':
        return VerificationMethod.qr;
      case 'barcode':
        return VerificationMethod.barcode;
      default:
        return VerificationMethod.qr;
    }
  }
}

class RiskIndicatorModel {
  final int id;
  final String title;
  final RiskSeverity severity;
  final String description;
  final String? recommendation;

  RiskIndicatorModel({
    required this.id,
    required this.title,
    required this.severity,
    required this.description,
    this.recommendation,
  });

  factory RiskIndicatorModel.fromJson(Map<String, dynamic> json) {
    return RiskIndicatorModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      severity: RiskSeverity.fromString(json['severity'] ?? 'low'),
      description: json['description'] ?? '',
      recommendation: json['recommendation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'severity': severity.value,
      'description': description,
      'recommendation': recommendation,
    };
  }
}

enum RiskSeverity {
  low('low'),
  medium('medium'),
  high('high');

  const RiskSeverity(this.value);
  final String value;

  static RiskSeverity fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return RiskSeverity.low;
      case 'medium':
        return RiskSeverity.medium;
      case 'high':
        return RiskSeverity.high;
      default:
        return RiskSeverity.low;
    }
  }
}

class SimilarReportModel {
  final int id;
  final String productName;
  final ReportType type;
  final int count;
  final int similarity;

  SimilarReportModel({
    required this.id,
    required this.productName,
    required this.type,
    required this.count,
    required this.similarity,
  });

  factory SimilarReportModel.fromJson(Map<String, dynamic> json) {
    return SimilarReportModel(
      id: json['id'] ?? 0,
      productName: json['productName'] ?? '',
      type: ReportType.fromString(json['type'] ?? 'unknown'),
      count: json['count'] ?? 0,
      similarity: json['similarity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'type': type.value,
      'count': count,
      'similarity': similarity,
    };
  }
}

enum ReportType {
  authentic('authentic'),
  fake('fake'),
  suspicious('suspicious'),
  unknown('unknown');

  const ReportType(this.value);
  final String value;

  static ReportType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'authentic':
        return ReportType.authentic;
      case 'fake':
        return ReportType.fake;
      case 'suspicious':
        return ReportType.suspicious;
      case 'unknown':
      default:
        return ReportType.unknown;
    }
  }
}

class FraudPatternsModel {
  final int priceManipulation;
  final int fakeReviews;
  final int locationMismatches;

  FraudPatternsModel({
    required this.priceManipulation,
    required this.fakeReviews,
    required this.locationMismatches,
  });

  factory FraudPatternsModel.fromJson(Map<String, dynamic> json) {
    return FraudPatternsModel(
      priceManipulation: json['priceManipulation'] ?? 0,
      fakeReviews: json['fakeReviews'] ?? 0,
      locationMismatches: json['locationMismatches'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priceManipulation': priceManipulation,
      'fakeReviews': fakeReviews,
      'locationMismatches': locationMismatches,
    };
  }
}

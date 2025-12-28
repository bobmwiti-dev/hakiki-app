// Flutter packages
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:sizer/sizer.dart';
export 'package:provider/provider.dart';

// Core exports
export 'constants/app_constants.dart';
export 'theme/app_theme.dart';
// export 'services/service_locator.dart'; // File doesn't exist
// export 'providers/theme_provider.dart'; // File doesn't exist
export 'services/auth_service.dart';
export 'services/firestore_service.dart';
export 'services/analytics_service.dart';
export 'providers/app_providers.dart';

// Presentation layer exports
export '../presentation/shared/routes/routes/app_routes.dart';
export '../presentation/shared/widgets/custom_error_widget.dart';

// Data layer exports
export '../data/models/user_model.dart';
export '../data/models/product_model.dart';
export '../data/models/vendor_model.dart';
export '../data/models/fraud_report_model.dart';
export '../data/models/product_verification_model.dart';
export '../data/models/report_model.dart';

// Domain layer exports (to be added as needed)

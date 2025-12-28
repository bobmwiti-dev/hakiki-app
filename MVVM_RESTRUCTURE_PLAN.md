# MVVM Architecture Restructuring Plan

## Current Structure Issues
- ViewModels are in root `lib/viewmodels/` instead of feature-specific locations
- Mixed organization between `lib/features/` and `lib/views/`
- Data models scattered across different locations
- Inconsistent layering and separation of concerns

## Target MVVM Structure

```
lib/
├── main.dart
├── app.dart
├── core/                           # Shared utilities, themes, constants
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   ├── widgets/                    # Reusable UI components
│   ├── services/                   # Core services (API, storage, etc.)
│   └── app_export.dart
├── data/                           # Data Layer
│   ├── models/                     # Data models
│   ├── repositories/               # Repository implementations
│   ├── datasources/               # API clients, local storage
│   └── services/                  # Data services
├── domain/                         # Business Logic Layer
│   ├── entities/                  # Business entities
│   ├── repositories/              # Repository interfaces
│   └── usecases/                  # Business use cases
└── presentation/                   # Presentation Layer
    ├── features/
    │   ├── auth/
    │   │   ├── views/             # UI Screens
    │   │   ├── widgets/           # Feature-specific widgets
    │   │   └── viewmodels/        # ViewModels for this feature
    │   ├── home/
    │   ├── vendor/
    │   ├── admin/
    │   ├── qr_scanner/
    │   ├── product_verification/
    │   └── fraud_reports/
    └── shared/
        ├── widgets/               # Shared presentation widgets
        └── routes/                # Navigation
```

## Migration Steps

### Phase 1: Create New Structure
1. Create `presentation/` directory
2. Create `domain/` directory  
3. Move features to `presentation/features/`
4. Move ViewModels to respective feature directories

### Phase 2: Reorganize Data Layer
1. Consolidate models in `data/models/`
2. Move repositories to `data/repositories/`
3. Create `data/datasources/` for API clients

### Phase 3: Create Domain Layer
1. Create business entities in `domain/entities/`
2. Define repository interfaces in `domain/repositories/`
3. Implement use cases in `domain/usecases/`

### Phase 4: Update Imports
1. Update all import statements
2. Update `app_export.dart`
3. Update routing configuration

## Benefits
- Clear separation of concerns
- Feature-based organization
- Scalable architecture
- Easier testing and maintenance
- Follows Flutter best practices

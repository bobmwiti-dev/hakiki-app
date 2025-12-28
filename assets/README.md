# Assets Folder Structure

This folder contains all static assets for the Hakiki app.

## Folder Organization

### 📁 images/
- **icons/** - App icons, navigation icons, feature icons
- **logos/** - App logo, brand logos, partner logos
- **backgrounds/** - Background images, patterns, gradients
- **illustrations/** - Custom illustrations, graphics, artwork
- **onboarding/** - Onboarding screen images and graphics
- **products/** - Product images, sample products, placeholders

### 📁 icons/
- App launcher icons
- Platform-specific icons (Android, iOS)
- Notification icons

### 📁 fonts/
- Custom font files (.ttf, .otf)
- Font licenses and documentation

### 📁 animations/
- Lottie animation files (.json)
- GIF animations
- Animation assets

## Usage Guidelines

### Image Formats
- **PNG** - For images with transparency, icons
- **JPG** - For photos, backgrounds without transparency
- **SVG** - For scalable vector graphics (use flutter_svg package)
- **WebP** - For optimized web images

### Naming Convention
Use descriptive, lowercase names with underscores:
- `app_logo.png`
- `onboarding_welcome.png`
- `icon_qr_scanner.svg`
- `background_gradient.png`

### Image Sizes
Provide multiple resolutions for different screen densities:
- `image.png` (1x)
- `image@2x.png` (2x)
- `image@3x.png` (3x)

### Example Usage in Code
```dart
// For regular images
Image.asset('assets/images/logos/app_logo.png')

// For SVG icons
SvgPicture.asset('assets/images/icons/qr_scanner.svg')

// For animations
Lottie.asset('assets/animations/loading.json')
```

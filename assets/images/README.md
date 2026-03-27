# 📱 Zingify App Assets

## Logo Files
- `zingify_logo.png` - Main app logo (400x400px)
- `app_icon.png` - App store icon (512x512px)
- `zingify_splash.png` - Splash screen image
- `logo_design_guide.md` - Design specifications

## Android Icons
All Android launcher icons are generated as adaptive icons:
- `mipmap-hdpi/` - High density (48x48)
- `mipmap-mdpi/` - Medium density (48x48)
- `mipmap-xhdpi/` - Extra high density (96x96)
- `mipmap-xxhdpi/` - Extra extra high density (144x144)
- `mipmap-xxxhdpi/` - Extra extra extra high density (192x192)

## Vector Graphics
- `zingify_logo.xml` - Vector logo for Android
- `ic_launcher_foreground.xml` - Adaptive icon foreground
- `ic_launcher_background.xml` - Adaptive icon background
- `launch_background.xml` - Splash screen background

## Integration
The logo is integrated into:
1. **App Launch Screen** - Full splash with gradient
2. **Login Screen** - Main branding element
3. **App Bar** - Compact logo version
4. **Notifications** - Small icon version
5. **App Icon** - Launcher icon

## Colors Used
- Primary: Indigo (#6366F1)
- Secondary: Pink (#EC4899)
- Accent: Emerald (#10B981)
- White: #FFFFFF

## Usage in Code
```dart
// Flutter app
Image.asset('assets/images/zingify_logo.png')

// Android XML
@drawable/zingify_logo
@drawable/ic_launcher
```

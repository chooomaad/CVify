<div align="center">

# CVify

**Professional CV & Resume Builder**

*Create stunning resumes in minutes — 100% free, no account required.*

[![Flutter](https://img.shields.io/badge/Flutter-3.29%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7%2B-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-1.0.0-blue)](https://github.com/your-username/cvify/releases)

</div>

---

## Overview

CVify is a polished, production-ready Flutter application that lets users build professional resumes with ease. It features 5 unique templates, unlimited PDF export, real-time preview, and bilingual support (French & English) — all completely free with no ads or paywalls.

---

## Screenshots

| Home | Templates | CV Builder | PDF Preview |
|------|-----------|------------|-------------|
| *coming soon* | *coming soon* | *coming soon* | *coming soon* |

> Run the app locally to see the full experience: `flutter run`

---

## Features

### Core
- **5 professional templates** — Modern (Nova), Minimalist (Pure), Corporate (Executive), Creative (Canvas), ATS-optimized (Clarity)
- **Unlimited PDF export** — high-quality, print-ready PDFs
- **Real-time preview** — see your resume update as you type
- **Photo support** — add a profile photo from your gallery
- **100% offline** — no internet connection required, all data stored locally
- **No account required** — open the app and start building immediately

### CV Builder Sections
- Personal information & professional summary
- Work experience with timeline view
- Education & academic background
- Skills with proficiency levels (5-star bar)
- Languages with proficiency selector

### Design
- **Dark mode / Light mode** — system-aware + manual toggle
- **5 distinct layouts** — each template has a completely unique visual structure
- Material 3 design system with custom theming
- Smooth 60fps animations powered by `flutter_animate`

### Multilingual
- **Français** (default)
- **English**
- Automatic device language detection on first launch

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.29+ / Dart 3.7+ |
| State Management | Riverpod 2.x (StateNotifier) |
| Navigation | GoRouter 13.x (ShellRoute) |
| PDF Generation | `pdf` 3.x + `printing` 5.x |
| Local Storage | Hive 2.x + SharedPreferences |
| Animations | flutter_animate 4.x |
| Fonts | Google Fonts (Inter) |
| i18n | Custom InheritedWidget system |

---

## Project Structure

```
cvify/
├── lib/
│   ├── app/
│   │   └── app.dart                 # MaterialApp root, theme, locale
│   ├── core/
│   │   ├── l10n/
│   │   │   └── translations.dart    # FR/EN translation system
│   │   ├── router/
│   │   │   └── app_router.dart      # GoRouter configuration
│   │   └── theme/
│   │       ├── app_colors.dart      # Design tokens & color palette
│   │       └── app_theme.dart       # Light / dark Material themes
│   ├── features/
│   │   ├── cv_builder/              # 5-step guided CV builder
│   │   ├── home/                    # Dashboard + bottom navigation
│   │   ├── onboarding/              # First-launch onboarding
│   │   ├── pdf_export/              # PDF generation & preview
│   │   ├── premium/                 # Free features showcase
│   │   ├── settings/                # Language, dark mode, about
│   │   ├── splash/                  # Animated splash screen
│   │   └── templates/               # 5 template previews
│   ├── shared/
│   │   ├── models/
│   │   │   ├── cv_model.dart        # CV data model (Hive)
│   │   │   └── template_model.dart  # Template definitions & enum
│   │   └── providers/
│   │       ├── app_state_provider.dart
│   │       └── cv_provider.dart
│   └── main.dart
├── assets/
│   ├── images/                      # logo.png, screenshots
│   └── icons/
├── android/                         # Android-specific config
├── ios/                             # iOS-specific config
├── web/                             # Web manifest & favicon
├── codemagic.yaml                   # CI/CD configuration
└── pubspec.yaml
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.29.0` — [Install Flutter](https://docs.flutter.dev/get-started/install)
- Dart SDK `>=3.7.0`
- Xcode 15+ (iOS builds)
- Android Studio or VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/cvify.git
cd cvify

# Install dependencies
flutter pub get

# Run the app (choose your target)
flutter run                            # auto-detect device
flutter run -d chrome                  # web browser
```

### Build Commands

```bash
# Release builds
flutter build apk --release            # Android APK
flutter build appbundle --release      # Android AAB (Play Store)
flutter build ipa --release            # iOS IPA (App Store)
flutter build web --release            # Web deployment

# Code quality
flutter analyze                        # Static analysis (0 issues)
flutter test                           # Run tests
dart format lib/ --set-exit-if-changed # Format check
```

---

## PDF Templates

| Template | Layout Style | Accent Color |
|----------|-------------|--------------|
| **Nova** — Modern | Two-column, blue sidebar with skill bars | `#2563EB` |
| **Pure** — Minimalist | Single column, vertical timeline | `#1F2937` |
| **Executive** — Corporate | Full-width navy header, two-column body | `#0F2044` |
| **Canvas** — Creative | Purple sidebar, chip-style skills | `#7C3AED` |
| **Clarity** — ATS | Plain single column, keyword-friendly | `#0D9488` |

---

## Multilingual System

The app uses a custom `InheritedWidget` translation system — no code generation required:

```dart
// Any widget with BuildContext:
context.t('nav_home')         // "Accueil" (FR) / "Home" (EN)
context.t('builder_title')    // "Créer mon CV" / "Create Resume"

// Change language programmatically:
ref.read(appStateProvider.notifier).setLang('en');
```

Language preference is persisted via `SharedPreferences`. Device locale is detected automatically on first launch.

---

## CI/CD — Codemagic

This project is configured for automated builds via Codemagic:

```yaml
# Workflows defined in codemagic.yaml:
# - android-release  →  APK + AAB
# - ios-release      →  IPA via App Store Connect
```

**Setup in Codemagic:**
1. Connect your GitHub repository
2. Select the `codemagic.yaml` configuration
3. Add your signing credentials as environment variables
4. Trigger a build

---

## App Store Readiness

| Item | Status |
|------|--------|
| iOS icons — all required sizes | ✅ |
| Android adaptive icons | ✅ |
| Web favicon + PWA manifest | ✅ |
| Photo library permission (iOS) | ✅ |
| App display name "CVify" | ✅ |
| `flutter analyze` — 0 issues | ✅ |
| Portrait lock (mobile) | ✅ |
| Dark mode support | ✅ |

**Before App Store submission, configure in Xcode:**
- Signing Team & certificate
- Bundle ID (`com.cvify.cvify`)
- iOS deployment target (≥ 16.0 recommended)

---

## Environment Variables (Codemagic)

| Variable | Description |
|----------|-------------|
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect API issuer ID |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | API key identifier |
| `APP_STORE_CONNECT_PRIVATE_KEY` | API private key (p8) |
| `CERTIFICATE_PRIVATE_KEY` | iOS distribution certificate |
| `KEYSTORE_FILE` | Android keystore (base64) |
| `KEYSTORE_PASSWORD` | Android keystore password |
| `KEY_ALIAS` | Android key alias |
| `KEY_PASSWORD` | Android key password |

---

## License

This project is licensed under the MIT License.

```
MIT License — Copyright (c) 2025 CVify

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the software.
```

---

<div align="center">

Made with ❤️ using [Flutter](https://flutter.dev)

</div>

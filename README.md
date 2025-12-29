# Ace Your Stats - Volleyball Statistics Tracker

<p align="center">
  <img src="assets/icon.svg" width="200" alt="Ace Your Stats Icon">
</p>

A professional volleyball statistics tracking app for coaches and teams, built with Flutter.

## Features

- 📊 Real-time rally tracking with automatic scoring
- 📈 Live momentum charts with score differential visualization
- 🔄 Automatic rotation and serve/receive phase tracking
- ⏱️ Timeout management for both teams
- 📱 Tablet-optimized interface for courtside use
- 💾 Complete offline functionality
- 📤 Export/import matches for backup and transfer
- 🎯 Rotation-based performance analysis

## App Store Pages

- **Privacy Policy:** [PRIVACY.md](PRIVACY.md)
- **Support & Help:** [SUPPORT.md](SUPPORT.md)
- **App Information:** [APP_INFO.md](APP_INFO.md)

## Tech Stack

- **Framework:** Flutter
- **Database:** SQLite (Drift ORM)
- **State Management:** Riverpod
- **Architecture:** Clean Architecture with offline-first design

## Getting Started

### Prerequisites

- Flutter SDK (3.x or later)
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/derekwalsh1/VBStats.git
   cd VBStats
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/               # Core utilities and services
│   └── services/       # Import/export services
├── data/               # Data layer
│   ├── datasources/    # Database tables and local data
│   └── repositories/   # Repository implementations
├── domain/             # Domain layer
│   └── entities/       # Business entities (Team, Match, Set, Rally)
└── presentation/       # Presentation layer
    ├── screens/        # UI screens
    ├── widgets/        # Reusable widgets
    └── providers/      # Riverpod providers
```

## Database Schema

- **Teams:** Store team information
- **Matches:** Track matches with opponent and date
- **Sets:** Individual sets within matches
- **Rallies:** Rally-by-rally tracking with outcomes and rotations

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

[Your License Here]

## Contact

For support or questions, see [SUPPORT.md](SUPPORT.md)


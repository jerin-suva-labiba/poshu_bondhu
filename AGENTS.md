# AGENTS.md

## Architecture Overview
This is a Flutter pet care management app ("পোষা বন্ধু") using local SQLite database via sqflite. Core structure:
- **Models** (`lib/models/`): Data classes with `toMap()`/`fromMap()` for DB serialization (e.g., `Pet`, `VaccineEntry`)
- **Database** (`lib/database/database_helper.dart`): Singleton `DatabaseHelper` with CRUD methods for all tables (pets, weights, notes, vaccines, deworming, documents)
- **Screens** (`lib/screens/`): Stateful widgets for UI, each loading data via `DatabaseHelper.instance` in `initState()`
- **Navigation**: Bottom nav bar (Home/Calendar/VetShop), pet profiles with grid of care features
- **Data Flow**: Pet-centric; all care records linked by `petId`, calendar aggregates vaccine/deworming reminders

Key tables: pets (id, name, birthday, imagePath, breed, gender), weights (petId, weight, date), notes (petId, title, content, date), vaccines/deworming (petId, name, lastDate, nextDate, notes), documents (petId, fileName, filePath, notes, date)

## Critical Workflows
- **Build/Run**: `flutter run` (debug), `flutter build apk` (Android release)
- **Test**: `flutter test` (runs `test/widget_test.dart`)
- **Analyze**: `flutter analyze` (uses `analysis_options.yaml` with flutter_lints)
- **Notifications**: Schedule via `NotificationHelper.scheduleReminder()` on adding vaccines/deworming; initialized in `main.dart`
- **File Handling**: Images via `image_picker`, PDFs/documents via `file_picker` + `flutter_pdfview`, stored locally with `path_provider`

## Project-Specific Patterns
- **DB Queries**: Always filter by `petId`, order by date DESC (e.g., `getVaccines(int petId)`); use `DatabaseHelper.instance` singleton
- **Date Handling**: Store as ISO strings (e.g., `DateTime.now().toIso8601String()`), parse with `DateTime.parse()`; compute age in `Pet.age` getter
- **UI Forms**: Add/edit via `showModalBottomSheet` with `TextEditingController` and `showDatePicker`; refresh parent with `Navigator.pop()` + `_load()`
- **State Management**: Simple `setState()` in screens; reload data after navigation (e.g., `await Navigator.push(...); _loadPets()`)
- **Theming**: Centralized in `AppTheme` class with pastel colors (primary: #FFB3C6); use `AppTheme.primary` etc. for consistency
- **Assets**: Images in `assets/images/`, declared in `pubspec.yaml`; use `FileImage(File(pet.imagePath))` for pet avatars
- **Reminders**: `DatabaseHelper.getAllReminders()` returns `Map<String, List<Map>>` for calendar, combining vaccines/deworming by nextDate

## Key Files
- `lib/main.dart`: App entry, notification init, home screen
- `lib/database/database_helper.dart`: All DB operations, schema creation
- `lib/screens/home_screen.dart`: Pet list with bottom nav
- `lib/screens/pet_profile_screen.dart`: Feature grid navigation
- `lib/theme/app_theme.dart`: Color constants and ThemeData
- `lib/notifications/notification_helper.dart`: Local notification scheduling

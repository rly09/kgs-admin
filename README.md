# KGS Admin - Admin Dashboard

Admin dashboard for managing KGS Shop.

## Features
- Admin authentication
- Dashboard with analytics
- Product management (CRUD)
- Category management
- Order management
- Delivery tracking with map
- Real-time order updates
- Settings management

## Setup

### Prerequisites
- Flutter SDK 3.5.4+
- Android Studio / VS Code
- Supabase account

### Installation
1. Navigate to admin directory
2. Copy `.env` from parent directory
3. Run `flutter pub get`
4. Run `flutter run`

### Environment Variables
Uses same `.env` as customer app:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

## Project Structure
```
lib/
├── main.dart
├── presentation/admin/
├── data/
└── core/
```

## Build
```bash
flutter build apk --release
```

## Related
- Customer app: `d:\kpg\`
- Shared database: Supabase

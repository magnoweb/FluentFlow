# FluentFlow

> A **spaced repetition** language learning platform focused on *Listening* and *Speaking*, available as a Web app and Mobile app.

---

## Overview

FluentFlow applies the **SM-2** algorithm (SuperMemo 2) to schedule card reviews based on the user's performance — the better the answer, the longer until the next review. Each card is automatically assessed with a **CEFR** level (A1–C2) based on the linguistic complexity of the phrase.

The platform has three main components:

| Component | Technology | Description |
|---|---|---|
| **API** | .NET 10 / ASP.NET Core | REST API with JWT, SignalR and Whisper.net |
| **Web** | Blazor WebAssembly + MudBlazor | PWA with offline support |
| **Mobile** | Flutter | Native Android/iOS app with Drift (SQLite) offline-first |

---

## Features

### Study
- **Listening** mode (listen and self-assess) and **Speaking** mode (record and transcribe)
- SM-2 algorithm with automatic review scheduling
- Online transcription via **Whisper.net** (server-side) and offline via native **speech_to_text**
- Similarity scoring between transcription and original text (Levenshtein distance)
- Manual score 0–5 with visual progress feedback

### Cards & Decks
- Create and manage decks per language pair
- Cards with front, back, pronunciation and audio
- Bulk audio upload with async processing (SignalR for real-time progress)
- Automatic CEFR level classification (A1–C2) on card creation/update

### Study Sessions
- Full session history with score distribution
- Per-review detail: transcription, similarity ratio, previous/new SM-2 interval
- Filter by mode (Listening/Speaking) and deck

### Offline Sync (Mobile)
- Local database powered by **Drift/SQLite**
- Cards and decks synced on app launch
- Reviews stored locally when offline, synced automatically when connection is restored

### Authentication
- Email/password login
- Social login: **Google**, **Microsoft**, **GitHub**
- JWT + Refresh Token with automatic rotation
- Access logs per platform (Web / Mobile / Social)

### Internationalisation (i18n)
- Support for **Portuguese**, **English**, **Spanish** and **French**
- Web: `IStringLocalizer` with `.resx` resource files shared from `FluentFlow.Core`
- Mobile: `flutter_gen` with `.arb` files
- Real-time language switching (no page reload required)

### Administration (Admin role)
- Full user list with stats (decks, cards, last login)
- User detail view: decks, cards with CEFR level and audio playback
- Access logs per platform and IP address
- System logs (Serilog) with filters by level, date and search

---

## Architecture

```
FluentFlow/
├── src/
│   ├── FluentFlow.Api/              # ASP.NET Core Web API
│   │   ├── Controllers/             # Auth, Decks, Cards, Study, Admin, Logs, Batch
│   │   ├── Authorization/           # AdminRequirement, AdminHandler (policy-based)
│   │   ├── Extensions/              # Serilog, Claims helpers
│   │   ├── Hubs/                    # SignalR (batch processing progress)
│   │   └── Validators/              # FluentValidation validators
│   │
│   ├── FluentFlow.Core/             # Domain layer (no external dependencies)
│   │   ├── Common/                  # Result<T>, PagedResult, CefrCalculator, LocalizationHelper
│   │   ├── DTOs/                    # Data Transfer Objects
│   │   ├── Entities/                # Card, Deck, StudySession, AccessLog, ...
│   │   ├── Enums/                   # CefrLevel, StudyMode, UserType, JobStatus
│   │   ├── Interfaces/              # IAuthService, IDeckService, IAdminService, ...
│   │   └── Resources/               # App.pt.resx, App.en.resx, App.es.resx, App.fr.resx
│   │
│   ├── FluentFlow.Infrastructure/   # Infrastructure implementations
│   │   ├── Data/                    # EF Core DbContext + Configurations + Migrations
│   │   ├── Identity/                # ApplicationUser (ASP.NET Identity)
│   │   └── Services/                # AuthService, DeckService, CardService, AdminService, ...
│   │       └── Tools/               # AudioConverterService (NAudio + FFmpeg), WhisperSpeechToText
│   │
│   ├── FluentFlow.Web/              # Blazor Server (host)
│   │   └── FluentFlow.Web.Client/   # Blazor WASM (client logic)
│   │       ├── Components/Pages/    # Home, Decks, Study, Sessions, Admin, Logs
│   │       ├── Services/            # ApiClient, WebAuthService, TokenAuthStateProvider
│   │       └── wwwroot/             # JS helpers, CSS
│   │
│   └── FluentFlow.Mobile/           # Flutter
│       └── lib/
│           ├── core/                # ApiConstants, TextSimilarity, LocaleProvider
│           ├── data/
│           │   ├── local/           # Drift database, DAOs, Tables
│           │   └── remote/          # ApiClient, DTOs
│           ├── domain/sync/         # SyncService (offline → online)
│           ├── features/            # auth, decks, home, study
│           └── l10n/                # app_pt.arb, app_en.arb, app_es.arb, app_fr.arb
```

---

## Tech Stack

### API / Backend

| Technology | Version | Purpose |
|---|---|---|
| .NET | 10 | Runtime |
| ASP.NET Core | 10 | Web framework |
| Entity Framework Core | 10 | ORM |
| SQL Server | — | Database |
| ASP.NET Identity | — | User management |
| Whisper.net | — | Server-side speech transcription (offline) |
| NAudio | 2.3 | Audio conversion (WAV, MP3) without FFmpeg |
| Xabe.FFmpeg | — | Advanced format conversion (M4A, WebM, OGG) |
| SignalR | — | Real-time batch progress notifications |
| Serilog | — | Structured logging to SQL Server |
| FluentValidation | — | DTO validation |
| Scalar | — | OpenAPI interactive documentation |

### Web (Blazor)

| Technology | Version | Purpose |
|---|---|---|
| Blazor WebAssembly | .NET 10 | SPA / PWA |
| MudBlazor | — | Material Design UI components |
| Microsoft.Extensions.Localization | — | i18n with .resx resource files |

### Mobile (Flutter)

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `drift` + `sqlite3_flutter_libs` | Offline-first local database |
| `dio` | HTTP client |
| `speech_to_text` | Native offline speech recognition |
| `record` | Audio recording |
| `audioplayers` | Audio playback |
| `flutter_web_auth_2` | Social login via external browser |
| `connectivity_plus` | Connectivity detection |
| `shared_preferences` | Preference persistence |
| `flutter_localizations` + `intl` | i18n with .arb files |

---

## Prerequisites

### API / Web
- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- SQL Server (local or Azure)
- FFmpeg (optional — the API works without it using NAudio for WAV/MP3)

### Mobile
- [Flutter 3.x+](https://flutter.dev/docs/get-started/install)
- Android Studio or Xcode
- Physical device or emulator

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/your-username/fluentflow.git
cd fluentflow
```

### 2. Configure the API

Create `src/FluentFlow.Api/appsettings.Development.json` (do not commit):

```json
{
  "Environment": "Development",
  "ConnectionStrings": {
    "local": "Server=localhost;Database=FluentFlow;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Jwt": {
    "Key": "your-secret-key-minimum-32-characters",
    "Issuer": "FluentFlow",
    "Audience": "FluentFlowClient"
  },
  "Auth": {
    "Google": {
      "ClientId": "GOOGLE_CLIENT_ID",
      "ClientSecret": "GOOGLE_CLIENT_SECRET"
    },
    "Microsoft": {
      "ClientId": "MICROSOFT_CLIENT_ID",
      "ClientSecret": "MICROSOFT_CLIENT_SECRET"
    },
    "GitHub": {
      "ClientId": "GITHUB_CLIENT_ID",
      "ClientSecret": "GITHUB_CLIENT_SECRET"
    }
  },
  "AppBaseUrl": "https://localhost:5028",
  "AllowAllOriginsDev": true
}
```

### 3. Run the API

```bash
cd src/FluentFlow.Api
dotnet run --launch-profile https
```

Database migrations are applied automatically on startup.

### 4. Run the Web app

```bash
cd src/FluentFlow.Web/FluentFlow.Web
dotnet run
```

### 5. Run the Mobile app

```bash
cd src/FluentFlow.Mobile

# Update the base URL in lib/core/constants/api_constants.dart
# static const String baseUrl = 'http://192.168.1.XXX:5207';

flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Production Environment Variables

```bash
export ConnectionStrings__online="Server=...;Database=FluentFlow;..."
export Jwt__Key="your-production-secret-key"
export Auth__Google__ClientId="..."
export Auth__Google__ClientSecret="..."
export Auth__Microsoft__ClientId="..."
export Auth__Microsoft__ClientSecret="..."
export Auth__GitHub__ClientId="..."
export Auth__GitHub__ClientSecret="..."
export AppBaseUrl="https://your-domain.com"
```

---

## Social Login Setup

### Google
1. Go to [console.cloud.google.com](https://console.cloud.google.com) → Credentials → OAuth 2.0 Client ID
2. Add the following Authorized redirect URIs:
   ```
   https://localhost:7051/signin-google
   https://your-domain.com/signin-google
   ```

### Microsoft
1. Go to [portal.azure.com](https://portal.azure.com) → App registrations → New registration
2. Add the following Redirect URIs:
   ```
   https://localhost:7051/signin-microsoft
   https://your-domain.com/signin-microsoft
   ```

### Android deep link (Mobile)

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<intent-filter android:label="flutter_web_auth_2">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="fluentflow" android:host="auth" />
</intent-filter>
```

---

## CORS Configuration

Three scenarios are supported via `appsettings.json` flags:

| Scenario | `AllowAllOriginsDev` | `AllowLocalDev` | Allowed Origins |
|---|---|---|---|
| Full local dev (API + Web on localhost) | `true` | `false` | Any origin |
| Web on localhost → API on production | `false` | `true` | Production + localhost |
| Production | `false` | `false` | Production only |

---

## SM-2 Algorithm

FluentFlow implements the SuperMemo 2 algorithm to calculate the interval between reviews:

```
score 0–1 → reset (interval = 1 day)
score 2   → interval = 1 day
score 3+  → interval = previous × easeFactor

easeFactor = max(1.3, ef + 0.1 - (5 - score) × (0.08 + (5 - score) × 0.02))
```

Each card maintains two independent sets of SM-2 parameters: one for **Listening** and one for **Speaking**.

---

## CEFR Levels

Cards are automatically classified using linguistic heuristics:

| Level | Description | Score Range |
|---|---|---|
| A1 | Beginner | 0–20 |
| A2 | Elementary | 21–35 |
| B1 | Intermediate | 36–50 |
| B2 | Upper Intermediate | 51–65 |
| C1 | Advanced | 66–80 |
| C2 | Proficient | 81–100 |

The score is computed from: average word length (20%), sentence length (15%), vocabulary outside the top-500 most common words (30%), complex grammatical structures (20%) and advanced affixes (15%).

---

## API Reference

```
POST   /api/auth/register                Register a new user
POST   /api/auth/login                   Login with email/password
POST   /api/auth/refresh                 Refresh JWT token
POST   /api/auth/logout                  Revoke refresh token
GET    /api/auth/login/{provider}        Initiate social login
GET    /api/auth/callback/{provider}     Social login callback
GET    /api/auth/profile                 Get user profile
PUT    /api/auth/profile                 Update user profile

GET    /api/decks                        List decks
POST   /api/decks                        Create deck
GET    /api/decks/{id}                   Get deck detail
PUT    /api/decks/{id}                   Update deck
DELETE /api/decks/{id}                   Delete deck

GET    /api/decks/{id}/cards             List cards
POST   /api/decks/{id}/cards             Create card
PUT    /api/cards/{id}                   Update card
DELETE /api/cards/{id}                   Delete card
POST   /api/decks/{id}/recalculate-cefr  Batch recalculate CEFR levels

POST   /api/study/start                  Start study session
POST   /api/study/review                 Submit review
POST   /api/study/end/{id}               End session
POST   /api/study/transcribe             Transcribe audio recording
GET    /api/study/sessions               Session history
GET    /api/study/sessions/{id}          Session detail

GET    /api/admin/users                  List all users (Admin)
GET    /api/admin/users/{id}             User detail (Admin)
GET    /api/admin/access-logs            Access logs (Admin)

GET    /api/logs                         System logs (Admin)

POST   /api/audio-batch/upload/{deckId}  Bulk audio upload
GET    /api/audio-batch/jobs/{deckId}    Batch job status
```

Interactive documentation available at `/scalar/v1` in development.

---

## Card JSON Structure

```json
{
  "id": "uuid",
  "deckId": "uuid",
  "front": "Hello, how are you?",
  "back": "Olá, como estás?",
  "pronunciation": "hɛˈloʊ, haʊ ɑr juː",
  "audioPath": "audio/deck-id/a1b2c3d4_hello-how-are-you.mp3",
  "cefrLevel": "A1",
  "listeningRepetitions": 3,
  "listeningInterval": 6,
  "listeningNextReview": "2025-02-15T00:00:00Z",
  "speakingRepetitions": 1,
  "speakingInterval": 1,
  "speakingNextReview": "2025-02-10T00:00:00Z"
}
```

---

## Contributing

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

### Commit conventions

```
feat:     new feature
fix:      bug fix
docs:     documentation only
refactor: code change with no new feature or fix
chore:    maintenance (dependencies, config, tooling)
```

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Screenshots

> *(coming soon)*

---

## Roadmap

- [ ] Push notifications (Firebase Cloud Messaging)
- [ ] Progress dashboard with evolution charts
- [ ] Deck import via CSV / Anki format
- [ ] Automatic audio generation via TTS (Text-to-Speech)
- [ ] Group study / competitive mode
- [ ] iOS mobile app
- [ ] Docker + CI/CD pipeline

---

<div align="center">
  Built with ♥ using .NET 10 and Flutter
</div>

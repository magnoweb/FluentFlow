# FluentFlow

> Plataforma de aprendizagem de idiomas por **repetição espaçada** com foco em *Listening* e *Speaking*, disponível em versão Web e Mobile.

---

## Visão geral

O FluentFlow aplica o algoritmo **SM-2** (SuperMemo 2) para agendar revisões de cards com base no desempenho do utilizador — quanto melhor a resposta, mais tempo até a próxima revisão. Cada card é avaliado automaticamente com um nível **CEFR/QECR** (A1–C2) com base na complexidade linguística da frase.

A plataforma tem três componentes principais:

| Componente | Tecnologia | Descrição |
|---|---|---|
| **API** | .NET 10 / ASP.NET Core | REST API com JWT, SignalR e Whisper.net |
| **Web** | Blazor WebAssembly + MudBlazor | PWA com suporte offline |
| **Mobile** | Flutter | App nativa Android/iOS com Drift (SQLite) offline-first |

---

## Funcionalidades

### Estudo
- Modos **Listening** (ouvir e avaliar) e **Speaking** (gravar e transcrever)
- Algoritmo SM-2 com intervalos automáticos
- Transcrição online via **Whisper.net** (API) e offline via **speech_to_text** nativo
- Cálculo de similaridade entre transcrição e texto original (Levenshtein)
- Score manual 0–5 com feedback visual de progresso

### Cards e Decks
- Criação e gestão de decks por idioma
- Cards com frente, verso, pronúncia e áudio
- Upload em lote de áudios com processamento assíncrono (SignalR para progresso em tempo real)
- Categorização automática por nível CEFR (A1–C2) ao criar/actualizar cards

### Sessões de Estudo
- Histórico completo de sessões com distribuição de scores
- Detalhe por review: transcrição, similaridade, intervalo SM-2 anterior/novo
- Filtro por modo (Listening/Speaking) e deck

### Sincronização Offline (Mobile)
- Base de dados local com **Drift/SQLite**
- Cards e decks sincronizados ao abrir a app
- Reviews guardadas localmente se offline, sincronizadas quando ligação é restaurada

### Autenticação
- Login com email/password
- Login social: **Google**, **Microsoft**, **GitHub**
- JWT + Refresh Token com rotação automática
- Registo de acessos por plataforma (Web / Mobile / Social)

### Internacionalização (i18n)
- Suporte para **Português**, **Inglês**, **Espanhol** e **Francês**
- Web: `IStringLocalizer` com ficheiros `.resx` em `FluentFlow.Core`
- Mobile: `flutter_gen` com ficheiros `.arb`
- Mudança de idioma em tempo real (sem recarregar a página)

### Administração (perfil Admin)
- Listagem de todos os utilizadores com stats (decks, cards, último acesso)
- Detalhe por utilizador: decks, cards com nível CEFR e reprodução de áudio
- Logs de acesso por plataforma e IP
- Logs de sistema (Serilog) com filtros por nível, data e pesquisa

---

## Arquitectura

```
FluentFlow/
├── src/
│   ├── FluentFlow.Api/              # ASP.NET Core Web API
│   │   ├── Controllers/             # Auth, Decks, Cards, Study, Admin, Logs, Batch
│   │   ├── Extensions/              # Serilog, Claims
│   │   ├── Hubs/                    # SignalR (progresso de batch)
│   │   └── Validators/              # FluentValidation
│   │
│   ├── FluentFlow.Core/             # Domínio (sem dependências externas)
│   │   ├── Common/                  # Result<T>, PagedResult, CefrCalculator, LocalizationHelper
│   │   ├── DTOs/                    # Data Transfer Objects
│   │   ├── Entities/                # Card, Deck, StudySession, AccessLog, ...
│   │   ├── Enums/                   # CefrLevel, StudyMode, UserType, JobStatus
│   │   ├── Interfaces/              # IAuthService, IDeckService, IAdminService, ...
│   │   └── Resources/               # App.pt.resx, App.en.resx, App.es.resx, App.fr.resx
│   │
│   ├── FluentFlow.Infrastructure/   # Implementações de infra
│   │   ├── Data/                    # EF Core DbContext + Configurations + Migrations
│   │   ├── Identity/                # ApplicationUser (ASP.NET Identity)
│   │   └── Services/                # AuthService, DeckService, CardService, AdminService, ...
│   │       └── Tools/               # AudioConverterService (NAudio + FFmpeg), WhisperSpeechToText
│   │
│   ├── FluentFlow.Web/              # Blazor Server (host)
│   │   └── FluentFlow.Web.Client/   # Blazor WASM (lógica do cliente)
│   │       ├── Components/Pages/    # Home, Decks, Study, Sessions, Admin, Logs
│   │       ├── Services/            # ApiClient, WebAuthService, TokenAuthStateProvider
│   │       └── wwwroot/             # JS, CSS
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

## Stack técnica

### API / Backend
| Tecnologia | Versão | Uso |
|---|---|---|
| .NET | 10 | Runtime |
| ASP.NET Core | 10 | Web framework |
| Entity Framework Core | 10 | ORM |
| SQL Server | — | Base de dados |
| ASP.NET Identity | — | Gestão de utilizadores |
| Whisper.net | — | Transcrição de voz (offline, no servidor) |
| NAudio | 2.3 | Conversão de áudio (WAV, MP3) sem FFmpeg |
| Xabe.FFmpeg | — | Conversão de formatos avançados (M4A, WebM, OGG) |
| SignalR | — | Progresso de batch em tempo real |
| Serilog | — | Logging estruturado para SQL Server |
| FluentValidation | — | Validação de DTOs |
| Scalar | — | Documentação OpenAPI |

### Web (Blazor)
| Tecnologia | Versão | Uso |
|---|---|---|
| Blazor WebAssembly | .NET 10 | SPA / PWA |
| MudBlazor | — | Componentes UI Material Design |
| Microsoft.Extensions.Localization | — | i18n com ficheiros .resx |

### Mobile (Flutter)
| Pacote | Uso |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Navegação |
| `drift` + `sqlite3_flutter_libs` | Base de dados local offline-first |
| `dio` | HTTP client |
| `speech_to_text` | Transcrição nativa offline |
| `record` | Gravação de áudio |
| `audioplayers` | Reprodução de áudio |
| `flutter_web_auth_2` | Social login via browser externo |
| `connectivity_plus` | Detecção de conectividade |
| `shared_preferences` | Persistência de preferências |
| `flutter_localizations` + `intl` | i18n com ficheiros .arb |

---

## Pré-requisitos

### API / Web
- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- SQL Server (local ou Azure)
- FFmpeg (opcional — a API funciona sem ele usando NAudio para WAV/MP3)

### Mobile
- [Flutter 3.x+](https://flutter.dev/docs/get-started/install)
- Android Studio ou Xcode
- Dispositivo físico ou emulador

---

## Configuração

### 1. Clonar o repositório

```bash
git clone https://github.com/seu-utilizador/fluentflow.git
cd fluentflow
```

### 2. Configurar a API

Criar `src/FluentFlow.Api/appsettings.Development.json` (não commitar):

```json
{
  "Environment": "Development",
  "ConnectionStrings": {
    "local": "Server=localhost;Database=FluentFlow;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Jwt": {
    "Key": "chave-secreta-minimo-32-caracteres",
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

### 3. Aplicar migrations e arrancar a API

```bash
cd src/FluentFlow.Api
dotnet run --launch-profile https
```

As migrations são aplicadas automaticamente no arranque.

### 4. Configurar e arrancar o Web

```bash
cd src/FluentFlow.Web/FluentFlow.Web
dotnet run
```

### 5. Configurar e arrancar o Mobile

```bash
cd src/FluentFlow.Mobile

# Actualizar o baseUrl em lib/core/constants/api_constants.dart
# static const String baseUrl = 'http://192.168.1.XXX:5207';

flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Variáveis de ambiente (produção)

```bash
# Configurações sensíveis via variáveis de ambiente
export ConnectionStrings__online="Server=...;Database=FluentFlow;..."
export Jwt__Key="chave-secreta-producao"
export Auth__Google__ClientId="..."
export Auth__Google__ClientSecret="..."
export Auth__Microsoft__ClientId="..."
export Auth__Microsoft__ClientSecret="..."
export Auth__GitHub__ClientId="..."
export Auth__GitHub__ClientSecret="..."
export AppBaseUrl="https://fluentflow.magnoweb.net"
```

---

## Configurar login social

### Google
1. [console.cloud.google.com](https://console.cloud.google.com) → Credentials → OAuth 2.0 Client ID
2. Authorized redirect URIs:
   - `https://localhost:7051/signin-google`
   - `https://fluentflow.magnoweb.net/signin-google`

### Microsoft
1. [portal.azure.com](https://portal.azure.com) → App registrations → New registration
2. Redirect URIs:
   - `https://localhost:7051/signin-microsoft`
   - `https://fluentflow.magnoweb.net/signin-microsoft`

### Android (deep link para mobile)
Adicionar ao `AndroidManifest.xml`:
```xml
<intent-filter android:label="flutter_web_auth_2">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="fluentflow" android:host="auth" />
</intent-filter>
```

---

## Algoritmo SM-2

O FluentFlow implementa o algoritmo SuperMemo 2 para calcular o intervalo entre revisões:

```
score 0–1 → resetar (interval = 1 dia)
score 2   → interval = 1 dia
score 3   → interval = anterior × easeFactor
score 4–5 → interval cresce e easeFactor aumenta

easeFactor = max(1.3, ef + 0.1 - (5 - score) × (0.08 + (5 - score) × 0.02))
```

Cada card tem dois conjuntos independentes de parâmetros SM-2: um para **Listening** e outro para **Speaking**.

---

## Níveis CEFR

Os cards são classificados automaticamente com base em heurísticas linguísticas:

| Nível | Descrição | Score aproximado |
|---|---|---|
| A1 | Iniciante | 0–20 |
| A2 | Elementar | 21–35 |
| B1 | Intermédio | 36–50 |
| B2 | Intermédio Superior | 51–65 |
| C1 | Avançado | 66–80 |
| C2 | Proficiente | 81–100 |

O score é calculado com base em: comprimento das palavras (20%), comprimento da frase (15%), vocabulário fora do top-500 (30%), estruturas gramaticais complexas (20%) e afixos avançados (15%).

---

## API — endpoints principais

```
POST /api/auth/register          Registar utilizador
POST /api/auth/login             Login com email/password
POST /api/auth/refresh           Renovar token JWT
POST /api/auth/logout            Revogar refresh token
GET  /api/auth/login/{provider}  Iniciar social login
GET  /api/auth/callback/{provider} Callback social login
GET  /api/auth/profile           Perfil do utilizador
PUT  /api/auth/profile           Actualizar perfil

GET  /api/decks                  Listar decks
POST /api/decks                  Criar deck
GET  /api/decks/{id}             Detalhe do deck
PUT  /api/decks/{id}             Actualizar deck
DELETE /api/decks/{id}           Eliminar deck

GET  /api/decks/{id}/cards       Listar cards
POST /api/decks/{id}/cards       Criar card
PUT  /api/cards/{id}             Actualizar card
DELETE /api/cards/{id}           Eliminar card
POST /api/decks/{id}/recalculate-cefr  Recalcular CEFR em lote

POST /api/study/start            Iniciar sessão
POST /api/study/review           Submeter review
POST /api/study/end/{id}         Terminar sessão
POST /api/study/transcribe       Transcrever áudio
GET  /api/study/sessions         Histórico de sessões
GET  /api/study/sessions/{id}    Detalhe de sessão

GET  /api/admin/users            Listar utilizadores (Admin)
GET  /api/admin/users/{id}       Detalhe de utilizador (Admin)
GET  /api/admin/access-logs      Logs de acesso (Admin)

GET  /api/logs                   Logs de sistema (Admin)

POST /api/audio-batch/upload/{deckId}  Upload em lote de áudios
GET  /api/audio-batch/jobs/{deckId}    Estado dos jobs
```

Documentação interactiva disponível em `/scalar/v1` (desenvolvimento).

---

## Estrutura de um Card

```json
{
  "id": "uuid",
  "deckId": "uuid",
  "front": "Hello, how are you?",
  "back": "Olá, como estás?",
  "pronunciation": "hɛˈloʊ, haʊ ɑr juː",
  "audioPath": "audio/deck-id/uuid_hello-how-are-you.mp3",
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

## Contribuição

1. Fazer fork do repositório
2. Criar branch: `git checkout -b feature/nome-da-feature`
3. Commit: `git commit -m 'feat: descrição da feature'`
4. Push: `git push origin feature/nome-da-feature`
5. Abrir Pull Request

### Convenções de commit
```
feat:     nova funcionalidade
fix:      correcção de bug
docs:     documentação
refactor: refactoring sem nova funcionalidade
chore:    manutenção (dependências, configuração)
```

---

## Licença

Este projecto está licenciado sob a [MIT License](LICENSE).

---

## Screenshots

> *(a adicionar)*

---

## Roadmap

- [ ] Push notifications (Firebase Cloud Messaging)
- [ ] Dashboard de progresso com gráficos de evolução
- [ ] Importação de decks via CSV / Anki
- [ ] Geração automática de áudio via TTS (Text-to-Speech)
- [ ] Modo de estudo em grupo / competição
- [ ] Versão iOS da app mobile
- [ ] Docker + CI/CD pipeline

---

<div align="center">
  Desenvolvido com ♥ usando .NET 10 e Flutter
</div>

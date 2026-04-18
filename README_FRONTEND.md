# VANI Frontend README

This document explains your Flutter frontend architecture and every screen/module code flow.

## 1) Frontend overview

Frontend stack:

- Flutter (cross-platform: Web, Android, iOS, Desktop)
- Camera capture (`camera`)
- WebSocket live inference (`web_socket_channel`)
- TTS (`flutter_tts`), STT (`speech_to_text`)
- Local persistence (`hive`)
- Authentication + cloud sync (`supabase_flutter`)
- Location (`geolocator`)

Main entry:

- `lib/main.dart`

## 2) App bootstrap flow

`main.dart` boot sequence:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. UI mode + system overlays configured
3. `runApp(VaniApp())`

`AppBootstrap.ensureInitialized()` performs one-time startup services:

- Hive initialization
- EmergencyContact adapter registration
- opens `emergency_contacts` box
- validates Supabase dart-defines
- initializes Supabase

This bootstrap is triggered from splash screen before moving to Home.

## 3) Global architecture (frontend)

```text
main.dart
  -> SplashScreen (bootstrap + animated intro)
  -> HomeScreen (hub)
     -> TranslateScreen (ISL -> text)
     -> TwoWayScreen (conversation bridge)
     -> SignsPage (dictionary/learning)
     -> ISLAssistantScreen (Gemini assistant)
     -> EmergencyScreen / EmergencySetupScreen
     -> Objective pages (6 screens)
```

Cross-cutting shared layers:

- Components: `GlobalNavbar`, `SOSFloatingButton`, `AuthDialog`
- Services: backend URL config, emergency orchestration, location, Supabase
- Models: `EmergencyContact`
- Localization: `AppLocalizations`

## 4) Services and data layer

### `lib/services/backend_config.dart`

Purpose:

- central source of backend URLs
- WebSocket/API URL resolution using `--dart-define`
- platform-aware candidate fallback (especially Android emulator loopback)

Important members:

- `websocketUrl`
- `websocketCandidates`
- `apiBaseUrl`
- `apiBaseCandidates`
- `healthUrl`

Why important:

- avoids hardcoded endpoint logic inside each screen
- supports local, staging, production with env flags

### `lib/services/EmergencyService.dart`

Purpose:

- singleton emergency orchestration service

Main responsibilities:

- manages emergency contacts in Hive
- optional Supabase sync CRUD integration
- shake detection trigger
- location-aware SOS message creation
- launches WhatsApp/SMS URI flows (mobile)
- web/desktop fallback handling

Core types:

- `SOSMessageType`
- `SOSResult`

Critical methods:

- `init()`, `syncFromSupabase()`, `pushLocalContactsToSupabase()`
- `addContact()`, `updateContact()`, `deleteContact()`, `setPrimary()`
- `triggerSOS(...)`

### `lib/services/LocationService.dart`

Purpose:

- unified geolocation API for mobile + web

Flow:

1. checks service availability
2. checks/requests permission
3. gets current position with timeout
4. fallback to last known location

Includes helper methods for:

- google maps link generation
- message placeholder interpolation (`{LOCATION}`, `{TIME}`)

### `lib/services/SupabaseService.dart`

Purpose:

- single source for Supabase DB operations

Functions:

- user profile upsert
- emergency contacts CRUD in cloud table
- cloud-to-local Hive sync

### `lib/services/web_home_nav.dart`

Purpose:

- lightweight section-navigation bus for Home web layout
- uses `ValueNotifier<WebHomeSection?>`

## 5) Components

### `lib/components/GlobalNavbar.dart`

What it does:

- responsive top navigation for web/desktop/mobile
- route navigation to feature screens
- home-section jump on web
- language dropdown
- theme toggle
- auth sign-in/sign-out actions
- SOS highlighted nav action

### `lib/components/SOSFloatingButton.dart`

What it does:

- persistent quick SOS action button
- expandable quick-action menu
- long-press instant general emergency
- can open full EmergencyScreen

### `lib/components/AuthDialog.dart`

What it does:

- login/signup UI and flow
- Supabase auth integration
- post-auth contact sync between Supabase and Hive
- can render as dialog or fullscreen auth screen

## 6) Models

### `lib/models/EmergencyContact.dart`

Data fields:

- `name`, `phone`, `relation`, `isPrimary`, `supabaseId`

Utility methods:

- phone cleaning and validation
- WhatsApp/SMS number normalization
- map serialization

### `lib/models/EmergencyContact.g.dart`

- generated Hive adapter (read/write binary format)
- includes `supabaseId` field persistence

## 7) Localization system

### `lib/l10n/AppLocalizations.dart`

Purpose:

- central translation map and localization delegate
- supported locales currently include: English, Hindi, Marathi

Key method:

- `t(key)` style lookups through localized maps

This is used across all screens for UI text consistency.

## 8) Screen-by-screen explanation

## `lib/screens/SplashScreen.dart`

Role:

- premium animated launch screen
- calls `AppBootstrap.ensureInitialized()`
- navigates to post-splash gate (home/auth flow)

Code behavior:

- multiple animation controllers for icon, text, exit fade
- timeline-based animation sequencing
- handles bootstrap failure with fallback error screen

## `lib/screens/HomeScreen.dart`

Role:

- central app hub
- mobile tabbed feed + web long-scroll landing sections
- entry point to all features

Code behavior:

- responsive split (`kIsWeb || width >= 700`)
- web section reveal and scroll targeting
- launches Translate, Signs, TwoWay, Emergency, Assistant, objective pages
- keeps FAB SOS available in mobile mode

## `lib/screens/TranslateScreen.dart`

Role:

- primary real-time ISL translation terminal

Key logic:

- camera initialization and frame capture loop
- websocket connection to backend
- parses prediction stream
- sentence generation pipeline:
  - `_kModelWords` vocabulary
  - `SentenceBuilder` (`_solo`, `_pairs`, `_triples`)
  - `_AutoAddEngine` stability/cooldown logic
- optional translation/TTS utilities
- onboarding flow and polished UI states

Why this screen is core:

- this is where ML output becomes meaningful language output.

## `lib/screens/TwoWayScreen.dart`

Role:

- bridge between deaf and hearing users

Key logic:

- ISL capture and websocket prediction ingestion
- message thread model (`_Message`, `_Sender`)
- hearing-side input:
  - typed text
  - speech-to-text (`speech_to_text`)
- deaf-side output:
  - TTS readout (`flutter_tts`)
- multilingual locale config for TTS/STT
- reconnect and camera switching logic

## `lib/screens/Signspage.dart`

Role:

- ISL reference and learning vault

Key logic:

- local sign catalog model (`_Sign`, category enum)
- 64 sign entries (alphabet, numbers, words)
- filter/search/category browsing
- responsive presentation patterns for web/mobile

## `lib/screens/Islassistantscreen.dart`

Role:

- AI conversational ISL assistant

Key logic:

- Gemini call via HTTP (`generateContent` API)
- system prompt specialized for ISL teaching behavior
- multilingual quick prompts and language profile
- optional voice input and TTS readout
- chat message model with assistant/user roles

## `lib/screens/EmergencyScreen.dart`

Role:

- emergency dispatch UI for scenario-based SOS

Key logic:

- predefined emergency scenarios mapped to type/helpline/message template
- auto scenario suggestion from detected sign text
- invokes `EmergencyService.triggerSOS(...)`
- status banners and contact readiness checks
- web/desktop and mobile layouts

## `lib/screens/EmergencySetupScreen.dart`

Role:

- manage emergency contacts and emergency preferences

Key logic:

- CRUD on local contacts through `EmergencyService`
- set primary contact
- contact validation flows
- form and modal interactions
- optional shake support messaging

## Objective screens (`lib/screens/objectives/*`)

Shared engine:

- `objective_shared.dart` defines reusable objective page scaffold, hero, stats, section blocks, charts, timeline components.

Individual pages:

- `AccessibilityPage.dart`
- `BridgingGapsPage.dart`
- `LocalizationPage.dart`
- `InclusivityPage.dart`
- `PrivacyPage.dart`
- `EducationPage.dart`

Pattern:

- each page supplies localized content + accent + stats + sections
- all heavy UI composition is delegated to `ObjectivePageBase`

## 9) Frontend user journeys

### Journey A: Translate flow

1. user opens Translate screen
2. camera starts
3. frames sent to backend websocket
4. prediction labels returned
5. smoothing + auto-add + sentence builder
6. text/transcript rendered in UI

### Journey B: Two-way communication flow

1. deaf user signs -> prediction -> text in chat
2. hearing user replies via typed or voice input
3. app can speak messages using TTS
4. thread history maintained for both sides

### Journey C: Emergency flow

1. user configures contacts in Setup screen
2. triggers SOS from button or shake
3. optional location retrieval
4. message template generated
5. WhatsApp/SMS launch for contacts

## 10) Web vs mobile behavior

Mobile-focused differences:

- persistent floating SOS button
- compact nav/tabs and device camera usage
- shake detection active on supported hardware

Web-focused differences:

- global navbar + section scrolling
- larger layouts and split panes
- no physical shake trigger

## 11) Platform helper utility

`lib/utils/PlatformHelper.dart` centralizes feature capability checks:

- `isWeb`, `isMobile`, `isDesktop`
- `supportsShake`, `canSendSMS`, `hasGPS`

This keeps platform branching clean and avoids repeated checks across screens.

## 12) Frontend architecture summary for exam

You can write:

The frontend is a modular Flutter application with a service-driven architecture. `main.dart` initializes local storage and Supabase once, then routes users through splash and home flows. Feature screens are separated by responsibility: `TranslateScreen` for live ISL detection output handling, `TwoWayScreen` for bidirectional communication, `Signspage` for dictionary learning, `ISLAssistantScreen` for Gemini-based guidance, and emergency screens for SOS workflows. Shared components (`GlobalNavbar`, `SOSFloatingButton`, `AuthDialog`) provide cross-app consistency, while services (`backend_config`, `EmergencyService`, `LocationService`, `SupabaseService`) isolate backend communication, state sync, and platform-specific behavior.

## 13) Suggested frontend improvements

1. Extract some large screens into smaller feature widgets for maintainability.
2. Add provider/state-management layer for clearer business-state boundaries.
3. Add widget tests for core flows: translate session, emergency trigger, auth sync.
4. Move Gemini endpoint call behind secure backend proxy for key protection.
5. Add analytics hooks for inference latency and error-rate monitoring.

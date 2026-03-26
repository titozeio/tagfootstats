# Project Tasks: TagFootStats

## Phase 0: Setup & Configuration [x]
- [x] Create project structure
- [x] Define `AGENTS.md` (AI Protocol)
- [x] Configure CI/CD with GitHub Actions

## Phase 1: Requirements & Architecture [x]
- [x] Formalize Functional Specifications (`docs/specs/functional_specs.md`)
- [x] Design ERD (Firebase FireStore schema)
- [x] Define App Architecture (Clean Architecture)
- [x] Technical Design (`docs/architecture/technical_design.md`)

## Phase 2: Data Layer (Implementation) [x]
- [x] Initialize Firebase in Dart (`firebase_core`)
- [x] Define Domain Entities and Data Models (`json_serializable`)
- [x] Implement Firestore Repositories
- [x] Unit Tests for Data Layer

## Phase 3: Domain & Logic (State Management) [x]
- [x] Implement Match BLoC (Real-time scoring)
- [x] Implement Team/Player CRUD Use Cases
- [x] Unit Tests for Business Logic

## Phase 5: Administrative UI & CRUD (Administrative Management) [ ]
- [ ] Implement Team CRUD Screens
    - [ ] Own Team setup flow
    - [ ] General Teams list and editor
- [ ] Implement Player CRUD Screens
    - [ ] Player list (filtered by team)
    - [ ] Player editor
- [ ] Implement Tournament CRUD Screens
    - [ ] Tournament list (with LIVE status logic)
    - [ ] Tournament editor (Team association)
- [ ] Implement Match History & CRUD
    - [ ] Match list with summary cards
    - [ ] Match deletion and editing logic

## Phase 6: Home & Global Navigation [/]
- [/] Build Main Dashboard (Home) [/]
    - [x] "Own Team" check and redirect
    - [x] Last Match summary card
    - [x] Navigation menu with icon buttons
- [ ] Implement Global Navigation (AppRouter/BottomNavBar)

## Phase 7: Verification & Launch [ ]
- [ ] Integration Testing
- [ ] Final UI Polish (Animations & Feedback)
- [ ] Production Build & Deployment
- [ ] Beta Release (Android APK)

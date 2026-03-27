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

## Phase 5: Administrative UI & CRUD (Administrative Management) [x]

## Phase 6: Upgrades in the CRUD pages[]

- [x] The Home Screen in the desktop chrome version is humongous and has an uneeded scroll. Fix it to fit everything in the screen.
- [x] In Home screen, the last match should be clickable/tappable and take the user to that match´s screen.

## Phase 6.1: Upgrades in the Tousnaments screens[]

- [ ] If there´s a live tournament, the "LIVE" tag should blink a bit to call for attention.
- [ ] In the tournament edition screen, the "Add existing team" button color is hard to read, change it to a more visible color.
- [ ] In the tournament edition screen, apart form editing the params and teams of the tournaments, there should also be a list of the matches of the tournament. Each match can be selected (then taken to its corresponding match editing screen) or deleted (which would delete the match and all its related data, but there should be a confirmation popup before deleting it).
- [ ] In the tournament edition screen, below the list of matches there should be a selector to add existing matches to the tournament. And a button to add a new match on the fly (i would take to the match creation screen, and once created, add it automatically to the oturnament).

## Phase 6.2: Upgrades in the Teams screens[]

- [ ] In the Edit Team screen, the "manage players" button is hard to see, change its color.
- [ ] In the Edit Team Screen, teams should have some optional values, like "badge" or "short name". Add a way so the user can add an image as a badge for the team.
- [ ] In the Edit Team Screen, we should make it clear if that team is the user team. Maybe with a small icon or color.
- [ ] In the Teams screen, we should allow the user to change his team easily (with a selector or a button for each team "make it my team"). A user can only have one team, so When selecting a new team for the user, the previous one ceases to be its team.

## Phase 7: Home & Global Navigation [/]

- [/] Build Main Dashboard (Home) [/]
  - [x] "Own Team" check and redirect
  - [x] Last Match summary card
  - [x] Navigation menu with icon buttons
- [ ] Implement Global Navigation (AppRouter/BottomNavBar)

## Phase 8: Verification & Launch [ ]

- [ ] Integration Testing
- [ ] Final UI Polish (Animations & Feedback)
- [ ] Production Build & Deployment
- [ ] Beta Release (Android APK)

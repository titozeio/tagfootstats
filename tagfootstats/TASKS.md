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

## Phase 6: Upgrades in the CRUD pages [x]

- [x] The Home Screen in the desktop chrome version is humongous and has an uneeded scroll. Fix it to fit everything in the screen.
- [x] In Home screen, the last match should be clickable/tappable and take the user to that match´s screen.
- [x] The whole app should be in spanish by dafault. Change all existing texts and buttons, etc.

## Phase 6.1: Upgrades in the Tournaments screens [x]

- [x] If there´s a live tournament, the "LIVE" tag should blink a bit to call for attention.
- [x] In the tournament edition screen, the "Add existing team" button color is hard to read, change it to a more visible color.
- [x] In the tournament edition screen, apart form editing the params and teams of the tournaments, there should also be a list of the matches of the tournament. Each match can be selected (then taken to its corresponding match editing screen) or deleted (which would delete the match and all its related data, but there should be a confirmation popup before deleting it).
- [x] In the tournament edition screen, below the list of matches there should be a selector to add existing matches to the tournament. And a button to add a new match on the fly (i would take to the match creation screen, and once created, add it automatically to the oturnament).

## Phase 6.2: Upgrades in the Match Recording screen [x]

- [x] En el registro del partido no aparecen las jugadas que se han ido registrando. Añade una lista de las jugadas que se han ido registrando por orden cronológico (de menor a mayor minuto). Debería mostrar un nresumen tipo: minuto de la jugada, ficha del jugador (si se especificó), tipo de jugada (iataque defensa), jugada en sí (pase, carrera, sack, etc.), yardas ganadas/perdidas, y si fue exitosa o no,... toda la info, vaya.
- [x] En el registro del partido, cuando se está registrando una jugada, no se muestra el resultado parcial del partido (p.e. 14-7). Añádelo en algún sitio visible.
- [x] En el registro del partido, cuando se está registrando una jugada, debe poder selecccionarse el minuto en el que se produjo. El tiempo del marcador debe actualizarse con el minutaje más avanzaado de todas las jugadas registradas (se puedden registrar jugadas de forma desordenada, no hace falta que sea en orden cronológico).
- [x] Actua como un experto en tag football, revisa las posibles jugadas que se pueden registrar ahora mimso y los puntos que conceden, y cómo las registramos, y dame consejo por si necesitamos modificarlas, añadir parámetros, faltan tipos de jugadas, etc.

## Phase 6.2.1: Expert Tag Football Enhancements [x]

- [x] Añadir jugada de **SAFETY (2 puntos)** para la defensa.
- [x] Permitir elegir entre **1 punto (yarda 5)** o **2 puntos (yarda 10)** para los Puntos Extra (PAT).
- [x] Añadir selector de **Resultado de Pase** (Completo, Incompleto, Interceptado) para mejorar las estadísticas del QB.
- [x] Implementar el rastreo de **Down** (1ª, 2ª, 3ª o 4ª oportunidad) para dar contexto a cada jugada.
- [x] Permitir seleccionar **múltiples jugadores** en una jugada (ej. QB + Receptor en un pase).

## Phase 6.3: Upgrades in the New Match Screen [x]

- [x] If theres an open tournament, select by default that tournament .
- [x] Instead of "Nombre del oponente", use a selector to select the opponent team from the user's teams, AND give the option to add a new team on the fly.
- [x] The date and time selector is not visible due to the color, change it.
- [x] Dependiendo del tipo de torneo, mostrar "Jornada" (liga) o "fase" (copa).
- [x] Jornada debería ser un selector de números.
- [x] Fase debería ser un selector de fases(>Final, Seimifinal, Cuartos, Octavos, liguilla, y otros que habilitaría un campo de texto para añadir una jornada custom).

## Phase 6.4: Upgrades in the Teams screens[]

- [ ] In the Edit Team screen, the "manage players" button is hard to see, change its color.
- [ ] In the Edit Team Screen, teams should have some optional values, like "badge" or "short name". Add a way so the user can add an image as a badge for the team.
- [ ] In the Edit Team Screen, we should make it clear if that team is the user team. Maybe with a small icon or color.
- [ ] In the Teams screen, we should allow the user to change his team easily (with a selector or a button for each team "make it my team"). A user can only have one team, so When selecting a new team for the user, the previous one ceases to be its team.

## Phase 6.4: Upgrades in the Players screens[]

- [ ] In the Edit player screen, we should enable a way to upload a photo of the player, and using that photo in the player card.

## Phase 7: Home & Global Navigation [/]

- [/] Build Main Dashboard (Home) [/]
  - [x] "Own Team" check and redirect
  - [x] Last Match summary card
  - [x] Navigation menu with icon buttons
- [ ] Implement Global Navigation (AppRouter/BottomNavBar)

## Phase 8: Advanced stats [ ]

- [ ] Add a new button in the Home Screen: Advanced stats. This button should take the user to the advanced stats screen.
- [ ] In the advanced stats screen, we should show the advanced stats of the user's team: Act as an expert in tag football and decide what advanced stats to show.
- [ ] In the advanced stats screen, add abutton to be stats for the players of the user´s team. This should open a different table of stats for each player´s stats.Act as an expert in tag football and decide what advanced stats to show.

## Phase 9: Verification & Launch [ ]

- [ ] Integration Testing
- [ ] Final UI Polish (Animations & Feedback)
- [ ] Production Build & Deployment
- [ ] Beta Release (Android APK)

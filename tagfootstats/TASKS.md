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

## Phase 6.3.5: Fixing stuff [ ]

## Phase 6.3.5: Fixing stuff [x]

- [x] The log section of the matches is not working at all.

## Phase 6.4: Upgrades in the Teams screens [x]

- [x] In the Edit Team screen, the "manage players" button is hard to see, change its color.
- [x] In the Edit Team Screen, teams should have some optional values, like "badge" or "short name". Add a way so the user can add an image as a badge for the team.
- [x] In the Edit Team Screen, we should make it clear if that team is the user team. Maybe with a small icon or color.
- [x] In the Teams screen, we should allow the user to change his team easily (with a selector or a button for each team "make it my team"). A user can only have one team, so When selecting a new team for the user, the previous one ceases to be its team.

## Phase 6.5: Upgrades in the Players screens [x]

- [x] in the players list, the dorsal should be bigger and easy to see. Change its format or color.
- [x] In the Edit player screen, we should also track where they play: Offense, Defense or Both.
- [x] In the Edit player screen, the "back" button takes you to the teams list, but should take you to that team's players list.
- [x] In the Edit player screen, we should enable a way to upload a photo of the player, and using that photo in the player card.

## Phase 7: Home & Global Navigation [x]

- [x] Build Main Dashboard (Home)
- [x] Quick-access button to start recording a match.
- [x] Team stats summary (Wins, Losses, Points).
- [x] Implement Global Navigation (BottomNavigationBar with Home, Matches, Teams, Tournaments, Settings).

## Phase 8: Advanced stats [x]

- [x] Add a new button in the Home Screen: Advanced stats.
- [x] In the advanced stats screen, show team stats: Success Rate, YPP, Completion %, Play Mix.
- [x] In the advanced stats screen, show player stats: Individual Yards, Points, Ints, Sacks, Pulls/Tackles.

## Phase 8.1: UI/UX Correction & Professionalism [x]

- [x] Fix color contrast issues: High-contrast primary colors (Avoid dark blue on dark backgrounds).
- [x] Record Design System rules in a persistent document/skill.
- [x] Upgrade Player Stats Table: Sortable, professional layout, and more expert metrics.

## Phase 8.2: Expert Tag Football Metrics [x]

- [x] Implement Team Metrics: TD Percentage, Turnover Differential, Success Rate.
- [x] Implement Player Metrics: Share % (Involvement), Indiv Yards, Points.
- [x] Implement Defensive Metrics: Total Sacks, Interceptions.

## Phase 8.3: Several fixes and helpers [x]

- [x] In the "Estadísticas avanzadas" Screen: "Equipo" and "Jugadores", when selected are not readable because of the color.
- [x] In the "Estadísticas avanzadas" Screen: Make the grid of stats occupy the whole screen (in width).
- [x] Fill some fake stats so I can test properly: Add fake teams, fake players, fake matches with fake plays...
- [x] Add an easy way to clean up the stats (in a safe way, i.e. with a confirmation popup).

## Phase 9: Verification & Launch [x]

- [x] Integration Testing
- [x] Final UI Polish (Animations & Feedback)
- [x] Production Build & Deployment
- [x] Beta Release (Android APK)

## Phase 10: Post-Launch Features & Polish [x]

- [x] Add "Faltas" (Fouls) to the match recording plays. First, research how fouls work in Flag/Tag Football (e.g., penalty yards, loss of down) to implement them accurately.
- [x] Implement a modern, visually stunning post-match statistics report/view (similar to basketball box scores but cooler). Include an option to export/copy the stats to a plain text format.

## Phase 11: Areglando el desastre provocado por la IA [x]

 - [x] Arreglar el estropicio de que en lugar del nombre del oponente salga "Opp_1", "Opp2_".  
 - [x] Que se puedan eliminar partidos 
 - [x] En la home, si no hay ningún partido, que no aparezca ninguno. Ahora mismo aparece uno que no existe del equipo del usuario sin rival, sin jugadas... NO! Que no salga nada si no hay partido. 
 - [x] En la sección de estadísticas tampoco muestra el nombre de los rivales, aparece también "Opo_1", etc. 
 - [x] En la sección de estadísticas no se registran bien las estadísticas. Le está asiganando todas las  jugadas al equipo del usuario. 
 - [x] En la sección de estadísticas no se muestran todas las estadísticas. Debería mostrar para cada equipo todas las posibles jugadas que se pueden registrar durante un partido (pases, carreras, sacks, fumbles, faltas, touchdowns, no pat, 1pt, 2pt,  flag quitado, intercepción, batted, safety, falta,... todas, vaya). Y que las muestre bien. Tanto para cada equipo, como para cada jugador. Ahora mismo no hace nada bien.

## Phase 12: Gameplay Recording Overhaul [x]

 - [x] **Perspectiva única del equipo del usuario**: Todas las jugadas se registran desde el punto de vista del equipo del usuario. Jugadas ofensivas = puntos para el usuario; jugadas defensivas = el usuario defiende (puntos del rival se controlan vía scoringTeamId).
   - [x] `play_entry_form.dart`: Eliminar dropdown "JUGADOR RIVAL" del formulario de registro.
   - [x] `play_entry_form.dart`: En defensa, el toggle TOUCHDOWN registra TD del RIVAL (scoringTeamId=opponentId).
   - [x] `stats_aggregator.dart`: Cambiar `_resolveOffenseTeamRef` — `phase=defensa` ahora significa que el equipo del usuario realiza la jugada defensiva (offenseTeamRef = ownTeamId para jugadas defensivas).
 - [x] **Color coding de jugadas**: Ataque = color del equipo del usuario (azul si local, rojo si visitante). Defensa = color opuesto.
   - [x] `match_page.dart`: Simplificar `_isPlayLocal()` con nueva lógica de colores.
 - [x] **Estadísticas de pases COM/INC/INT**: Distinguir pases completos, incompletos e interceptados en stats.
   - [x] `stats_aggregator.dart`: Añadir contadores `passesComplete`, `passesIncomplete`, `passesIntercepted` a `TeamStatsAggregate` y `PlayerStatsAggregate`.
   - [x] `advanced_stats_page.dart`: Mostrar chips COM/INC/INT en stats de equipo y columnas en tabla de jugadores.
 - [x] **Nuevas jugadas defensivas**: Añadir "AVANCE MÁXIMO" y "FLAG FALLIDO" al panel de defensa.
   - [x] `play_entry_form.dart`: Añadir las dos nuevas acciones al grid de defensa.
   - [x] `stats_aggregator.dart`: Contabilizar las nuevas acciones en aggregates de equipo y jugador.
   - [x] `advanced_stats_page.dart`: Reflejar las nuevas métricas en la UI.
 - [x] **OT (Overtime)**: Checkbox "OT" en el selector de minuto. Internamente min=61+n; en la UI mostrar "OT".
   - [x] `play_entry_form.dart`: Añadir checkbox OT, deshabilitar slider cuando OT está activo.
   - [x] `match_page.dart`: Mostrar "OT" en lista de jugadas cuando minute >= 61. `_calculateTimeLeft` devuelve "OT".
 - [x] **Documentación**: Actualizar `functional_specs.md` y `technical_design.md` con los nuevos cambios.
 - [x] **Tests**: Actualizar y ampliar `stats_aggregator_test.dart` para cubrir los nuevos comportamientos.

## 1. Use Case Diagram
All interactions are managed through the Flutter application by the team's manager/coach.

```mermaid
useCaseDiagram
    actor "Manager / Coach" as user
    package "Team Management" {
        usecase "Manage Tournaments" as UC1
        usecase "Manage Teams & Players" as UC2
    }
    package "Match Recording (Real-time)" {
        usecase "Initialize Match" as UC3
        usecase "Record Play (Ataque/Defensa/Extra)" as UC4
        usecase "Real-time Scoreboard & Highlights" as UC5
    }
    package "Analytics" {
        usecase "Consult Stats" as UC6
    }
    user --> UC1
    user --> UC2
    user --> UC3
    user --> UC4
    user --> UC5
    user --> UC6
```

## 2. Data Model (ERD) - Firebase Firestore
The application will use Firebase Firestore as the primary database.

```mermaid
erDiagram
    TOURNAMENT ||--o{ MATCH : contains
    TOURNAMENT {
        string id
        string name
        date start_date
        date end_date
        string type
    }
    TEAM ||--o{ PLAYER : has
    TEAM {
        string id
        string name
        string logo_url
        boolean is_own_team
    }
    PLAYER {
        string id
        string team_id
        string first_name
        string last_name
        int dorsal
        date birth_date
        string email
        string phone
    }
    MATCH ||--o{ PLAY : records
    MATCH {
        string id
        string tournament_id
        datetime date_time
        string opponent_id
        string location_type
        int matchday
        string phase
        int home_score
        int away_score
    }
    PLAY {
        string id
        string match_id
        string phase
        int minute
        string action
        string outcome
        int points
        int yardas
        list involved_player_ids
    }
```

## 3. Class Diagram (Data & Domain)

```mermaid
classDiagram
    class Tournament {
        +String id
        +String name
        +DateTime startDate
        +DateTime endDate
        +TournamentType type
    }
    class Team {
        +String id
        +String name
        +String logoUrl
        +bool isOwnTeam
    }
    class Player {
        +String id
        +String teamId
        +String firstName
        +String lastName
        +int dorsal
    }
    class Match {
        +String id
        +String tournamentId
        +String opponentId
        +DateTime dateTime
        +int homeScore
        +int awayScore
    }
    class Play {
        +String id
        +String matchId
        +PlayPhase phase
        +int minute
        +String action
        +int points
        +List~String~ playerIds
    }
    
    class TournamentRepository {
        <<interface>>
        +getTournaments() Future
        +saveTournament(Tournament t) Future
    }
    class MatchBloc {
        +addPlay(Play p)
        +updateScore()
        +Stream state
    }

    Match "1" *-- "Many" Play
    Tournament "1" *-- "Many" Match
    Team "1" *-- "Many" Player
```

## 4. App Architecture
The app follows **Clean Architecture** principles to ensure maintainability and testability.

### 4.1 Layers
- **Core**: Common utilities, themes, constants.
- **Data Layer**: Repositories, Data Sources (Firebase), Models (JSON serialization).
- **Domain Layer**: Entities, Use Cases (Business logic).
- **Presentation Layer**: Widgets, Blocs/Providers (State Management), Pages.

### 4.2 State Management
- **Flutter BLoC**: For complex state management (Match Recording, Multi-layer stats).
- **Provider/Riverpod**: For simple state (Authentication, User profile).

## 5. UI/UX Style (NFL Aesthetic)
- **Primary Color**: Deep Blue (`#013369`) / Neutral Dark Grey (`#121212`).
- **Accent Color**: NFL Gold (`#D50A0A`) or White for high contrast.
- **Typography**: Bold, condensed sans-serif (e.g., *Roboto Condensed* or *Inter*).
- **Components**: Glassmorphism highlights, smooth transitions between play phases.

## 6. Maintenance Policy
As defined in [AGENTS.md](file:///d:/projects/tagfootstats/tagfootstats/AGENTS.md), these diagrams MUST be updated whenever the core data structure or logic changes. AI agents are responsible for ensuring zero drift between diagrams and code.

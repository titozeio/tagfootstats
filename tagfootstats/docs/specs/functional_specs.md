# Functional Specifications: TagFootStats

## 1. Overview
TagFootStats is a Flutter application designed to record, track, and consult statistics for a Tag Football team. It supports real-time data entry during matches and provides a premium, NFL-style visual experience.

## 2. Core Entities (CRUD)

### 2.1 Tournament
- **Name**: String (e.g., "Spanish Tag League 2026")
- **Start Date**: Date
- **End Date**: Date
- **Type**: Enum { Liga, Copa }

### 2.2 Team
- **Name**: String
- **Logo/Escudo**: Image (Path/URL)
- **Is Own Team**: Boolean (Only one team can be marked as the primary "own" team)

### 2.3 Player
- **Team**: Reference to Team (Defaults to "Own Team")
- **First Name**: String
- **Last Name**: String
- **Jersey Number (Dorsal)**: Integer
- **Optional Info**: Date of Birth, Email, Phone.

### 2.4 Match
- **Tournament**: Reference to Tournament
- **Date & Time**: DateTime
- **Opponent**: Reference to Team
- **Location Type**: Enum { Local, Visitante, Neutro }
- **Format**:
    - For **Liga**: Matchday (Jornada) (1, 2, 3...)
    - For **Copa**: Phase (Octavos, Cuartos, Final...)

## 3. Match Statistics Recording
Statistics are recorded in real-time or post-match. The interface updates the score and main stats dynamically.

### 3.1 Play Components
- **Phase**: Enum { Ataque, Defensa, Extra Point }
- **Minute**: Integer (Game clock)
- **Involved Players**: List of References to Player (Optional)

### 3.2 Action Details

| Phase           | Action       | Outcome           | Points/Effect                    |
| :-------------- | :----------- | :---------------- | :------------------------------- |
| **Ataque**      | Pase         | Completo (Yardas) | +6 pts if TD                     |
|                 |              | Incompleto        | -                                |
|                 |              | Interceptado      | Pick6 (+6 pts rival) or No Pick6 |
|                 | Carrera      | Yardas            | +6 pts if TD                     |
|                 | Recepción    | Completo (Yardas) | +6 pts if TD                     |
|                 |              | Incompleto        | -                                |
|                 | Sack         | Yardas (Loss)     | -                                |
|                 | Safety       | -                 | +2 pts to Opponent               |
|                 | Fumble       | Yardas (Loss)     | -                                |
|                 | Falta        | Yardas (Penalty)  | -                                |
| **Defensa**     | Flag Pull    | Yardas (Stop)     | -                                |
|                 | Intercepción | Yardas            | Pick6 (+6 pts) or No Pick6       |
|                 | Falta        | Yardas (Penalty)  | -                                |
| **Extra Point** | Pase         | Completo          | +1 or +2 pts                     |
|                 |              | Incompleto        | -                                |
|                 |              | Interceptado      | Pick2 (+2 pts rival) or No Pick2 |
|                 | Carrera      | Completo          | +1 or +2 pts                     |
|                 |              | Fallido           | -                                |

## 4. UI/UX Requirements
- **Real-time Scoreboard**: Visible at all times during match recording.
- **Dynamic Clock**: Updates based on the last recorded play's timestamp.
- **Highlights Panel**: Real-time display of top stats/players (NFL style).
- **Aesthetics**: Premium, clean, and accessible interface. Similar to NFL broadcast markers.
- **Responsiveness**: Optimized for Android (Mobile), with adaptive support for Desktop/Web.

## 5. Non-Functional Requirements
- **Offline Support**: (Optional but recommended) Ability to record stats without internet, syncing later to Firebase.
- **Accessibility**: Clear typography and high-contrast elements for quick reading during game action.

# Specification: Post-Match Statistics (Box Score)

## Overview
A "Premium" visual report of a finished match, summarizing both team and individual player performance. It should be shareable via plain text.

## Visual Design (Premium Aesthetics)
- **Header**: Scoreboard overlay with team logos, final score, and date.
- **Tabs/Sections**:
  - **Resumen**: Global team stats (Yards, TD, Ints, Sacks, Efficiency).
  - **Jugadores**: Detailed table or cards for individual stats.
- **Modern Layout**: Use glassmorphism, subtle gradients, and clear typography (Card-based layout).

## Metrics to Display

### Team Stats
- **Total Yards**: Passing + Rushing.
- **Efficiency**: Success Rate on 3rd/4th downs.
- **Turnovers**: Interceptions thrown + Fumbles lost.
- **Defense**: Sacks and Interceptions made.

### Player Stats (NFL Style)
- **Passing**: Completions/Attempts, Yards, TDs, INTs, Passer Rating.
- **Rushing/Receiving**: Carries/Receptions, Yards, TDs.
- **Defense**: Flag Pulls (Tackles), Sacks, INTs.

## Export to Plain Text
A button "Copiar al portapapeles" that generates a text like:
```text
PARTIDO: [Local] vs [Visitante]
RESULTADO: [Score]
FECHA: [Date]
-------------------------
ESTADÍSTICAS POR JUGADOR
[Nombre] #[Dorsal] ([Posición])
  PUNTOS: [X]
  YARDAS: [X]
  INTERCEPCIONES: [X]
  ...
```

## Navigation Flow
1. User clicks on a finished match from the "Partidos" list or Home dashboard.
2. A new "Resumen del Partido" button appears.
3. Tapping it opens the `MatchStatsPage`.

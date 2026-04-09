# Specification: Faltas (Fouls) System

## Overview
The "Faltas" system allows recording penalties during a match. Penalties in Tag Football vary in yardage and impact on the down (replay vs loss of down).

## Categories & Common Fouls

### Defensive Fouls (Normal: 5-10 yards)
- **Offside / Encroachment**: 5 yards.
- **Defensive Pass Interference**: Spot of the foul + Automatic First Down.
- **Illegal Contact / Holding**: 10 yards.
- **Roughing the Passer**: 15 yards + Automatic First Down.
- **Illegal Flag Pull**: 10 yards from spot of catch.

### Offensive Fouls (Normal: 5-10 yards)
- **False Start / Illegal Motion**: 5 yards.
- **Offensive Pass Interference**: 10 yards + Loss of Down.
- **Flag Guarding**: 10 yards + Loss of Down.
- **Charging / Illegal Contact**: 10 yards.
- **Blocking / Screening**: 10 yards.

## Data Model Requirements

The `Play` entity (or a specific `Foul` entity) needs to track:
- `foulType`: String (e.g., "Pass Interference")
- `penaltyYards`: Integer
- `isLossOfDown`: Boolean
- `isAutomaticFirstDown`: Boolean
- `teamId`: Reference to the team that committed the foul.
- `playerId`: Reference to the player (optional).

## UI Requirements in Match Recording
1. **New Action Button**: "Falta" added to the action selector.
2. **Foul Selection Flow**:
   - Select Team (Home/Away).
   - Select Foul Type (Preset list + "Otra").
   - Select Player (Optional).
   - Input Yards (Auto-filled based on type, but editable).
   - Toggle "Pérdida de Down" or "1st Down Automático".
3. **Log Appearance**:
   - Fouls should be clearly distinguished in the play log (e.g., yellow background or specific icon).
   - Display: "[Min X] FALTA: [Nombre Falta] - [Equipo] - [Yards] y [Efecto]".

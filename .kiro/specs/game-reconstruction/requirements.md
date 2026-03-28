# Game Reconstruction — Requirements

Spec ID: `game-reconstruction`
Privacy Zone: HYBRID
Execution Platform: Gander (goose-cli) + OpenRouter via goose-proxy
CSWR Anchor: GitHub issue #5, #19

## Requirements (EARS Notation)

### R1: Session Grouping

WHEN multiple screenshot metadata records exist
THE SYSTEM SHALL group them by game session using timestamp proximity and visual continuity signals.

[NEEDS CLARIFICATION: What timestamp window defines "same game session"? Marvel Snap games last ~3-5 minutes. 10-minute window?]

### R2: Turn Sequencing

WHEN screenshots within a session are grouped
THE SYSTEM SHALL order them by turn number extracted from metadata
AND resolve conflicts using timestamp ordering.

### R3: Board State Reconstruction

WHEN a turn sequence is established
THE SYSTEM SHALL reconstruct the board state per turn: cards at each location, cube count, energy, score.

### R4: Outcome Determination

WHEN a game session is fully reconstructed
THE SYSTEM SHALL determine the outcome: win, loss, snap, retreat
AND record the final cube delta.

### R5: Missing Turn Integrity

WHEN turns are missing from the sequence
THE SYSTEM SHALL flag the gap with a [MISSING_TURN] marker
AND SHALL NOT fabricate or interpolate missing game state.

### R6: Game Record Schema

WHEN a game is reconstructed
THE SYSTEM SHALL output a versioned JSON game record containing: game_id, player_deck, opponent_deck (anonymized), locations[], turns[], cube_state, outcome, source_screenshots[], confidence_scores, schema_version.

## Gander Execution

Recipe structure:
- Lead model: `bytedance-reason` (Seed OSS 36B for reasoning over structured metadata)
- Worker model: `llama3.1:8b` (local, for JSON assembly)
- MCP extensions: qdrant-shared-knowledge (store/query game records), filesystem
- Game records stored in Qdrant collection for semantic search and pattern analysis

## Validation Checklist

- [x] All requirements use EARS notation
- [ ] No [NEEDS CLARIFICATION] markers remain
- [x] Every requirement is testable
- [x] Privacy zone declared (HYBRID)
- [ ] Gander recipe identified
- [x] CSWR anchor defined

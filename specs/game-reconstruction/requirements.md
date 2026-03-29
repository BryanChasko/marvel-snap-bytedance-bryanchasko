# Game Reconstruction — Requirements

Spec ID: `game-reconstruction`
Privacy Zone: HYBRID
Execution Platform: Gander (goose-cli) + OpenRouter via goose-proxy
CSWR Anchor: GitHub issue #5, #19

## Requirements (EARS Notation)

### R1: Session Grouping

WHEN multiple screenshot metadata records exist
THE SYSTEM SHALL group them by game session using a 10-minute timestamp window from EXIF metadata.

Marvel Snap games last 3-5 minutes. A 10-minute window captures a full game with buffer for screenshots taken slightly after the match ends.

### R2: Turn Sequencing

WHEN screenshots within a session are grouped
THE SYSTEM SHALL order them by turn number extracted from metadata
AND resolve conflicts using EXIF timestamp ordering.

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
THE SYSTEM SHALL output a versioned JSON game record containing: game_id, player_deck, opponent_deck, locations[], turns[], cube_state, outcome, source_screenshots[], confidence_scores, schema_version.

### R7: Qdrant Storage

WHEN a game record is complete
THE SYSTEM SHALL store it in the snap-game-records Qdrant collection
AND this storage event marks the screenshot as "processing complete" per the ingestion spec.

## Gander Execution

Sub-recipe `snap-reconstruct.yaml` invoked by `snap-pipeline.yaml` orchestrator.

- Lead model: `bytedance-reason` (Seed OSS 36B for reasoning over structured metadata)
- Worker model: `llama3.1:8b` (local, for JSON assembly)
- MCP extensions: qdrant-shared-knowledge (store/query game records), filesystem

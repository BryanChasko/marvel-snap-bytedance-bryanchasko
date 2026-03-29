# Private Ingestion — Requirements

Spec ID: `private-ingestion`
Privacy Zone: LOCAL (no ByteDance models touch Google credentials or raw photos)
Execution Platform: Gander (goose-cli, local agent on aihost)
CSWR Anchor: GitHub issue #1, #13, #14

## Context

Google Photos Library API removed `photoslibrary.readonly` scope in March 2025. Background watchers that read a user's full library are no longer possible. Our approach:

1. **Bootstrap:** Google Takeout bulk export of existing screenshots to local staging
2. **Steady state:** Local folder watcher monitors a staging directory on aihost
3. **Backlog:** Drive API bridge utility for ongoing sync (future sprint)

## Requirements (EARS Notation)

### R1: Bulk Import

WHEN the user exports screenshots via Google Takeout
THE SYSTEM SHALL ingest all images from the export directory into the local staging folder
AND preserve original filenames and EXIF timestamps.

### R2: Local Folder Watcher

WHEN a new image file appears in the local staging directory
THE SYSTEM SHALL detect it within 60 seconds
AND queue it for the classification pipeline.

### R3: Local-Only Execution

WHEN the ingestion agent runs
THE SYSTEM SHALL execute entirely on the local machine via goose-cli
AND SHALL NOT send any data to external model providers.

### R4: Credential Isolation

WHEN any Google credentials are used (Takeout, future Drive bridge)
THE SYSTEM SHALL store them only in local .env files
AND SHALL NOT pass them to ByteDance models, OpenRouter, or any external service.

### R5: Staging Directory Safety

WHEN images are written to local staging
THE SYSTEM SHALL write them to a gitignored directory
AND SHALL NOT commit raw screenshots to the public repository.

### R6: Processing Complete Definition

WHEN a screenshot's game data has been ingested into Qdrant (snap-game-records collection)
THE SYSTEM SHALL mark the screenshot as processed.
WHEN a processed screenshot is visually noteworthy
THE SYSTEM SHALL copy it to an S3 highlights bucket before cleanup.

### R7: Cleanup After Processing

WHEN a screenshot is marked as processed AND is not flagged as noteworthy
THE SYSTEM SHALL delete it from local staging
AND log the cleanup with timestamp.

## Gander Execution

Sub-recipe `snap-ingest.yaml` invoked by the `snap-pipeline.yaml` orchestrator. Pattern follows the gander's existing sub-recipe architecture (e.g., ghostwriter-draft.yaml invoking sub-kerouac, sub-voss).

- Lead/worker: llama3.1:8b / llama3.1:8b (local only, no OpenRouter)
- MCP extensions: filesystem
- CSWR: attached via prompt-ledger.sh

## Backlog

- Drive API bridge utility for ongoing photo sync (future sprint)
- Google Photos Picker API integration if interactive selection is needed

## Validation Checklist

- [x] All requirements use EARS notation
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Every requirement is testable
- [x] Privacy zone declared (LOCAL)
- [x] Gander recipe identified (sub-recipe of orchestrator)
- [x] CSWR anchor defined

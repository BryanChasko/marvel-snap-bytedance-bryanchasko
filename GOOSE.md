# Marvel Snap Cybernetic Loop — Gander Context

## What This Project Is

automated pipeline: Marvel Snap screenshots → classification → game reconstruction → analysis → public artifacts

you play Marvel Snap, take screenshots, everything after that is automated

## Pipeline Flow

```
staging/raw/ → preprocess (crop, strip EXIF) → classify (bytedance-vision) → extract metadata → group by session → sequence turns → build game record → store to qdrant → publish
```

## Privacy Zones — Inviolable

| Zone | What Lives Here | Who Touches It |
|------|----------------|----------------|
| LOCAL | google creds, raw screenshots, EXIF data | local agents only (llama3.1:8b) |
| HYBRID | sanitized game screenshots (no EXIF, cropped) | bytedance models via goose-proxy |
| PUBLIC | anonymized game records, analysis | the world |

data flows one direction: local → hybrid → public. never reversed

raw screenshots NEVER leave local zone without preprocessing (EXIF strip + crop)

## Model Routing

all external model calls go through goose-proxy at localhost:4000

| Alias | Model | Use Case |
|-------|-------|----------|
| `bytedance-vision` | bytedance-seed/seed-2.0-mini | screenshot classification, image input support |
| `bytedance-reason` | bytedance-seed/seed-2.0-lite | game reconstruction, analysis reasoning |

daily cost cap: $0.01 — enforced by goose-proxy via valkey counter

local models (llama3.1:8b) handle all non-vision work: formatting, orchestration, file operations

## Qdrant Collections

| Collection | Contents |
|------------|----------|
| `snap-game-records` | structured GameRecord JSON (primary output) |
| `snap-analysis` | analysis results, matchup data |
| `snap-screenshots` | metadata for processed screenshots |

## Game Record Schema

contract: `specs/game-reconstruction/schema.json`

key types:
- `GameRecord` — top-level: game_id, outcome, locations[], turns[], cube_state, confidence_scores
- `TurnRecord` — per-turn: turn_number, energy, cards played, score, source_screenshot. `missing: true` for gaps
- `CardPlay` — card_name, location_index, energy_cost, power, confidence
- `CubeState` — snapped, final_value, snap_turn, snap_player

sample: `fixtures/sample_game_record.json`

## Fixtures

sample input/output JSON for every pipeline stage lives in `fixtures/`:

| File | Stage |
|------|-------|
| `sample_classification_snap.json` | bytedance-vision output (snap=true) |
| `sample_classification_not_snap.json` | bytedance-vision output (snap=false) |
| `sample_metadata_extraction.json` | extracted game metadata from one screenshot |
| `sample_session_group.json` | screenshots grouped into game sessions |
| `sample_game_record.json` | complete reconstructed game record |

use these for dry-run testing, format validation, recipe development

## Recipe Architecture

| Recipe | Lead Model | Worker | What It Does |
|--------|-----------|--------|-------------|
| `snap-ingest.yaml` | llama3.1:8b | llama3.1:8b | watch staging dir, queue new screenshots |
| `snap-classify.yaml` | bytedance-vision | llama3.1:8b | preprocess → classify → extract metadata |
| `snap-reconstruct.yaml` | bytedance-reason | llama3.1:8b | group → sequence → build game record → qdrant |
| `snap-pipeline.yaml` | qwen-reason | llama3.1:8b | orchestrator, runs sub-recipes in sequence |

## CSWR Requirements

every agent action requires a CSWR: `{ issue_id, spec_id, conversation_id }`

use `prompt-ledger.sh` from the gander repo at task boundaries

## Environment Setup

run `scripts/snap-setup.sh` to validate:
- staging directories exist
- qdrant reachable with expected collections
- valkey reachable
- goose-proxy health
- sample fixtures validate against schema

## What NOT to Do

- never send raw screenshots to external models without preprocessing
- never commit secrets, credentials, raw screenshots, or PII to this repo
- never fabricate missing game data — use [MISSING_TURN] markers, flag uncertainty
- never skip the goose-proxy for external model calls
- never log request/response bodies in cost tracking

## Spec Reference

all requirements use EARS notation (WHEN / THE SYSTEM SHALL) in `specs/`:

| Spec | Path |
|------|------|
| pipeline overview | `specs/marvel-snap-pipeline/design.md` |
| task list | `specs/marvel-snap-pipeline/tasks.md` |
| private ingestion | `specs/private-ingestion/requirements.md` |
| classification + metadata | `specs/classification-metadata/requirements.md` |
| game reconstruction | `specs/game-reconstruction/requirements.md` |
| vendor gateway | `specs/vendor-gateway/requirements.md` |

## Project Board

[Marvel Snap Cybernetic Loop](https://github.com/users/BryanChasko/projects/4) — all issues tracked here

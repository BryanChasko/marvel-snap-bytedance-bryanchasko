# Marvel Snap Cybernetic Loop — Tasks

Parseable by `generate-task-issues.py --tasks-file specs/marvel-snap-pipeline/tasks.md --repo BryanChasko/marvel-snap-bytedance-bryanchasko`

## Task: Add ByteDance models to goose-proxy MODEL_MAP
Agent: myrren-openrouter-mapper
Depends on: none
Branch: feat/bytedance-model-map
- Verify the canonical `bytedance-vision` alias target in goose-proxy.py
- Verify the canonical `bytedance-reason` alias target in goose-proxy.py
- Sync Marvel Snap docs/specs to the live alias contract instead of stale hardcoded provider IDs

## Task: Create snap-ingest.yaml sub-recipe
Agent: ellow-gander-mechanic
Depends on: none
Branch: feat/snap-ingest-recipe
- Recipe uses mistral-nemo:latest lead and worker for the local-first tuning baseline
- Mounts filesystem MCP extension
- Watches local staging directory for new images
- Attaches CSWR via prompt-ledger.sh
- Queues detected images for classification pipeline

## Task: Implement local screenshot preprocessing
Agent: ellow-gander-mechanic
Depends on: none
Branch: feat/snap-preprocessing
- Crop game UI region from full screenshot
- Strip EXIF metadata (GPS, device info)
- Preserve EXIF timestamp for session grouping
- Output sanitized image ready for external model

## Task: Create snap-classify.yaml sub-recipe
Agent: ellow-gander-mechanic
Depends on: Add ByteDance models to goose-proxy MODEL_MAP
Branch: feat/snap-classify-recipe
- Lead model: bytedance-vision, local reviewer: mistral-nemo:latest
- Routes through goose-proxy
- Classifies images as snap/not-snap with confidence score
- Threshold 0.7 configurable via env var
- Attaches CSWR via prompt-ledger.sh

## Task: Implement Snap metadata extraction via UI-TARS
Agent: ellow-gander-mechanic
Depends on: Create snap-classify.yaml sub-recipe
Branch: feat/snap-metadata-extraction
- Extract cards played, locations, turn number, energy, score, opponent
- Output structured JSON conforming to game record schema
- Include per-field confidence scores
- Flag uncertain fields, never fabricate

## Task: Define game record JSON schema
Agent: stratia-gander-arch
Depends on: none
Branch: feat/game-record-schema
- Versioned JSON schema with: game_id, player_deck, opponent_deck, locations[], turns[], cube_state, outcome, source_screenshots[], confidence_scores, schema_version
- Validate with JSON Schema
- Store schema in specs/game-reconstruction/schema.json

## Task: Add PII payload filter to goose-proxy
Agent: kade-vox-gander-security
Depends on: none
Branch: feat/proxy-pii-filter
- Reject outbound payloads matching PII patterns (email, phone, address, account ID)
- Log rejections with CSWR metadata
- Return clear error to calling agent

## Task: Add cost tracking and $0.01/day cap to goose-proxy
Agent: ellow-gander-mechanic
Depends on: none
Branch: feat/proxy-cost-cap
- Track cumulative daily cost per model via Valkey
- Reset counter at midnight
- Reject calls when daily cap exceeded
- Cap configurable via SNAP_DAILY_COST_CAP env var, default $0.01

## Task: Create Qdrant collections for snap data
Agent: ellow-gander-mechanic
Depends on: none
Branch: feat/snap-qdrant-collections
- Create snap-game-records collection
- Create snap-analysis collection
- Create snap-screenshots collection
- Add an idempotent local bootstrap path for the collections
- Verify via qdrant health check and collection existence check

## Task: Create snap-reconstruct.yaml sub-recipe
Agent: ellow-gander-mechanic
Depends on: Define game record JSON schema, Create Qdrant collections for snap data
Branch: feat/snap-reconstruct-recipe
- Lead model: bytedance-reason, local reviewer: mistral-nemo:latest
- Groups screenshots by 10-minute EXIF timestamp window
- Reconstructs turn-by-turn board state
- Flags missing turns with [MISSING_TURN] marker
- Stores completed game records in snap-game-records Qdrant collection
- Attaches CSWR via prompt-ledger.sh

## Task: Create snap-pipeline.yaml orchestrator recipe
Agent: stratia-gander-arch
Depends on: Create snap-ingest.yaml sub-recipe, Create snap-classify.yaml sub-recipe, Create snap-reconstruct.yaml sub-recipe
Branch: feat/snap-pipeline-orchestrator
- Orchestrator invokes sub-recipes in sequence: ingest → classify → reconstruct
- Passes CSWR through the chain
- Lead model: mistral-nemo:latest, worker: mistral-nemo:latest during the local-first tuning cycle
- Mounts all MCP extensions needed by sub-recipes

## Task: Wire CSWR into all snap recipes
Agent: ellow-gander-mechanic
Depends on: Create snap-pipeline.yaml orchestrator recipe
Branch: feat/snap-cswr-wiring
- All snap recipes call prompt-ledger.sh with --agent, --cswr, --action, --summary
- Steering rejects tool calls without CSWR
- Verify ledger entries written to ~/.agentic/prompt-ledger/

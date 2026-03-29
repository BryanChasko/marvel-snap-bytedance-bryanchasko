# Marvel Snap Cybernetic Loop — Tasks

Parseable by `generate-task-issues.py --tasks-file specs/marvel-snap-pipeline/tasks.md --repo BryanChasko/marvel-snap-bytedance-bryanchasko`

## Task: Add ByteDance models to goose-proxy MODEL_MAP
Agent: myrren-openrouter-mapper
Depends on: none
Branch: feat/bytedance-model-map
- Add `bytedance-vision` alias mapping to `bytedance/ui-tars-1.5-7b` in goose-proxy.py
- Add `bytedance-reason` alias mapping to `bytedance/seed-oss-36b-instruct` in goose-proxy.py
- Verify routing via proxy health check

## Task: Create snap-ingest.yaml sub-recipe
Agent: ellow-gander-mechanic
Depends on: none
Branch: feat/snap-ingest-recipe
- Recipe uses llama3.1:8b lead and worker (local only)
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
- Lead model: bytedance-vision, worker: llama3.1:8b
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
- Verify via qdrant health check

## Task: Create snap-reconstruct.yaml sub-recipe
Agent: ellow-gander-mechanic
Depends on: Define game record JSON schema, Create Qdrant collections for snap data
Branch: feat/snap-reconstruct-recipe
- Lead model: bytedance-reason, worker: llama3.1:8b
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
- Lead model: qwen-reason, worker: llama3.1:8b
- Mounts all MCP extensions needed by sub-recipes

## Task: Wire CSWR into all snap recipes
Agent: ellow-gander-mechanic
Depends on: Create snap-pipeline.yaml orchestrator recipe
Branch: feat/snap-cswr-wiring
- All snap recipes call prompt-ledger.sh with --agent, --cswr, --action, --summary
- Steering rejects tool calls without CSWR
- Verify ledger entries written to ~/.agentic/prompt-ledger/

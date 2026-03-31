## Marvel Snap Cybernetic Loop — Project Context

this project builds an automated pipeline: Marvel Snap screenshots → classification → game reconstruction → analysis → public artifacts

implementation language: Rust. build with `cargo build --release`, binary name: `snap-pipeline`

### model guidance for this project

use qwen-reason as your lead model for orchestration, planning, architecture decisions. say `use qwen-reason` at session start

use llama3.1:8b as worker for file operations, formatting, simple tasks

do NOT use llama3.1:8b for orchestration or complex reasoning — it will hallucinate the architecture

for pipeline recipe runs:
- snap-ingest runs on llama3.1:8b (local, free)
- snap-classify runs on bytedance-vision (bytedance-seed/seed-2.0-mini via openrouter)
- snap-reconstruct runs on bytedance-reason (bytedance-seed/seed-2.0-lite via openrouter)
- snap-pipeline orchestrator runs on qwen-reason
- daily cost cap: $0.01 enforced via valkey key "snap:daily_cost"

### privacy zones — inviolable

- LOCAL: google creds, raw screenshots, EXIF data → local models only
- HYBRID: sanitized screenshots (EXIF stripped, cropped) → bytedance models via goose-proxy
- PUBLIC: anonymized game records, analysis → the world

data flows one direction: local → hybrid → public. never reversed

### first steps

- run `scripts/snap-setup.sh` to verify infrastructure
- read `specs/marvel-snap-pipeline/tasks.md` for the task list
- read `specs/game-reconstruction/schema.json` for the data contract
- check `fixtures/` for sample input/output JSON at each pipeline stage
- check the project board: https://github.com/users/BryanChasko/projects/4

### what not to do

- never send raw screenshots to external models without preprocessing
- never commit secrets, credentials, raw screenshots, or PII
- never fabricate missing game data — flag with [MISSING_TURN]
- never skip goose-proxy for external model calls

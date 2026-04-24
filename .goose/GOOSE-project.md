## Marvel Snap Cybernetic Loop — Project Context

this project builds an automated pipeline: Marvel Snap screenshots → classification → game reconstruction → analysis → public artifacts

implementation language: Rust. build with `cargo build --release`, binary name: `snap-pipeline`

### model guidance for this project

default to `mistral-nemo:latest` for this project during the current tuning cycle

use `mistral-nemo:latest` for repo review, planning, file operations, and issue-scoped implementation slices unless a task explicitly proves it needs a different model

do not switch to OpenRouter by default. first prove what recipe shape, task framing, and persona guidance can achieve on the local baseline

`llama3.1:8b` and `llama3.2:3b` are optional cheaper lanes for narrow tasks only. they are not the main project driver until they earn that role on this repo

for pipeline recipe runs:
- snap-ingest baseline runs on mistral-nemo:latest
- snap-classify uses bytedance-vision for external vision work and mistral-nemo:latest for local prep/review
- snap-reconstruct uses bytedance-reason for external reasoning work and mistral-nemo:latest for local prep/review
- snap-pipeline baseline orchestration runs on mistral-nemo:latest during local-first tuning
- daily cost cap: $0.01 enforced via valkey key "snap:daily_cost"

before trusting repo docs about external model identity, verify the live gander proxy aliases. runtime alias drift is tracked in issue #23.

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
- prefer bounded issue-backed tasks over open-ended repo review
- use Jaeger/OTel traces when Goose stalls, loops, or gives weak repo analysis
- for the current alignment slice, use issue `#37`; for the paired gander runtime/tuning slice, use issue `BryanChasko/goosecli-heraldstack-gander#78`

### first implementation slice

- start with issue `#25` for local screenshot preprocessing
- keep the first run local-only: no bytedance calls, no OpenRouter, no proxy routing work
- do not broad-review the repo again; implement only the bounded issue acceptance criteria
- use `.goose/extensions/issue-implementation.yaml` for issue `#25`
- use `.goose/extensions/docs.yaml` only when external docs lookup is actually needed
- use `.goose/extensions/pipeline.yaml` or `.goose/extensions/full.yaml` only when the task truly needs qdrant or valkey
- defer issue `#23` until after the first local-only implementation slice is complete
- use `.goose/issue-25-first-run.md` as the handoff contract for the first bounded Goose run
- record the run against `BryanChasko/goosecli-heraldstack-gander#78` with a trace reference and failure-mode notes

### what not to do

- never send raw screenshots to external models without preprocessing
- never commit secrets, credentials, raw screenshots, or PII
- never fabricate missing game data — flag with [MISSING_TURN]
- never skip goose-proxy for external model calls

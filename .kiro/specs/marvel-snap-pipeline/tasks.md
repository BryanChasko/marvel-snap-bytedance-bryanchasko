# Marvel Snap Cybernetic Loop — Tasks

Derived from design.md and individual spec requirements.
Tasks trace to requirements via spec_id and issue_id.

## Sprint 1: Foundation

These tasks unblock everything else.

### T1: Add ByteDance models to goose-proxy MODEL_MAP
Spec: vendor-gateway R5 | Issue: #16
Add `bytedance-vision` and `bytedance-reason` aliases to goose-proxy.py in goosecli-heraldstack-gander.
Status: [ ] not started

### T2: Create snap-ingest.yaml recipe
Spec: private-ingestion R1, R2 | Issue: #13
Goose recipe for Google Photos watcher. Local-only, llama3.1:8b, filesystem MCP. CSWR via prompt-ledger.sh.
Status: [ ] not started

### T3: Implement local preprocessing script
Spec: classification-metadata R1 | Issue: #15
Crop game UI, strip EXIF, blur PII. Runs locally before any external call.
Status: [ ] not started

### T4: Create snap-classify.yaml recipe
Spec: classification-metadata R2, R6 | Issue: #17
Goose recipe with lead: bytedance-vision, worker: llama3.1:8b. Routes through goose-proxy.
Status: [ ] not started

### T5: Define game record JSON schema
Spec: game-reconstruction R6 | Issue: #19
Versioned schema for game records. Validate with JSON Schema.
Status: [ ] not started

### T6: Add PII payload filter to goose-proxy
Spec: vendor-gateway R2 | Issue: #16
Reject outbound payloads matching PII patterns. Log rejections with CSWR.
Status: [ ] not started

### T7: Add cost tracking to goose-proxy
Spec: vendor-gateway R3 | Issue: #16
Track cumulative daily cost per model. Enforce configurable cap. Use Valkey for state.
Status: [ ] not started

### T8: Implement Google Photos deletion with dry-run
Spec: private-ingestion R3, R4 | Issue: #14
API-based deletion after processing. Dry-run mode. Confirmation logging.
Status: [ ] not started

### T9: Create Qdrant collections for snap data
Spec: design.md Qdrant Collections | Issue: #5
Create snap-game-records, snap-analysis, snap-screenshots collections.
Status: [ ] not started

### T10: Wire CSWR into snap recipes
Spec: CSWR enforcement | Issue: #20, #21
All snap recipes attach CSWR metadata via prompt-ledger.sh. Steering rejects tool calls without CSWR.
Status: [ ] not started

## Sprint 2: Pipeline Core

### T11: Create snap-reconstruct.yaml recipe
Spec: game-reconstruction R1-R5 | Issue: #5
Lead: bytedance-reason, worker: llama3.1:8b. Qdrant for storage.

### T12: Create snap-analyze.yaml recipe
Spec: (analysis spec TBD) | Issue: #4
Cube efficiency, retreat timing, deck performance.

### T13: Create snap-pipeline.yaml orchestrator
Spec: design.md Recipe Architecture
Orchestrator that invokes sub-recipes in sequence with CSWR passthrough.

### T14: Metadata extraction via UI-TARS
Spec: classification-metadata R3 | Issue: #18
Extract cards, locations, turn, energy, score from sanitized screenshots.

### T15: Cedar policy extensions
Spec: vendor-gateway, Constitution Article VI
Extend Cedar policies for payload filtering and privacy zone enforcement.

## Backlog

### T16: snap-publish.yaml recipe (Layer 5)
### T17: Website dashboard integration (Layer 6)
### T18: Continuous improvement feedback loop (Layer 7)
### T19: Blog article on builder.aws.com (Layer 8)
### T20: Seedance 1.5 Pro video generation (when out of alpha)
### T21: Marvel API integration
### T22: Discord/Twitch integration
### T23: CSWR GitHub integration — branches/PRs carry CSWR (Issue: #22)

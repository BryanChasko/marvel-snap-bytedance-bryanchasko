# Marvel Snap Cybernetic Loop — Design (Pipeline Overview)

Architect: Stratia (she/her), stratia-gander-arch
Workflow: Design-First (Bryan provided the cybernetic loop architecture; requirements derived from it)

This is the umbrella design. Individual layer specs live in `specs/`.

## Execution Substrate

This pipeline runs on the gander (goose-cli) with coordination from the haunting (kiro-cli).

Existing gander infrastructure we leverage:
- `goose-proxy.py` — heuristic model dispatcher (add ByteDance models to MODEL_MAP)
- `prompt-ledger.sh` — CSWR prompt logging (already built)
- `generate-task-issues.py` — spec-to-GitHub-issue automation (already built)
- `build-cedar-context.py` — Cedar policy evaluation from git diffs (already built)
- Cedar policies — no-secrets-in-commits, branch-naming, required-reviews (already built)
- Qdrant — vector store at localhost:6333 (store game records, semantic search)
- Valkey — Redis-compatible cache at localhost:6379 (session state, cost tracking)
- Docker hardening — cap_drop, no-new-privileges, resource limits (already configured)
- MCP launchers — vision-server, filesystem, github, context7, qdrant (already built)
- Lead/worker model splitting — expensive model plans, cheap model executes (native goose feature)

Reference: https://github.com/BryanChasko/goosecli-heraldstack-gander

## CSWR — Conversation-Scoped Work Reference

The traceability spine. Every agent action anchored to a CSWR before it does anything.
Reference implementation: `scripts/prompt-ledger.sh` in the gander repo.

CSWR = { issue_id, spec_id, conversation_id }

## Privacy Model

Not a privacy architecture. Just: don't give ByteDance your Google credentials.

- LOCAL zone: Google credentials, raw screenshots. Goose-cli local agents only.
- HYBRID zone: Sanitized game screenshots sent to ByteDance models via OpenRouter.
- PUBLIC zone: Anonymized game records, analysis, website artifacts.

Data flows one direction: local → hybrid → public.

## Recipe Architecture

Each pipeline layer is a sub-recipe invoked by `snap-pipeline.yaml` orchestrator:

| Layer | Sub-recipe | Lead Model | Worker Model | MCP Extensions |
|-------|-----------|-----------|-------------|----------------|
| 1: Ingestion | `snap-ingest.yaml` | llama3.1:8b | llama3.1:8b | filesystem |
| 2: Classification | `snap-classify.yaml` | bytedance-vision | llama3.1:8b | filesystem, qdrant |
| 3: Reconstruction | `snap-reconstruct.yaml` | bytedance-reason | llama3.1:8b | qdrant, filesystem |
| 4: Analysis | `snap-analyze.yaml` | bytedance-reason | llama3.1:8b | qdrant |
| 5: Artifacts | `snap-publish.yaml` | llama3.1:8b | llama3.1:8b | github, filesystem |
| Orchestrator | `snap-pipeline.yaml` | qwen-reason | llama3.1:8b | all |

## Model Routing (goose-proxy.py additions)

| Alias | Provider | Model ID |
|-------|----------|----------|
| `bytedance-vision` | OpenRouter | `bytedance/ui-tars-1.5-7b` |
| `bytedance-reason` | OpenRouter | `bytedance/seed-oss-36b-instruct` |

## Qdrant Collections

| Collection | Contents |
|------------|----------|
| `snap-game-records` | Structured JSON game records |
| `snap-analysis` | Analysis results, matchup data |
| `snap-screenshots` | Metadata for processed screenshots |

# Marvel Snap Cybernetic Loop

![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)
![Spec Driven](https://img.shields.io/badge/methodology-spec--driven-blue?style=flat-square)
![ByteDance](https://img.shields.io/badge/models-ByteDance-purple?style=flat-square)
![OpenRouter](https://img.shields.io/badge/provider-OpenRouter-blue?style=flat-square)
![Ollama](https://img.shields.io/badge/local-Ollama-orange?style=flat-square)
![GooseCLI](https://img.shields.io/badge/runtime-GooseCLI-red?style=flat-square)
![HeraldStack](https://img.shields.io/badge/platform-HeraldStack-black?style=flat-square)

A fully automated, privacy-preserving pipeline that ingests Marvel Snap screenshots, reconstructs games, analyzes play patterns, and publishes curated public artifacts.

Built by [Bryan Chasko](https://bryanchasko.com) and the [HeraldStack](https://github.com/BryanChasko) multi-platform agent architecture.

---

## What This Does

```
Screenshots → Classification → Metadata → Game Records → Analysis → Public Artifacts
```

You play Marvel Snap. You take screenshots. Everything after that is automated.

The pipeline classifies screenshots, extracts game state (cards, locations, turns, cubes), reconstructs full matches, computes competitive analytics, and publishes anonymized results to your website and GitHub.

## Architecture

```mermaid
graph TD
    A[Screenshots] --> B[Local Staging]
    B --> C{Snap?}
    C -->|Yes| D[bytedance-vision alias]
    C -->|No| E[Archive]
    D --> F[Metadata JSON]
    F --> G[bytedance-reason alias]
    G --> H[Game Record]
    H --> I[Qdrant]
    I --> J[Analysis Engine]
    J --> K[Public Artifacts]
    K --> L[bryanchasko.com]
    K --> M[GitHub]

    style A fill:#1a1a2e,stroke:#e94560,color:#eee
    style D fill:#533483,stroke:#e94560,color:#eee
    style G fill:#533483,stroke:#e94560,color:#eee
    style I fill:#16213e,stroke:#0f3460,color:#eee
    style L fill:#0f3460,stroke:#e94560,color:#eee
```

## Privacy Model

Not a privacy architecture. Just: don't give ByteDance your Google credentials.

| Zone | What Lives Here | Who Touches It |
|------|----------------|----------------|
| **Local** | Google creds, raw screenshots | Goose-cli local agents only |
| **Hybrid** | Sanitized game screenshots | ByteDance models via OpenRouter |
| **Public** | Anonymized game records, analysis | The world |

Data flows one direction: local → hybrid → public. Never reversed.

## ByteDance Models (via OpenRouter)

Runtime contract is alias-based. The canonical mapping lives in the gander proxy `MODEL_MAP`, not this repo.

| Alias | Current gander proxy target | Use Case | Cost |
|-------|-----------------------------|----------|------|
| `bytedance-vision` | `bytedance-seed/seed-2.0-mini` | Screenshot classification, game UI recognition | runtime/provider dependent |
| `bytedance-reason` | `bytedance-seed/seed-2.0-lite` | Game reconstruction, analysis reasoning | runtime/provider dependent |

Daily cost cap: $0.01. That's ~50-100 classifications per day.

## Pipeline Layers

| Layer | Recipe | What It Does |
|-------|--------|--------------|
| 1. Ingestion | `snap-ingest.yaml` | Watch local folder, queue new screenshots |
| 2. Classification | `snap-classify.yaml` | Is this Marvel Snap? (via `bytedance-vision`) |
| 3. Reconstruction | `snap-reconstruct.yaml` | Build turn-by-turn game record (via `bytedance-reason`) |
| 4. Analysis | `snap-analyze.yaml` | Cube efficiency, deck stats, misplays |
| 5. Artifacts | `snap-publish.yaml` | Generate public-safe content, open PRs |
| Orchestrator | `snap-pipeline.yaml` | Run all layers in sequence with CSWR |

## Spec-Driven Development

This project uses spec-driven development. Specs are the source of truth. Code serves specs.

```
specs/
  SPEC-INDEX.md                    # Map of all specs
  marvel-snap-pipeline/
    design.md                      # Architecture (Design-First)
    tasks.md                       # Executable tasks (generate-task-issues.py format)
  private-ingestion/
    requirements.md                # EARS notation requirements
  classification-metadata/
    requirements.md
  game-reconstruction/
    requirements.md
  vendor-gateway/
    requirements.md
```

Requirements use [EARS notation](https://kiro.dev/docs/specs/feature-specs/) (WHEN/THE SYSTEM SHALL) for testability.

## CSWR — Conversation-Scoped Work Reference

Every agent action is anchored to a CSWR before it does anything. The CSWR ties conversations to GitHub issues, specs, and sessions.

```
CSWR = { issue_id, spec_id, conversation_id }
```

Implemented via [prompt-ledger.sh](https://github.com/BryanChasko/goosecli-heraldstack-gander/blob/main/scripts/prompt-ledger.sh) in the gander runtime.

## Execution Platform

Runs on the [gander](https://github.com/BryanChasko/goosecli-heraldstack-gander) — the goose-cli collective of the HeraldStack.

Existing infrastructure leveraged:
- **goose-proxy.py** — heuristic model dispatcher
- **Qdrant** — vector store for game records and semantic search
- **Valkey** — Redis-compatible cache for cost tracking
- **Cedar policies** — governance (no-secrets, branch-naming)
- **Docker hardening** — cap_drop, no-new-privileges, resource limits
- **38+ MCP launchers** — filesystem, GitHub, vision-server, Qdrant, AWS

## Prompt-Ready Baseline

Before the first serious Goose prompt:
- run `scripts/snap-setup.sh`
- if the three snap collections are missing, run `scripts/bootstrap-qdrant-collections.sh`
- treat gander `goose-proxy.py` as the source of truth for alias resolution

## Project Governance

- [CONSTITUTION.md](CONSTITUTION.md) — 8 immutable architectural principles
- [SECURITY.md](SECURITY.md) — public repo rules
- [specs/SPEC-INDEX.md](specs/SPEC-INDEX.md) — spec map and validation checklists

## The Team

Built by the HeraldStack haunting:

| Agent | Role |
|-------|------|
| Harald (he/him) | Anchor, coordination |
| Stratia (she/her) | Architect, recipe design |
| Ellow | GooseCLI implementation |
| Myrren | OpenRouter model routing |
| Kade-Vox | Security |
| Ralph Wiggum | QA validation |

## Links

- [bryanchasko.com](https://bryanchasko.com) — Website (game dashboard target)
- [builder.aws.com/community/@bryanchasko](https://builder.aws.com/community/@bryanchasko) — Blog
- [goosecli-heraldstack-gander](https://github.com/BryanChasko/goosecli-heraldstack-gander) — Gander runtime
- [OpenRouter ByteDance models](https://openrouter.ai/bytedance) — Model catalog

## License

MIT

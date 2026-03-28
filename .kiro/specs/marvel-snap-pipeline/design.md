# Marvel Snap Cybernetic Loop — Design

Architect: Stratia (she/her), stratia-gander-arch

This document describes the architecture of the Marvel Snap Cybernetic Loop — a privacy-preserving pipeline that ingests screenshots, reconstructs games, analyzes play patterns, and publishes curated public artifacts.

## CSWR — Conversation-Scoped Work Reference

The traceability spine of the entire system. Every agent and subagent must attach to a CSWR before doing anything.

A CSWR is:
- `issue_id` or `todo_id` or `rock_id` — the work item
- `spec_id` (optional, recommended) — the spec driving the work
- `conversation_id` — unique per user session

No action without CSWR. This is enforced at the steering layer.

### CSWR Infrastructure Layers

```
┌─────────────────────────────────────────────────────┐
│  Layer 0: Prompt Ledger                              │
│  Stores every prompt (including subagent prompts)    │
│  with CSWR metadata attached.                        │
├─────────────────────────────────────────────────────┤
│  Layer 1: Steering                                   │
│  Enforces: "No action without CSWR."                 │
│  Agent CLI requires CSWR before any tool call.       │
├─────────────────────────────────────────────────────┤
│  Layer 2: Knowledge Bases                            │
│  Specs, docs, semantic search — all indexed by       │
│  spec_id and issue_id.                               │
├─────────────────────────────────────────────────────┤
│  Layer 3: Live Context                               │
│  Runtime signals, ephemeral data, PR diffs,          │
│  CI results.                                         │
├─────────────────────────────────────────────────────┤
│  Layer 4: GitHub Integration                         │
│  CSWR becomes a branch, PR, or issue.                │
│  All git operations carry CSWR in commit metadata.   │
└─────────────────────────────────────────────────────┘
```

### CSWR in this project

For the Marvel Snap pipeline, the CSWR anchors to:
- GitHub issues (#1-#19 and growing) as `issue_id`
- `.kiro/specs/marvel-snap-pipeline/` as `spec_id`
- Each kiro-cli session as `conversation_id`

## Privacy Boundaries

```
┌─────────────────────────────────────────────────────┐
│                   PRIVATE ZONE                       │
│  Google Photos credentials, raw screenshots,         │
│  personal metadata, account tokens                   │
│                                                      │
│  Runs: LOCAL ONLY via goosecli                       │
│  Models: Local models only (no vendor calls)         │
│  Pipeline Layer: 1 (Ingestion)                       │
└─────────────────────────────────────────────────────┘
         │ sanitized images (cropped, anonymized)
         ▼
┌─────────────────────────────────────────────────────┐
│                   HYBRID ZONE                        │
│  Pre-processed screenshots, cropped game UI,         │
│  no PII, no account data                             │
│                                                      │
│  Runs: Local + Lambda + OpenRouter                   │
│  Models: UI-TARS 1.5 7B, Seed OSS 36B               │
│  Pipeline Layers: 2-4 (Classification, Recon, Analysis)│
└─────────────────────────────────────────────────────┘
         │ structured JSON game records
         ▼
┌─────────────────────────────────────────────────────┐
│                   PUBLIC ZONE                        │
│  Anonymized game records, analysis, visualizations,  │
│  blog content, GitHub artifacts                      │
│                                                      │
│  Runs: Lambda + static site                          │
│  Pipeline Layers: 5-8 (Artifacts, Website, Loop, Narrative)│
└─────────────────────────────────────────────────────┘
```

## Pipeline Layer Architecture

### Layer 1: Private Ingestion (Google Photos → Local Staging)

Local watcher monitors Google Photos for new images. Copies to private staging on aihost. Deletes originals from Google Photos after copy. No external models touch this layer.

Components:
- Google Photos API client (local, OAuth tokens in .env)
- File watcher / cron trigger
- Local staging directory (gitignored)
- Deletion confirmation before removing from Google Photos

Runtime: Local goosecli agent

### Layer 2: Classification & Metadata (Local + Vendor)

Determines if screenshot is Marvel Snap. Extracts game state metadata.

Hybrid model strategy:
- Local models handle sensitive preprocessing: cropping, anonymization, PII removal
- UI-TARS 1.5 7B (bytedance/ui-tars-1.5-7b) via OpenRouter handles game UI recognition on sanitized images
- Only pre-processed, cropped, anonymized segments leave the local machine

Outputs: classification result, confidence score, raw metadata JSON

Runtime: Local goosecli + OpenRouter via gateway

### Layer 3: Game Reconstruction Engine

Groups screenshots by game session. Reconstructs turn-by-turn board state from metadata.

Seed OSS 36B Instruct (bytedance/seed-oss-36b-instruct) reasons over structured metadata to:
- Sequence turns by timestamp and visual continuity
- Identify cards played, locations revealed, cube state
- Flag missing turns (never fabricate)
- Determine game outcome

Output: structured JSON game record

Runtime: Lambda or local

### Layer 4: Analysis & Strategy

Computes competitive analytics from game records:
- Cube efficiency, retreat timing, snap timing
- Deck performance, matchup tables
- Opponent archetype detection
- Misplay identification
- "What you should have done" scenarios

Runtime: Lambda or local

### Layer 5: Public Artifact Generator

From each game record, automatically produces:
- Public-safe screenshot (cropped, anonymized, stylized)
- Game summary card
- Turn-by-turn replay (GIF or interactive)
- Deck performance update
- Blog-ready markdown
- GitHub PR with new game record + assets

Mandatory redaction step before any artifact is published. API-based deletion of originals after publicization.

Runtime: Lambda

### Layer 6: Website Integration (bryanchasko.com)

Living Marvel Snap dashboard:
- Latest games, deck performance, tournament prep
- Highlight reels, strategy breakdowns
- Public gallery of anonymized screenshots
- Interactive replay viewer

GitHub serves as the backend.

Runtime: Static site + Lambda API

### Layer 7: Continuous Improvement Loop

Every new screenshot feeds the loop. Over time the system learns:
- Play habits, strengths, weaknesses
- Matchup patterns, cube discipline
- Deck biases, tilt patterns, optimal lines

Feedback from analysis informs future classification and reconstruction.

Runtime: Scheduled Lambda + local

### Layer 8: Public Narrative

The pipeline itself is the showcase:
- GitHub repo documents the architecture and workflow
- Blog article on builder.aws.com/community/@bryanchasko
- Tournament calendars, Discord feeds, Twitch integration
- Portfolio piece + technical showcase + competitive tool

## External Vendor Gateway

All external API calls (OpenRouter, future Marvel API, tournament APIs) route through a gateway with:
- Strict payload filters (no PII, no credentials in payloads)
- Cost caps per call and per day
- Request/response logging (bodies redacted)
- Circuit breaker for runaway costs

## Model Routing (via OpenRouter)

| Model | OpenRouter ID | Use Case | Cost |
|-------|--------------|----------|------|
| UI-TARS 1.5 7B | bytedance/ui-tars-1.5-7b | Screenshot classification, game UI recognition | $0.10/$0.20 per M tokens |
| Seed OSS 36B | bytedance/seed-oss-36b-instruct | Game reconstruction reasoning, analysis | TBD |
| Seedance 1.5 Pro | bytedance/seedance-1-5-pro | Video generation (backlog) | $0 (alpha) |

## Tracing & Observability

- OpenTelemetry instrumentation across all layers
- All OTEL spans carry CSWR metadata (issue_id, spec_id, conversation_id)
- CI policy checks enforce privacy boundaries
- No trace data contains PII or credentials
- Ralph Wiggum (ralph-wiggum-otel-trace) handles trace analysis

## GooseCLI Recipe Structure

Stratia designs the recipe YAML. Ellow builds it. The recipe defines:
- Agent definitions for each pipeline stage
- Model tier assignments (local vs OpenRouter)
- Provider routing topology
- Privacy boundary enforcement
- CSWR attachment requirement for all agents

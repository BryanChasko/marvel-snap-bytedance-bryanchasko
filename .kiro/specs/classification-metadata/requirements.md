# Classification & Metadata — Requirements

Spec ID: `classification-metadata`
Privacy Zone: HYBRID (local preprocessing, ByteDance models see only game screenshots)
Execution Platform: Gander (goose-cli) + OpenRouter via goose-proxy
CSWR Anchor: GitHub issue #2, #15, #17, #18

## Strategy

Start with OpenRouter (ByteDance models) to build a clean pipeline. Once established, migrate to local models via the vision-server MCP launcher (which is designed for local models only).

## Requirements (EARS Notation)

### R1: Preprocessing Gate

WHEN a raw screenshot enters the classification pipeline
THE SYSTEM SHALL first run local preprocessing (crop, EXIF strip)
AND SHALL NOT send any unprocessed image to an external model.

### R2: Snap Classification

WHEN a preprocessed image is ready for classification
THE SYSTEM SHALL send it to bytedance/ui-tars-1.5-7b via OpenRouter through the goose-proxy
AND return a classification (snap/not-snap) with a confidence score.

### R3: Metadata Extraction

WHEN an image is classified as Marvel Snap with confidence >= 0.7
THE SYSTEM SHALL extract game metadata: cards played, locations revealed, turn number, energy state, score, opponent identifier.

Threshold is configurable via environment variable. Default 0.7 — for a personal project, false positives just mean extra processing, not harm. Err toward inclusion.

### R4: Structured Output

WHEN metadata is extracted
THE SYSTEM SHALL store it as a JSON file conforming to the game record schema (spec: game-reconstruction)
AND include confidence scores per extracted field.

### R5: Partial Screenshot Handling

WHEN a screenshot is unclear or partially captured
THE SYSTEM SHALL extract what it can, flag uncertain fields with low confidence scores
AND SHALL NOT fabricate missing data.

### R6: Vendor Gateway Routing

WHEN any call is made to an external model
THE SYSTEM SHALL route it through the goose-proxy with payload filters
AND enforce the $0.01/day cost cap.

## Gander Execution

Sub-recipe `snap-classify.yaml` invoked by `snap-pipeline.yaml` orchestrator.

- Lead model: `bytedance-vision` (UI-TARS for image analysis)
- Worker model: `llama3.1:8b` (local, for structured output formatting)
- MCP extensions: filesystem, qdrant-shared-knowledge
- Vision-server MCP is local-only — not used in v1. Target for v2 migration to local models.

## Backlog

- Migrate from OpenRouter to local models via vision-server MCP once pipeline is proven

## Validation Checklist

- [x] All requirements use EARS notation
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Every requirement is testable
- [x] Privacy zone declared (HYBRID)
- [x] Gander recipe identified (sub-recipe of orchestrator)
- [x] CSWR anchor defined

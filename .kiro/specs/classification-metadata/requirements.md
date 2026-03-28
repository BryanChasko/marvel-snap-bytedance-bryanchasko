# Classification & Metadata — Requirements

Spec ID: `classification-metadata`
Privacy Zone: HYBRID
Execution Platform: Gander (goose-cli) + OpenRouter via goose-proxy
CSWR Anchor: GitHub issue #2, #15, #17, #18

## Requirements (EARS Notation)

### R1: Preprocessing Gate

WHEN a raw screenshot enters the classification pipeline
THE SYSTEM SHALL first run local preprocessing (crop, EXIF strip, PII blur)
AND SHALL NOT send any unprocessed image to an external model.

### R2: Snap Classification

WHEN a preprocessed image is ready for classification
THE SYSTEM SHALL send it to bytedance/ui-tars-1.5-7b via OpenRouter through the goose-proxy
AND return a classification (snap/not-snap) with a confidence score.

### R3: Metadata Extraction

WHEN an image is classified as Marvel Snap with confidence >= threshold
THE SYSTEM SHALL extract game metadata: cards played, locations revealed, turn number, energy state, score, opponent identifier (anonymized).

[NEEDS CLARIFICATION: What confidence threshold for classification? 0.8? 0.9? Configurable?]

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
AND enforce the configured cost cap.

## Gander Execution

This layer requires adding ByteDance models to the gander's goose-proxy.py MODEL_MAP:

| Alias | Provider | Model ID |
|-------|----------|----------|
| `bytedance-vision` | OpenRouter | `bytedance/ui-tars-1.5-7b` |
| `bytedance-reason` | OpenRouter | `bytedance/seed-oss-36b-instruct` |

Recipe structure:
- Lead model: `bytedance-vision` (UI-TARS for image analysis)
- Worker model: `llama3.1:8b` (local, for structured output formatting)
- MCP extensions: filesystem, qdrant-shared-knowledge, vision-server
- Sub-recipe pattern: preprocessing (local) → classification (hybrid) → extraction (hybrid)

[NEEDS CLARIFICATION: Does the existing vision-server MCP launcher in the gander support sending images to OpenRouter models, or does it only work with local models?]

## Validation Checklist

- [x] All requirements use EARS notation
- [ ] No [NEEDS CLARIFICATION] markers remain
- [x] Every requirement is testable
- [x] Privacy zone declared (HYBRID)
- [ ] Gander recipe identified
- [x] CSWR anchor defined

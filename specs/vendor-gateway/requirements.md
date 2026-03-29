# Vendor Gateway — Requirements

Spec ID: `vendor-gateway`
Privacy Zone: Cross-cutting (keeps ByteDance away from Google credentials)
Execution Platform: Gander goose-proxy.py
CSWR Anchor: GitHub issue #11, #16

## Requirements (EARS Notation)

### R1: Mandatory Routing

WHEN any agent makes a call to an external model provider
THE SYSTEM SHALL route it through the goose-proxy heuristic dispatcher.

### R2: Payload Filtering

WHEN a request is routed through the proxy
THE SYSTEM SHALL reject any payload that matches PII patterns (email, phone, address, account ID)
AND log the rejection with the CSWR of the originating agent.

### R3: Cost Caps

WHEN the cumulative daily cost exceeds $0.01
THE SYSTEM SHALL reject further external model calls
AND return a clear error to the calling agent.

Cost cap is configurable via environment variable. Default: $0.01/day.
At UI-TARS pricing ($0.10/$0.20 per M tokens), $0.01 allows ~50-100 screenshot classifications per day.

### R4: Request Logging

WHEN a request passes through the proxy
THE SYSTEM SHALL log: timestamp, model alias, token count, cost estimate, CSWR metadata
AND SHALL NOT log request or response bodies.

### R5: ByteDance Model Registration

WHEN the proxy starts
THE SYSTEM SHALL include ByteDance models in the MODEL_MAP:
- `bytedance-vision` → `bytedance/ui-tars-1.5-7b`
- `bytedance-reason` → `bytedance/seed-oss-36b-instruct`

### R6: Circuit Breaker

WHEN a model endpoint returns errors on 3 consecutive calls
THE SYSTEM SHALL trip the circuit breaker for that model
AND fall back to the next available model in the routing chain.

## Gander Execution

Extension to goose-proxy.py in goosecli-heraldstack-gander:
- Add ByteDance entries to MODEL_MAP
- Add PII pattern filter to request pipeline
- Add cost tracking via Valkey (daily counter, reset at midnight)
- Add CSWR metadata to request logs

Cedar policy alignment: no-secrets-in-commits.cedar already covers secret patterns.

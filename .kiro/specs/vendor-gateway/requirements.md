# Vendor Gateway — Requirements

Spec ID: `vendor-gateway`
Privacy Zone: Cross-cutting (enforces HYBRID/PUBLIC boundary)
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

WHEN the cumulative daily cost exceeds the configured cap
THE SYSTEM SHALL reject further external model calls
AND return a clear error to the calling agent.

[NEEDS CLARIFICATION: What daily cost cap? $5? $10? Configurable per-model?]

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

This is an extension to the existing goose-proxy.py in goosecli-heraldstack-gander. Changes needed:
- Add ByteDance entries to MODEL_MAP
- Add PII pattern filter to request pipeline
- Add cost tracking and cap enforcement
- Add CSWR metadata to request logs

Cedar policy alignment: no-secrets-in-commits.cedar already covers secret patterns. Extend with a payload-filter policy.

## Validation Checklist

- [x] All requirements use EARS notation
- [ ] No [NEEDS CLARIFICATION] markers remain
- [x] Every requirement is testable
- [x] Privacy zone declared (cross-cutting)
- [x] Gander execution identified (goose-proxy.py extension)
- [x] CSWR anchor defined

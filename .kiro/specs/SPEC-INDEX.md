# Spec Index

This project uses multiple focused specs, not one monolith.

## Active Specs

| Spec | Path | Status |
|------|------|--------|
| Pipeline Overview | `.kiro/specs/marvel-snap-pipeline/` | Design-first, in progress |
| Private Ingestion | `.kiro/specs/private-ingestion/` | Requirements phase |
| Classification & Metadata | `.kiro/specs/classification-metadata/` | Requirements phase |
| Game Reconstruction | `.kiro/specs/game-reconstruction/` | Requirements phase |
| Vendor Gateway | `.kiro/specs/vendor-gateway/` | Requirements phase |

## Spec Workflow

This project uses Design-First workflow. Bryan provided the cybernetic loop architecture (design), and requirements are derived from it.

Flow: design.md → requirements.md → tasks.md

## Spec Validation Checklist

Before any spec is considered complete:

- [ ] All requirements use EARS notation (WHEN/THE SYSTEM SHALL)
- [ ] No [NEEDS CLARIFICATION] markers remain unresolved
- [ ] Every requirement is testable
- [ ] Every task traces to a requirement
- [ ] Privacy zone is declared for every component
- [ ] Gander recipe or sub-recipe is identified for execution
- [ ] CSWR attachment point is defined
- [ ] Cedar policy compliance is verified

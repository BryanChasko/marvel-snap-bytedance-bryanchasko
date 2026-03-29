# Spec Index

This project uses goose-cli spec conventions. Specs live in `specs/`, tasks follow the format expected by `generate-task-issues.py`.

## Active Specs

| Spec | Path | Status |
|------|------|--------|
| Pipeline Overview | `specs/marvel-snap-pipeline/` | Design + tasks complete |
| Private Ingestion | `specs/private-ingestion/` | Requirements complete |
| Classification & Metadata | `specs/classification-metadata/` | Requirements complete |
| Game Reconstruction | `specs/game-reconstruction/` | Requirements complete |
| Vendor Gateway | `specs/vendor-gateway/` | Requirements complete |

## Generating GitHub Issues from Tasks

```bash
python3 scripts/generate-task-issues.py \
  --tasks-file specs/marvel-snap-pipeline/tasks.md \
  --repo BryanChasko/marvel-snap-bytedance-bryanchasko
```

This uses the gander's existing `generate-task-issues.py` script.

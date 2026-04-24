#!/usr/bin/env bash
# snap-setup.sh — validate environment before running the snap pipeline
# run this before your first recipe execution to confirm all dependencies are ready

set -uo pipefail

PASS=0
FAIL=0
WARN=0

check() {
  local label="$1"
  local cmd="$2"
  if eval "$cmd" > /dev/null 2>&1; then
    echo "  [ok]  $label"
    PASS=$((PASS + 1))
  else
    echo "  [FAIL] $label"
    FAIL=$((FAIL + 1))
  fi
}

warn() {
  local label="$1"
  local cmd="$2"
  if eval "$cmd" > /dev/null 2>&1; then
    echo "  [ok]  $label"
    PASS=$((PASS + 1))
  else
    echo "  [warn] $label"
    WARN=$((WARN + 1))
  fi
}

echo "snap pipeline environment check"
echo "================================"
echo ""

# -- local directories --
echo "staging directories:"
check "staging/raw exists" "test -d staging/raw"
check "staging/queued exists" "test -d staging/queued"
check "fixtures/ exists" "test -d fixtures"
check "specs/game-reconstruction/schema.json exists" "test -f specs/game-reconstruction/schema.json"
echo ""

# -- infrastructure services --
echo "infrastructure:"
check "qdrant reachable (6333)" "curl -sf http://localhost:6333/healthz"
warn "valkey reachable via MCP (8110)" "curl -sf -X POST http://localhost:8110/mcp -H 'Content-Type: application/json' -d '{\"jsonrpc\":\"2.0\",\"id\":\"snap-setup\",\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-03-26\",\"capabilities\":{},\"clientInfo\":{\"name\":\"snap-setup\",\"version\":\"1.0.0\"}}}'"
warn "goose-proxy reachable (4000)" "curl -sf http://localhost:4000/ready"
echo ""

# -- qdrant collections --
echo "qdrant collections:"
for coll in snap-game-records snap-analysis snap-screenshots; do
  warn "collection: $coll" "curl -sf http://localhost:6333/collections/$coll"
done
echo "  note: run scripts/bootstrap-qdrant-collections.sh if the snap collections are missing"
echo ""

# -- schema validation --
echo "schema:"
if command -v python3 > /dev/null 2>&1; then
  check "sample_game_record validates against schema" \
    "python3 -c \"
import json
from jsonschema import validate
schema = json.load(open('specs/game-reconstruction/schema.json'))
record = json.load(open('fixtures/sample_game_record.json'))
validate(record, schema)
\""
else
  warn "python3 available for schema validation" "false"
fi
echo ""

# -- summary --
echo "================================"
echo "passed: $PASS  failed: $FAIL  warnings: $WARN"
if [ "$FAIL" -gt 0 ]; then
  echo "fix failures before running snap recipes"
  exit 1
else
  if [ "$WARN" -gt 0 ]; then
    echo "environment partially ready — review warnings before external-model or qdrant-dependent runs"
  else
    echo "environment ready"
  fi
  exit 0
fi

# Private Ingestion — Requirements

Spec ID: `private-ingestion`
Privacy Zone: PRIVATE
Execution Platform: Gander (goose-cli, local agent on aihost)
CSWR Anchor: GitHub issue #1, #13, #14

## Requirements (EARS Notation)

### R1: Screenshot Detection

WHEN a new image appears in the user's Google Photos library
THE SYSTEM SHALL detect it within the configured polling interval
AND copy it to the local staging directory on aihost.

### R2: Local-Only Execution

WHEN the ingestion agent runs
THE SYSTEM SHALL execute entirely on the local machine via goose-cli
AND SHALL NOT make any external API calls except to the Google Photos API.

[NEEDS CLARIFICATION: Which Google Photos API client library? Python via google-auth + google-api-python-client, or a lighter alternative?]

### R3: Original Deletion

WHEN a screenshot has been successfully copied to local staging AND processing is confirmed complete
THE SYSTEM SHALL delete the original from Google Photos via the API
AND log the deletion with timestamp and confirmation status.

[NEEDS CLARIFICATION: What defines "processing complete"? After classification? After full game reconstruction? After public artifact generation?]

### R4: Deletion Safety

WHEN the system attempts to delete an original from Google Photos
THE SYSTEM SHALL support a dry-run mode that logs intended deletions without executing them.

### R5: Credential Isolation

WHEN Google OAuth tokens are used
THE SYSTEM SHALL store them only in local .env files
AND SHALL NOT pass them to any external model, proxy, or cloud service.

### R6: Staging Directory

WHEN images are copied to local staging
THE SYSTEM SHALL write them to a gitignored directory
AND SHALL NOT commit raw screenshots to the public repository under any circumstances.

## Gander Execution

This layer maps to a goose-cli recipe. The recipe should:
- Use local Ollama models only (no OpenRouter calls)
- Mount the Google Photos OAuth token from .env
- Use the filesystem MCP launcher for local file operations
- Follow the lead/worker pattern: llama3.1:8b for execution
- Attach CSWR metadata via prompt-ledger.sh

[NEEDS CLARIFICATION: Should this be a standalone recipe or a sub-recipe invoked by a pipeline orchestrator recipe?]

## Validation Checklist

- [x] All requirements use EARS notation
- [ ] No [NEEDS CLARIFICATION] markers remain
- [x] Every requirement is testable
- [x] Privacy zone declared (PRIVATE)
- [ ] Gander recipe identified
- [x] CSWR anchor defined

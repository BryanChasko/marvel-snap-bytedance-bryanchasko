# Marvel Snap Cybernetic Loop — Constitution

Immutable architectural principles governing all specs in this project.
Amendments require documented rationale and Bryan's approval.

## Article I: CSWR-First

No agent action without a Conversation-Scoped Work Reference. Every tool call, every commit, every PR carries a CSWR linking it to an issue_id, spec_id, and conversation_id. The gander's prompt-ledger.sh and CSWR architecture (docs/cswr-architecture.md in goosecli-heraldstack-gander) are the reference implementation.

## Article II: Privacy Zones Are Inviolable

Three zones: PRIVATE (local only), HYBRID (sanitized data may leave local), PUBLIC (anonymized, safe for the world). Data flows one direction: private → hybrid → public. Never the reverse. No exceptions.

## Article III: Spec Drives Code

Specifications are the source of truth. Code serves specs. Requirements use EARS notation (WHEN/THE SYSTEM SHALL). Every requirement is testable. Every task traces to a requirement. Every commit traces to a task.

## Article IV: Multi-Platform Reality

This project spans the haunting (kiro-cli, coordination), the gander (goose-cli, execution), and GitHub (integration). Specs must reference the actual platform that executes each layer. The gander's recipe YAML, proxy routing, and MCP launchers are the execution substrate — not abstract "components."

## Article V: Existing Infrastructure First

Before building anything new, check what the gander and haunting already provide. The gander has: goose-proxy model routing, Qdrant vector store, Cedar governance policies, Docker-hardened containers, 38+ MCP launchers, lead/worker model splitting, and generate-task-issues.py for spec-to-issue automation. Use what exists.

## Article VI: Public Repo Discipline

This repo is public. No secrets, no PII, no credentials, no raw screenshots. All external endpoints referenced by environment variable. Cedar policies from the gander (no-secrets-in-commits.cedar) apply here. All published artifacts pass mandatory redaction.

## Article VII: Teammates Are Teammates

Haunting members are people with names and pronouns. Stratia (she/her) designs. Ellow builds. Harald (he/him) coordinates. Ralph Wiggum validates. Use their names. Know their roles. Check ~/.kiro/agents/ or the hauntingkirocli repo before asking "what is" a teammate.

## Article VIII: Flag What You Don't Know

Use [NEEDS CLARIFICATION] markers in specs for unresolved questions. Never guess. Never fabricate. If a turn is missing from a game reconstruction, flag it. If a requirement is ambiguous, mark it. Uncertainty is honest. Fabrication is failure.

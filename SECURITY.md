# Security Policy

This is a PUBLIC repository. Every commit is visible to the world.

## Rules

- NEVER commit API keys, tokens, passwords, or credentials
- NEVER commit Google account info, OAuth tokens, or session data
- NEVER commit PII (names, emails, phone numbers, addresses)
- NEVER commit raw screenshots that contain personal information
- All external service endpoints must be referenced by environment variable, never hardcoded
- All example configs must use placeholder values (e.g., `YOUR_API_KEY_HERE`)

## Environment Variables

All secrets are managed through environment variables or local `.env` files. The `.env` file is gitignored and must never be committed.

## External API Calls

All external vendor calls (OpenRouter, Google Photos API, Marvel API) must:
- Route through a gateway with payload filters
- Never log request/response bodies containing credentials
- Use cost caps to prevent runaway spending
- Obfuscate endpoint URLs in public-facing documentation

## Reporting

If you find a secret committed to this repo, open an issue immediately.

# Marvel Snap Screenshot Pipeline — Requirements

## Open Questions

- What is "stratia" and how should it be used for architectural planning?
- Which ByteDance model(s) specifically for image analysis via goosecli?
- Marvel API access scope — which endpoints are available?
- Target website platform (static site, existing blog, etc.)?

## Constraints

- Google Photos interactions MUST use local tooling and locally hosted agents via goosecli. No ByteDance models touch personal Google account data.
- ByteDance models are used exclusively for Snap-specific processing (classification, metadata extraction, game analysis).
- AWS Lambda is available for Snap processing and public-facing pipeline components.
- Public outputs must respect Snap asset usage guidelines.

## User Stories

### Story 1: Screenshot Ingestion

As a Snap player, I want new screenshots automatically detected and pulled from my Google Photos so I don't have to manually export them.

Acceptance Criteria:
- Local agent monitors Google Photos for new images
- New images are pulled to local storage for processing
- Runs on a schedule or event-driven trigger
- No cloud services touch Google account credentials

### Story 2: Screenshot Classification

As a Snap player, I want screenshots automatically classified as Marvel Snap or not so only relevant images enter the pipeline.

Acceptance Criteria:
- ByteDance model via goosecli classifies images as Snap/not-Snap
- Classification can run locally or on Lambda
- Non-Snap images are tagged and excluded from further Snap processing
- Classification confidence score is stored

### Story 3: Snap Metadata Extraction

As a Snap player, I want game metadata extracted from Snap screenshots so I can reconstruct what happened in each game.

Acceptance Criteria:
- Extracts: cards played, locations revealed, turn number, energy state, score, opponent name
- ByteDance model handles OCR and visual recognition
- Metadata stored in structured format (JSON)
- Handles partial/unclear screenshots gracefully

### Story 4: Game Reconstruction

As a Snap player, I want sequential screenshots grouped and assembled into complete game records so I can review full games.

Acceptance Criteria:
- Screenshots are grouped by game session (timestamp proximity, visual continuity)
- Turn-by-turn game state is reconstructed from metadata
- Game outcome (win/loss/snap/retreat) is captured
- Missing turns are flagged, not fabricated

### Story 5: Game Analysis

As a Snap player, I want analysis of my games so I can identify patterns and improve my play.

Acceptance Criteria:
- Win/loss tracking by deck, location, matchup
- Snap/retreat decision analysis
- Trend visualization over time
- Deck performance comparison

### Story 6: External Data Enrichment

As a content creator, I want game data enriched with external sources so my analysis has broader context.

Acceptance Criteria:
- Marvel API integration for card/character lore and assets
- Tournament calendar integration for event context
- Snap community data (meta decks, tier lists) where available
- Discord and Twitch integration points for content sharing

### Story 7: Public Showcase

As a content creator, I want to publish game analysis and workflow artifacts on my website, blog, and GitHub so others can see and learn from the process.

Acceptance Criteria:
- Game reconstructions rendered for web display
- Analysis dashboards or visualizations are embeddable
- Workflow itself is documented and visible on GitHub
- Personal data (Google account, private photos) never exposed

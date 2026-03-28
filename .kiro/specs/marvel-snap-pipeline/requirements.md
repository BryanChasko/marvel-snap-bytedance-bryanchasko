# Marvel Snap Screenshot Pipeline — Requirements

## Resolved

- Stratia (stratia-gander-arch) is the haunting's architect. She designs GooseCLI agent blueprints, recipe YAML, tier mappings, and provider routing. Blueprint-first, read-only during drafting. She owns the design.md phase.
- ByteDance models on OpenRouter: UI-TARS 1.5 7B (vision/GUI, $0.10/$0.20/M), Seed OSS 36B Instruct (reasoning, 131K ctx), Seedance 1.5 Pro (video gen, alpha)
- Website: bryanchasko.com. Blog: builder.aws.com/community/@bryanchasko (article about the process, written after completion)

## Backlog (not this sprint)

- Marvel API integration for card/character lore and assets
- Seedance 1.5 Pro for game replay video generation
- Discord and Twitch integration points

## Constraints

- Google Photos interactions MUST use local tooling and locally hosted agents via goosecli. No ByteDance models touch personal Google account data.
- ByteDance models via OpenRouter are used for Snap-specific processing (classification, metadata extraction, game analysis).
- AWS Lambda is available for Snap processing and public-facing pipeline components.
- Public outputs must respect Snap asset usage guidelines.

## Model Assignments

- UI-TARS 1.5 7B (bytedance/ui-tars-1.5-7b): Screenshot classification, Snap metadata extraction, visual game state recognition. Multimodal vision-language agent built for GUI/game environments.
- Seed OSS 36B Instruct (bytedance/seed-oss-36b-instruct): Game reconstruction reasoning, analysis logic, structured data processing. 131K context window.

## Haunting Agents Involved

- stratia-gander-arch: Architectural design, recipe YAML, provider routing
- ellow-goosecli-dev: GooseCLI agent implementation
- myrren-openrouter-arch: OpenRouter model routing topology
- harald-gander-anchor: Coordination and sprint tracking

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
- UI-TARS 1.5 7B via goosecli classifies images as Snap/not-Snap
- Classification can run locally or on Lambda
- Non-Snap images are tagged and excluded from further Snap processing
- Classification confidence score is stored

### Story 3: Snap Metadata Extraction

As a Snap player, I want game metadata extracted from Snap screenshots so I can reconstruct what happened in each game.

Acceptance Criteria:
- Extracts: cards played, locations revealed, turn number, energy state, score, opponent name
- UI-TARS 1.5 7B handles visual recognition of game UI elements
- Metadata stored in structured format (JSON)
- Handles partial/unclear screenshots gracefully

### Story 4: Game Reconstruction

As a Snap player, I want sequential screenshots grouped and assembled into complete game records so I can review full games.

Acceptance Criteria:
- Screenshots are grouped by game session (timestamp proximity, visual continuity)
- Seed OSS 36B Instruct reasons over metadata to reconstruct turn-by-turn game state
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
- Tournament calendar integration for event context
- Snap community data (meta decks, tier lists) where available
- Marvel API integration (backlogged — not this sprint)

### Story 7: Public Showcase

As a content creator, I want to publish game analysis and workflow artifacts on bryanchasko.com and GitHub so others can see and learn from the process.

Acceptance Criteria:
- Game reconstructions rendered for web display on bryanchasko.com
- Analysis dashboards or visualizations are embeddable
- Workflow itself is documented and visible on GitHub
- Personal data (Google account, private photos) never exposed
- Blog article on builder.aws.com/community/@bryanchasko documenting the process (post-completion)

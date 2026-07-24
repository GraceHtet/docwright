# Changelog

All notable changes to DocWright will be documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.1.0] - 2026-07-22

### Added

- Railtie integration — DocWright hooks into Rails boot automatically
- `docwright:generate` — interactive wizard for guided documentation generation
- Database documentation — auto-extracts tables, columns, and types
- API documentation — auto-extracts routes and endpoints
- Model documentation — auto-extracts associations and validations
- Auth and permissions documentation — detects before/around/after action filters
- Background jobs documentation — detects job classes, queues, priorities, and schedules
- Services documentation — detects service classes and public methods
- Concerns documentation — detects model and controller concerns
- Manual templates — overview, setup, architecture, deployment, security, troubleshooting, business rules, changelog, readme
- Feature-specific docs — declared in `.docwright.yml`
- Smart merge markers — human-written content preserved across regenerations
- `docwright:check` — audit task for missing files, placeholder content, empty notes
- `docwright:search` — search across all documentation files

## [0.1.1] - 2026-07-24

### Fixed

- `eager_load!` rescue in model, auth, concerns, and background_jobs extractors to handle missing railties gracefully
- `merger.rb` notes_placeholder now passed through to `merge_named` — fixes inconsistent notes headers
- `write_template` in wizard now correctly handles feature files using `FeatureGenerator`
- `FeatureGenerator` — added `generate_single` method for wizard template writing
- `README.md` — added link to examples/ folder

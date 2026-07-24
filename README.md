# DocWright

Auto-generate and maintain documentation for your Rails application.

DocWright introspects your live Rails app to generate structured markdown
documentation for your database schema, API routes, models, services,
background jobs, and more. Human-written content is preserved across
regenerations using smart merge markers.

## Installation

Add to your application's Gemfile:

```ruby
gem "docwright"
```

Then run:

```bash
bundle install
bundle exec rake docwright:generate
```

## Usage

### Generate documentation

```bash
rake docwright:generate
```

Runs the interactive wizard which:

1. Scans your app and shows what will be generated
2. Asks y/n to continue
3. Generates auto files (database, API, models)
4. Walks you through each new manual file with write/editor/skip options

### Check documentation completeness

```bash
rake docwright:check
```

Audits your docs and reports:

- Missing required files
- Files with placeholder content only
- Empty notes slots

### Search documentation

```bash
rake docwright:search[your_term]
```

Searches across all generated markdown files.

## Generated files

### Auto-generated (always regenerated)

- `docs/database.md` — tables, columns, types
- `docs/api.md` — routes and endpoints
- `docs/models.md` — associations and validations per model

### Manual templates (written once, never overwritten)

- `docs/overview.md`
- `docs/setup.md`
- `docs/architecture.md`
- `docs/deployment.md`
- `docs/security.md`
- `docs/troubleshooting.md`
- `docs/business_rules.md`
- `docs/changelog.md`
- `docs/readme.md`

### Optional docs (declared in `.docwright.yml`)

- `docs/auth_and_permissions.md`
- `docs/background_jobs.md`
- `docs/services.md`
- `docs/concerns.md`
- `docs/features/*.md`

## Configuration

Create `.docwright.yml` in your Rails app root:

```yaml
# Optional narrative docs
optional_docs:
  auth_and_permissions: true
  background_jobs: true
  services: true
  concerns: true

# Feature-specific docs
features:
  - name: qr_flow
    description: QR code generation and scanning flow
  - name: subscriptions
    description: Billing and plan management
```

## How merge markers work

Auto-generated content is wrapped in markers:

<!-- DOCWRIGHT:AUTO -->

auto content here — regenerated every time

<!-- DOCWRIGHT:END -->

Write your notes **outside** these markers — DocWright will never touch them.

For per-model files, named markers are used:

<!-- DOCWRIGHT:AUTO:Post -->

auto content for Post

<!-- DOCWRIGHT:END:Post -->

Notes for Post

your notes here — never overwritten

## Development

```bash
git clone https://github.com/GraceHtet/docwright.git
cd docwright
bundle install
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/GraceHtet/docwright/issues).

## License

MIT License. See [LICENSE.txt](LICENSE.txt).

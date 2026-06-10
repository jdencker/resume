# LaTeX Resume · Docker Build · CI/Lint · Versioned Releases

This repo contains my single-page LaTeX resume, backed by a **reproducible build system**, **automated linting**, and **GitHub Actions workflows** for CI and releases.

- Deterministic builds via Docker - also enables local builds without local TeX distribution
- Spellchecking that correctly parses LaTeX
- PDF validation via `cvlint`
- CI-gated changes to `main`
- Manual release workflow that versions and publishes a downloadable PDF via GitHub Pages

## Repository Structure

A high-level view of the repository layout:

    .
    ├── src/
    │   └── resume.tex              # LaTeX source code
    │
    ├── build/                      # (gitignored) Generated during local/CI builds
    │   └── resume.pdf
    │
    ├── dist/                       # Latest released résumé (GitHub Pages)
    │   └── resume.pdf
    │
    ├── release-notes/              # Per-edition résumé release notes (vX.Y.Z.md)
    │
    ├── scripts/
    │   ├── run_lint.py             # Unified lint runner
    │   ├── bump-version.sh         # Semantic version bumping (résumé releases)
    │   ├── setup.sh                # Local env setup helper
    │   └── linting_helpers/        # Spellcheck + cvlint helpers
    │
    ├── .github/
    │   └── workflows/              # CI + release pipelines
    │       ├── build-resume.yml    # PR build, lint, ruff, commit-message checks
    │       ├── release-propose.yml # Manual: open a versioned release PR
    │       └── release-publish.yml # Auto on VERSION change: tag + GitHub Release
    │
    ├── hooks/                     
    │   └── commit-msg              # conventional commit style linter for commit messages
    │
    ├── lint-config.yml             # Spellchecker allowlist + cvlint rules
    ├── ruff.toml                   # Ruff config for Python tooling
    ├── requirements.txt            # Pinned Python dependencies
    ├── Makefile                    # Build + lint commands
    ├── LICENSE
    ├── VERSION                     # Current release version
    ├── CHANGELOG.md                # Technical / infra changelog
    └── README.md

## Dependencies

This project requires only a few external tools, all of which are installed automatically in CI or via Docker-based builds.

### Runtime Dependencies
- **Docker** (recommended for reproducible builds)
- **Make** (used to orchestrate build and lint targets)

### Local Development
If you want to run the lint suite locally (useful for checking CI outcomes prior to pushing):

NOTE: The Docker workflow bundles all LaTeX dependencies, so no system-level TeX installation is required unless you choose to build locally.

#### Setup Script
  - `scripts/setup.sh`
  - sets up the required commit formatting hook
  - checks for runtime dependencies (run locally as well)
  - also checks for Python dependencies:
    - **Python 3.11+**
    - **requirements.txt**
    - **TeX Live** with `latexmk` (local builds without docker - not recommended)

#### Makefile targets:
  1. `make` -> defaults to local (non-docker) build
  2. `make docker` -> docker-based build
  3. `make lint` -> local env based lint
  4. `make clean` -> removes `build/` dir for clean latex build
  
#### Commit Message Format Requirements
Simple Conventional Commit-style linter for commit messages.
Enforces: `type(scope): subject`
Allowed types: 
  - feat
  - fix
  - docs
  - chore

## Goals

This repo is designed to showcase:

- Clear, concise technical communication (through the resume itself)
- Engineering discipline around build pipelines and CI
- Attention to detail through strict linting and quality gates
- A clean, maintainable structure suitable for long-term use

## Features

This repository provides a reproducible, automated workflow for maintaining a single-page LaTeX résumé with consistent quality and versioned releases.

### Reproducible Builds
- Deterministic PDF output using a pinned TeXLive Docker image.
- Makefile-based build system for both Docker and local LaTeX environments.

### Automated Linting
- Unified `make lint` command that runs:
  - codespell for common spelling issues
  - a LaTeX-aware spellchecker with an allowlist
  - cvlint for structural PDF checks
- All linting steps return non-zero exit codes to support CI gating.

### Continuous Integration
- Every pull request to `main` triggers a CI workflow that:
  - Builds the résumé in Docker
  - Runs the full lint suite
  - Lints the Python tooling with ruff
  - Validates commit messages against the Conventional Commit rules
  - Uploads the generated PDF as an artifact
- Branch protection ensures only lint-clean changes reach `main`.

### Release Workflow
- A two-phase process: a manual workflow opens a versioned release PR, and a second workflow tags and publishes the GitHub Release only after it merges to `main`.
- Rebuilds and re-lints the résumé, updates `VERSION`, and publishes the PDF with per-edition release notes.

### GitHub Pages Distribution
- The `dist/` directory is published via GitHub Pages.
- The latest released résumé is available at a stable, downloadable URL.

## Build Instructions

The résumé can be built either through Docker (recommended) or a local LaTeX installation. All build commands are defined in the Makefile.

### Build with Docker (reproducible)
This method ensures a consistent TeXLive environment across all machines:

    make docker

The resulting PDF will be written to:

    build/resume.pdf

### Build Locally (if TeX Live is installed)

    make

### Clean Build Artifacts

    make clean

## Linting

The lint pipeline verifies spelling, structure, and PDF quality before changes are merged or released. All lint checks are wrapped in a single command:

    make lint

### What the Lint Step Checks
- **codespell** for common spelling mistakes  
- **LaTeX-aware spellchecker** that extracts only document text and applies an allowlist  
- **cvlint** for PDF validation (single-page enforcement, metadata checks, link hygiene, etc.)

A non-zero exit code from any check causes the entire lint step to fail, which is required for CI gating.

## Continuous Integration

All pull requests to `main` run an automated CI workflow that builds and validates the résumé.

### What CI Does
1. Builds the PDF in a pinned Docker environment  
2. Runs the unified lint suite  
3. Lints the Python tooling with ruff  
4. Validates the PR's commit messages against the Conventional Commit rules  
5. Uploads the generated PDF as an artifact for review  

### Branch Protection
The `main` branch is protected so that:
- All changes must come through a pull request  
- CI must pass before the pull request can be merged  

This keeps `main` consistently buildable and lint-clean.

## Release Workflow

Résumé releases use a **two-phase** process so a version is only ever published from `main`, never from an unmerged branch.

### Phase 1 — Propose (`release-propose.yml`, manual)
Dispatched manually with a `bump` type (patch/minor/major) and a one-line `summary`. It:
1. Rebuilds the résumé in Docker and runs the full lint suite  
2. Bumps the `VERSION` file  
3. Copies the validated PDF to `dist/resume.pdf`  
4. Writes the summary to `release-notes/vX.Y.Z.md`  
5. Opens a release pull request  

No tag or GitHub Release is created in this phase.

### Phase 2 — Publish (`release-publish.yml`, automatic)
Triggered when a change to `VERSION` lands on `main` (i.e. a release PR is merged). It tags `vX.Y.Z` at that commit and creates the GitHub Release — using `release-notes/vX.Y.Z.md` as the body and attaching `dist/resume.pdf`.

This guarantees every published résumé is versioned, validated, and traceable, and that the tag always points at a real commit on `main`.

### Versioning and changelog
`VERSION` tracks the **résumé document**, not the build tooling — a bump means a new edition of the résumé. Each edition is a Git tag + GitHub Release. `CHANGELOG.md` is a separate **technical** changelog for build, CI, and tooling changes.

## GitHub Pages [Coming Soon]

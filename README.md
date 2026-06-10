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
    ├── scripts/
    │   ├── run_lint.py             # Unified lint runner
    │   ├── bump-version.sh         # Semantic version bumping
    │   ├── generate-changelog.sh   # Changelog creation
    │   ├── setup.sh                # Local env setup helper
    │   └── linting_helpers/        # Spellcheck + cvlint helpers
    │
    ├── .github/
    │   └── workflows/              # CI + release pipelines
    │       ├── build-resume.yml    # PR build, lint, ruff, commit-message checks
    │       └── release-resume.yml  # Manual versioned release
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
    ├── CHANGELOG.md                # Auto-generated release notes
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
- A manual GitHub Action handles official releases.
- Rebuilds and re-lints the résumé, updates `VERSION`, regenerates `CHANGELOG.md`, commits release artifacts, and tags the version.

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

Official résumé releases are created through a manual GitHub Actions workflow.

### What the Release Workflow Does
1. Rebuilds the résumé using Docker  
2. Runs the full lint suite  
3. Updates the `VERSION` file  
4. Regenerates `CHANGELOG.md`  
5. Copies the validated PDF to `dist/resume.pdf`  
6. Commits release artifacts back to `main` and creates a version tag  

This ensures every published résumé is versioned, validated, and fully traceable.

## GitHub Pages [Coming Soon]

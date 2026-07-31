# LaTeX Résumé

This repository contains the source and delivery pipeline for my single-page résumé. The document is built reproducibly with a pinned TeX Live container, validated in CI, and published as a versioned PDF.

## What this repository provides

- A reproducible Docker-based LaTeX build
- LaTeX-aware spelling and structural PDF validation
- Pull-request quality gates for the résumé and its supporting scripts
- A two-phase release workflow that publishes only from `main`
- A stable copy of the latest released PDF in `dist/resume.pdf`

## Typical update workflow

1. Edit the résumé content in `src/resume.tex`.
2. Run `make docker` followed by `make lint`.
3. Commit the change on a branch, push it, and open a pull request into `main`.
4. Wait for CI to pass, review the generated PDF artifact, and merge the pull request.
5. In GitHub Actions, run **Release - Propose Résumé Version** and choose the appropriate version bump.
6. Review and merge the generated release pull request. The publish workflow then creates the tag and GitHub Release automatically.

## Repository structure

```text
.
├── src/
│   └── resume.tex              # Résumé source
├── build/                      # Local and CI build output (gitignored)
│   └── resume.pdf
├── dist/
│   └── resume.pdf              # Latest released résumé
├── release-notes/
│   └── vX.Y.Z.md               # Notes for each résumé edition
├── scripts/
│   ├── run_lint.py             # Unified lint runner
│   ├── bump-version.sh         # Semantic version helper
│   ├── setup.sh                # Local environment setup
│   └── linting_helpers/        # Spellcheck and PDF-validation helpers
├── .github/workflows/
│   ├── build-resume.yml        # Pull-request quality checks
│   ├── release-propose.yml     # Opens a versioned release PR
│   └── release-publish.yml     # Tags and publishes a merged release
├── hooks/commit-msg            # Conventional commit-message check
├── lint-config.yml             # Spellchecker allowlist and cvlint rules
├── ruff.toml                   # Python lint configuration
├── requirements.txt            # Pinned Python dependencies
├── Makefile                    # Build and lint commands
├── VERSION                     # Current résumé edition
└── CHANGELOG.md                # Build and tooling changes
```

## Local development

The recommended local dependencies are Docker and Make. Python 3.11 or later is also required to run the lint suite outside CI.

Run the setup helper once after cloning:

```bash
scripts/setup.sh
```

### Build

Use the pinned TeX Live container for the reproducible build:

```bash
make docker
```

The generated PDF is written to `build/resume.pdf`.

If a compatible TeX Live installation is already available locally, run:

```bash
make
```

Remove generated build files with:

```bash
make clean
```

### Validate

Build the PDF before running the unified lint suite:

```bash
make docker
make lint
```

Validation includes:

- `codespell` for common spelling errors
- LaTeX-aware spellchecking against the project allowlist
- `cvlint` checks for page count, metadata, links, and document structure
- Ruff checks for the Python tooling in CI

## Automation

### Pull requests

Every pull request into `main` runs three quality jobs:

1. `build-and-lint` builds the PDF, validates it, and uploads it as a workflow artifact.
2. `ruff` checks the Python support scripts.
3. `commit-lint` validates commit messages using the repository's Conventional Commit rules.

Branch protection requires these checks to pass before merge.

### Publish a résumé edition

Résumé releases use two phases so a tag is created only after the release commit reaches `main`.

1. In GitHub Actions, run **Release - Propose Résumé Version**.
2. Select a semantic version bump and provide a one-line release summary.
3. The workflow builds and validates the résumé, updates `VERSION`, copies the PDF to `dist/resume.pdf`, writes the release notes, and opens a release PR.
4. Review and merge that PR into `main` after its normal quality checks pass.
5. **Release - Publish Résumé Version** automatically tags the merge commit and creates the GitHub Release with `dist/resume.pdf` attached.

Do not tag releases manually. The automated flow keeps the version file, committed PDF, release notes, Git tag, and GitHub Release aligned.

## Versioning

`VERSION` tracks editions of the résumé document. A change to résumé content that should be published requires a version bump and release; build, CI, and tooling changes do not.

Technical changes are recorded separately in `CHANGELOG.md`.

## GitHub Pages

`dist/resume.pdf` is the source for the stable web-hosted résumé. The Pages deployment should publish that released artifact—not the unreleased PDF generated from the current source—so the public URL always corresponds to a tagged résumé edition.

## Commit messages

The repository uses the form `type(scope): subject`. Allowed types are:

- `feat`
- `fix`
- `docs`
- `chore`

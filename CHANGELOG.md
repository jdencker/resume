# Changelog

## v0.4.0 - 2025-12-04


### Fixed
- include github tagging and releases in CI


## v0.3.0 - 2025-12-01


### Fixed
- changelog autogeneration script change
- remove excessive/duplicated linting from release workflow
- correct changelog and generation script
- change script to pick up on commit style; add fallback category in event of failures


## v0.2.0 - 2025-11-30

### Added
- finalize resume
- finalize layout, correct spelling errors
- add Dockerfile to build without local latex distribution; add docker commands to makefile

### Fixed
- change script to pick up on commit style; add fallback category in event of failures
- create pr instead of pushing directly to main in release workflow
- fix release scripts - version file initialization - changelog no longer prints empty
- introduce spelling error to see if pipeline catches mistake
- fix makefile lint target to display cvlint results properly
- fix regex pattern
- remove emoji characters
- use pre-built multiarch latex docker image instead of building via dockerfile
- remove unnecessary package bloat in preamble

### Chore
- v0.2.0
- add readme
- update ci to reflect new linting regime
- print spell errors in line number order, not alphabetical order
- setup local linting workflow; incorporate into makefile; update gitignore and requirements
- setup local python env for linting prior to CI; add make lint target
- setup initial CI wiring
- add setup script to ensure all dependencies and services are available
- add commit message linter

## v0.1.0 - 2025-11-25

### Added
- initial resume draft and layout

### Chore
- initial repository setup and CI/tooling scaffolding
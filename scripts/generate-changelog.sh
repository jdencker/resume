#!/bin/sh
set -e

if ! [ -f VERSION ]; then
  echo "VERSION file missing. Cannot generate changelog."
  exit 1
fi

VERSION=$(cat VERSION)
DATE=$(date +"%Y-%m-%d")

# Determine last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
  # No previous tags → use entire history
  RANGE=""
else
  RANGE="${LAST_TAG}..HEAD"
fi

# Extract commit messages following conventional commit structure.
COMMITS=$(git log --pretty=format:"%s" $RANGE)

ADDED=""
FIXED=""
DOCS=""
CHORE=""

# Classify commits
echo "$COMMITS" | while read -r LINE; do
  case "$LINE" in
    feat*)
      ADDED="${ADDED}\n- ${LINE#*: }"
      ;;
    fix*)
      FIXED="${FIXED}\n- ${LINE#*: }"
      ;;
    docs*)
      DOCS="${DOCS}\n- ${LINE#*: }"
      ;;
    chore*)
      CHORE="${CHORE}\n- ${LINE#*: }"
      ;;
  esac
done > .changelog.tmp

# Load results from the loop
ADDED=$(grep "^-" .changelog.tmp | grep -E "^[[:space:]]*-" | grep -i "feat"  || true)
FIXED=$(grep "^-" .changelog.tmp | grep -E "^[[:space:]]*-" | grep -i "fix"   || true)
DOCS=$(grep "^-" .changelog.tmp | grep -E "^[[:space:]]*-" | grep -i "docs"  || true)
CHORE=$(grep "^-" .changelog.tmp | grep -E "^[[:space:]]*-" | grep -i "chore" || true)
rm -f .changelog.tmp

# Build the new section
NEW_SECTION="## v${VERSION} - ${DATE}\n"

if [ -n "$ADDED" ]; then
  NEW_SECTION="${NEW_SECTION}\n### Added\n${ADDED}"
fi

if [ -n "$FIXED" ]; then
  NEW_SECTION="${NEW_SECTION}\n\n### Fixed\n${FIXED}"
fi

if [ -n "$DOCS" ]; then
  NEW_SECTION="${NEW_SECTION}\n\n### Documentation\n${DOCS}"
fi

if [ -n "$CHORE" ]; then
  NEW_SECTION="${NEW_SECTION}\n\n### Chore\n${CHORE}"
fi

NEW_SECTION="${NEW_SECTION}\n\n"

# Prepend to CHANGELOG.md
if [ -f CHANGELOG.md ]; then
  echo "$NEW_SECTION$(cat CHANGELOG.md)" > CHANGELOG.md
else
  echo -e "# Changelog\n\n${NEW_SECTION}" > CHANGELOG.md
fi

echo "CHANGELOG.md updated for v${VERSION}"
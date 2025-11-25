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

# Classify based on prefixes
echo "$COMMITS" | while read -r LINE; do
  case "$LINE" in
    feat:*)
      echo "ADDED: ${LINE#feat: }"
      ;;
    fix:*)
      echo "FIXED: ${LINE#fix: }"
      ;;
    docs:*)
      echo "DOCS: ${LINE#docs: }"
      ;;
    chore:*)
      echo "CHORE: ${LINE#chore: }"
      ;;
  esac
done > .changelog.tmp

# Parse the bucket file
ADDED=$(grep "^ADDED:" .changelog.tmp  | sed 's/^ADDED: /- /'  || true)
FIXED=$(grep "^FIXED:" .changelog.tmp  | sed 's/^FIXED: /- /'  || true)
DOCS=$(grep "^DOCS:"  .changelog.tmp  | sed 's/^DOCS: /- /'   || true)
CHORE=$(grep "^CHORE:" .changelog.tmp | sed 's/^CHORE: /- /'  || true)

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
  printf "%b\n%b" "$NEW_SECTION" "$(cat CHANGELOG.md)" > CHANGELOG.md
else
  printf "# Changelog\n\n%b" "$NEW_SECTION" > CHANGELOG.md
fi

echo "CHANGELOG.md updated for v${VERSION}"
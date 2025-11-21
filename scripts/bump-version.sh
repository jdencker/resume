#!/bin/sh
set -e

# Usage: ./bump-version.sh patch|minor|major

if [ $# -ne 1 ]; then
  echo "Usage: $0 {patch|minor|major}"
  exit 1
fi

BUMP_TYPE="$1"

if ! [ -f VERSION ]; then
  echo "VERSION file not found at the repo root."
  exit 1
fi

VERSION=$(cat VERSION)

# Parse X.Y.Z
MAJOR=$(echo "$VERSION" | awk -F. '{print $1}')
MINOR=$(echo "$VERSION" | awk -F. '{print $2}')
PATCH=$(echo "$VERSION" | awk -F. '{print $3}')

case "$BUMP_TYPE" in
  patch)
    PATCH=$((PATCH + 1))
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  *)
    echo "Invalid version bump: $BUMP_TYPE"
    echo "Valid options: patch, minor, major"
    exit 1
    ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
echo "$NEW_VERSION" > VERSION

echo "Version bumped: $VERSION → $NEW_VERSION"
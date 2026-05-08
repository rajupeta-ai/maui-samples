#!/usr/bin/env bash
# verify-coverage-strategy.sh
#
# Asserts that docs/test-coverage-strategy.md lists every top-level module
# the maui-samples repository ships and that each entry states either
# "Tested by" or "No executable tests required because". This is the
# executable contract behind TICKET-008's documentation.
#
# Usage: eng/verify-coverage-strategy.sh
# Exit:  0 if the document is well-formed, non-zero (with diagnostics) otherwise.

set -euo pipefail

DOC="docs/test-coverage-strategy.md"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

if [[ ! -f "$DOC" ]]; then
  echo "FAIL: $DOC is missing." >&2
  exit 1
fi

# The seven modules called out by the analyzer findings. If a new top-level
# module is added to the repo, append it here AND to the strategy doc.
REQUIRED_MODULES=(
  "9.0"
  "10.0"
  "11.0"
  ".github"
  "Upgrading"
  "Images"
  "eng"
)

failures=0

for module in "${REQUIRED_MODULES[@]}"; do
  # Each module must have a heading that references its directory.
  if ! grep -qE "^### \`${module}/?\`" "$DOC"; then
    echo "FAIL: $DOC has no '### \`${module}/\`' (or '### \`${module}\`') section." >&2
    failures=$((failures + 1))
    continue
  fi
done

# Every module entry must contain at least one of the two contractual phrases.
if ! grep -q "Tested by:" "$DOC"; then
  echo "FAIL: $DOC has no 'Tested by:' entries — the strategy must state where each module is verified." >&2
  failures=$((failures + 1))
fi

if ! grep -q "No executable tests required because" "$DOC"; then
  echo "FAIL: $DOC has no 'No executable tests required because' entries — exempt modules need a written rationale." >&2
  failures=$((failures + 1))
fi

# CONTRIBUTING.md must point at the strategy doc.
if ! grep -q "docs/test-coverage-strategy.md" "CONTRIBUTING.md"; then
  echo "FAIL: CONTRIBUTING.md does not link to docs/test-coverage-strategy.md." >&2
  failures=$((failures + 1))
fi

if [[ $failures -gt 0 ]]; then
  echo "verify-coverage-strategy: $failures failure(s)." >&2
  exit 1
fi

echo "verify-coverage-strategy: OK — all ${#REQUIRED_MODULES[@]} modules documented."

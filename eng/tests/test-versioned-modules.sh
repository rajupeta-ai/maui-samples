#!/usr/bin/env bash
#
# Portable test for the versioned-module wiring invariants asserted by
# eng/Verify-VersionedModules.ps1. Useful for local dev (no pwsh required)
# and as a CI sanity step on Linux runners.
#
# Invariants tested (from TICKET-001 acceptance criteria):
#   1. 11.0/ exists and contains at least one .csproj.
#   2. 11.0/Samples-11.0.sln exists.
#   3. Every 11.0/**/*.csproj is referenced in 11.0/Samples-11.0.sln.
#   4. The README audit table mentions each csproj at least once.
#   5. 9.0/ and 10.0/ each contain at least one .csproj (folders not deleted).
#
# Exits non-zero on any failure. Prints PASS / FAIL lines for each check.

set -u
# Note: we don't use -e because we want to collect every failure before exiting.

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
ELEVEN_DIR="$REPO_ROOT/11.0"
ELEVEN_SLN="$ELEVEN_DIR/Samples-11.0.sln"
ELEVEN_README="$ELEVEN_DIR/README.md"

failures=0
pass() { echo "PASS  $1"; }
fail() { echo "FAIL  $1"; failures=$((failures + 1)); }

# 1. 11.0 has at least one csproj.
csprojs=()
while IFS= read -r line; do csprojs+=("$line"); done < <(find "$ELEVEN_DIR" -type f -name '*.csproj' | LC_ALL=C sort)
if [ "${#csprojs[@]}" -gt 0 ]; then
    pass "11.0 module contains ${#csprojs[@]} csproj file(s)"
else
    fail "11.0 module contains zero csproj files"
fi

# 2. Top-level solution exists.
if [ -f "$ELEVEN_SLN" ]; then
    pass "Samples-11.0.sln exists"
else
    fail "Missing $ELEVEN_SLN"
fi

# 3. Every 11.0/**/*.csproj is in Samples-11.0.sln.
if [ -f "$ELEVEN_SLN" ]; then
    for csproj in "${csprojs[@]}"; do
        # Solution files store paths relative to the sln, with backslashes.
        rel_unix="${csproj#$ELEVEN_DIR/}"
        rel_win="${rel_unix//\//\\}"
        if grep -q -F "$rel_win" "$ELEVEN_SLN"; then
            pass "Samples-11.0.sln references $rel_unix"
        else
            fail "Samples-11.0.sln does NOT reference $rel_unix"
        fi
    done
fi

# 4. README mentions each csproj.
if [ -f "$ELEVEN_README" ]; then
    pass "11.0/README.md exists"
    for csproj in "${csprojs[@]}"; do
        rel_unix="${csproj#$ELEVEN_DIR/}"
        if grep -q -F "$rel_unix" "$ELEVEN_README"; then
            pass "README mentions $rel_unix"
        else
            fail "README missing entry for $rel_unix"
        fi
    done
else
    fail "Missing 11.0/README.md audit doc"
fi

# 5. 9.0 / 10.0 sanity (sibling modules not accidentally emptied).
for mod in 9.0 10.0; do
    count=$(find "$REPO_ROOT/$mod" -type f -name '*.csproj' 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
        pass "$mod module contains $count csproj file(s)"
    else
        fail "$mod module contains zero csproj files"
    fi
done

echo ""
if [ "$failures" -gt 0 ]; then
    echo "$failures check(s) failed."
    exit 1
fi
echo "All versioned-module invariants satisfied."
exit 0

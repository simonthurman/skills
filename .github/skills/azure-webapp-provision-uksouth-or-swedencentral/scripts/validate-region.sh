#!/usr/bin/env bash
set -euo pipefail

# validate-region.sh
# Validates and normalizes an Azure region input to the allowed set:
#   - uksouth (UK South)
#   - swedencentral (Sweden Central)
#
# Usage:
#   ./scripts/validate-region.sh "<region>"
#
# Output (stdout):
#   Prints the normalized Azure location code: uksouth|swedencentral
#
# Exit codes:
#   0 = valid
#   2 = invalid / not allowed
#   64 = usage error

usage() {
  echo "Usage: $0 \"<region>\"" >&2
  echo "Allowed regions: uksouth (UK South), swedencentral (Sweden Central)" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 64
fi

raw="$1"

# Normalize: lowercase, remove leading/trailing whitespace, remove spaces/hyphens/underscores for matching
trimmed="$(echo "$raw" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
lower="$(echo "$trimmed" | tr '[:upper:]' '[:lower:]')"
key="$(echo "$lower" | tr -d ' _-')"

case "$key" in
  # UK South variants
  uksouth|uksouthregion|unitedkingdomsouth|uksouthazure|uksouthuk|uksouthgb|uksouthengland|uksouthlondon|uksouthuk*)
    echo "uksouth"
    exit 0
    ;;

  # Sweden Central variants
  swedencentral|swedencentralregion|secentral|swedencentralazure|swedencentral*)
    echo "swedencentral"
    exit 0
    ;;

  # Common display-name inputs
  "uk south"|"uk south region"|"sweden central"|"sweden central region")
    # (These are technically already handled by the 'key' normalization,
    #  but kept for readability in case you expand logic later.)
    ;;
esac

# If not matched by allowlist:
echo "ERROR: Region '$raw' is not allowed by this skill." >&2
echo "Only these regions are permitted:" >&2
echo "  - UK South (uksouth)" >&2
echo "  - Sweden Central (swedencentral)" >&2
exit 2

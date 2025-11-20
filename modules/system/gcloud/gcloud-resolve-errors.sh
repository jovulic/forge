# shellcheck shell=bash

# 1. ARGUMENT PARSING
# -------------------
PROJECT_ID=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
    -d | --dry-run)
        DRY_RUN=true
        shift
        ;;
    *)
        if [ -z "$PROJECT_ID" ]; then
            PROJECT_ID="$1"
        else
            echo "Unknown argument: $1"
            echo "Usage: ./resolve_errors_final.sh <PROJECT_ID> [-d|--dry-run]"
            exit 1
        fi
        shift
        ;;
    esac
done

if [ -z "$PROJECT_ID" ]; then
    echo "Error: No Project ID provided."
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "Error: 'jq' is not installed."
    exit 1
fi

# 2. SETUP
# --------
TOKEN=$(gcloud auth print-access-token)
PAGE_TOKEN=""
TEMP_FILE=$(mktemp)
TOTAL_FOUND=0
CURRENT_COUNT=0
trap 'rm -f "$TEMP_FILE"' EXIT

echo "Targeting Project: $PROJECT_ID"
echo "--- PHASE 1: Scanning for errors (Collection) ---"

# 3. COLLECTION PHASE
# -------------------
while :; do
    BASE_URL="https://clouderrorreporting.googleapis.com/v1beta1/projects/$PROJECT_ID/groupStats?timeRange.period=PERIOD_30_DAYS"

    if [ -n "$PAGE_TOKEN" ]; then
        URL="${BASE_URL}&pageToken=${PAGE_TOKEN}"
    else
        URL="${BASE_URL}"
    fi

    RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "$URL")

    if echo "$RESPONSE" | grep -q '"error":'; then
        echo "CRITICAL: API Error encountered during scan:"
        echo "$RESPONSE" | jq .
        exit 1
    fi

    # Collect IDs (filtering out already RESOLVED).
    NEW_IDS=$(echo "$RESPONSE" | jq -r '.errorGroupStats[]? | select(.group.resolutionStatus != "RESOLVED") | .group.name')

    if [ -n "$NEW_IDS" ]; then
        echo "$NEW_IDS" >>"$TEMP_FILE"
        BATCH_COUNT=$(echo "$NEW_IDS" | wc -l | tr -d ' ')
        ((TOTAL_FOUND += BATCH_COUNT))
        echo "   ...found $BATCH_COUNT errors."
    else
        echo "   ...scanning page (clean)."
    fi

    PAGE_TOKEN=$(echo "$RESPONSE" | jq -r '.nextPageToken // empty')
    if [ -z "$PAGE_TOKEN" ]; then break; fi
done

echo "Scan complete. Total open errors: $TOTAL_FOUND"
echo "------------------------------------------------"

if [ "$TOTAL_FOUND" -eq 0 ]; then
    echo "No errors to resolve."
    exit 0
fi

# 4. EXECUTION PHASE
# ------------------
if [ "$DRY_RUN" = true ]; then
    echo "--- DRY RUN MODE: No changes will be made ---"
else
    echo "--- LIVE MODE: Attempting to resolve errors ---"
fi

while read -r GROUP_NAME; do
    ((CURRENT_COUNT++))
    # Get just the short ID for cleaner printing.
    SHORT_ID=${GROUP_NAME##*/}

    if [ "$DRY_RUN" = true ]; then
        echo "[$CURRENT_COUNT/$TOTAL_FOUND] [DRY-RUN] Would resolve: $SHORT_ID"
    else
        echo -n "[$CURRENT_COUNT/$TOTAL_FOUND] Resolving $SHORT_ID... "

        # Perform PUT request, capture HTTP code at the end
        HTTP_RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"resolutionStatus": "RESOLVED"}' \
            "https://clouderrorreporting.googleapis.com/v1beta1/$GROUP_NAME")

        # Split body and status code
        HTTP_BODY=$(echo "$HTTP_RESPONSE" | head -n -1)
        HTTP_CODE=$(echo "$HTTP_RESPONSE" | tail -n 1)

        if [ "$HTTP_CODE" -eq 200 ]; then
            echo "✅ [OK 200]"
        else
            echo "❌ [FAILED: $HTTP_CODE]"
            echo "   Error Details: $HTTP_BODY"
        fi

        sleep 0.2
    fi
done <"$TEMP_FILE"

echo "------------------------------------------------"
echo "Done."

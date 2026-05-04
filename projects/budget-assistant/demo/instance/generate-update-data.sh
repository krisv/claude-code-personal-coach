#!/bin/bash
# Generate follow-up budget request data
# Run this AFTER processing initial requests to show Montgomery handling updates

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Read configuration
API_KEY=$(grep 'api_key:' "$SCRIPT_DIR/config.yaml" | awk '{print $2}' | tr -d '"')
SERVICE_PORT=$(grep 'SERVICE_PORT=' "$SCRIPT_DIR/start.sh" | head -1 | cut -d'=' -f2 | tr -d '"')
API_URL="http://localhost:$SERVICE_PORT/api/news"

echo "========================================="
echo "Generating Follow-Up Budget Requests"
echo "========================================="
echo "API URL: $API_URL"
echo ""

# Helper function
post_news() {
    local title="$1"
    local content="$2"
    local labels="$3"
    local timestamp="$4"

    local response=$(curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -H "X-API-Key: $API_KEY" \
        -d @- <<EOF
{
    "title": "$title",
    "content": "$content",
    "labels": [$labels],
    "timestamp": "$timestamp"
}
EOF
    )

    if echo "$response" | grep -q '"id"'; then
        echo "✓ Posted: $title"
    else
        echo "✗ Failed: $title"
    fi
}

TODAY=$(date -u +"%Y-%m-%dT12:00:00Z")

echo "Creating follow-up budget requests..."
echo ""

# Follow-up Request 1: Bob Smith - Revised laptop request (split amount)
post_news \
    "Budget Request: Bob Smith - Monitor + Accessories (Revised)" \
    "**Employee:** Bob Smith
**Amount:** \$400
**Category:** Equipment
**Justification:** Following feedback on my laptop request, I'm breaking this into smaller purchases. Starting with an external monitor and accessories this month, will request remaining equipment next month.

**Details:**
- 27\" 4K monitor: \$300
- Mechanical keyboard: \$70
- Ergonomic mouse: \$30
- Total: \$400

**Note:** This is a revised approach to address my development setup needs within budget." \
    "\"type:budget-request\", \"employee:bob-smith\", \"category:equipment\", \"amount:400\"" \
    "$TODAY"

# Follow-up Request 2: Alice Johnson - Additional travel for same conference
post_news \
    "Budget Request: Alice Johnson - PyCon Hotel Accommodation" \
    "**Employee:** Alice Johnson
**Amount:** \$600
**Category:** Travel
**Justification:** Hotel accommodation for PyCon conference (May 15-20). Conference registration was already approved. Need 4 nights at conference hotel.

**Details:**
- Conference hotel: \$150/night × 4 nights = \$600
- Conference dates: May 15-20
- Previous approved: \$250 (registration)
- Total conference cost: \$850" \
    "\"type:budget-request\", \"employee:alice-johnson\", \"category:travel\", \"amount:600\"" \
    "$TODAY"

# Follow-up Request 3: Emma Wilson - Additional AWS resource
post_news \
    "Budget Request: Emma Wilson - AWS Practice Labs" \
    "**Employee:** Emma Wilson
**Amount:** \$59
**Category:** Training
**Justification:** Hands-on practice labs to complement the AWS Solutions Architect bootcamp. These labs provide real AWS environment experience.

**Details:**
- AWS practice lab subscription: \$59/month (1 month)
- Includes 50+ hands-on labs
- Complements bootcamp training
- Previous approved: \$599 (bootcamp)" \
    "\"type:budget-request\", \"employee:emma-wilson\", \"category:training\", \"amount:59\"" \
    "$TODAY"

echo ""
echo "========================================="
echo "✓ Follow-Up Budget Requests Generated!"
echo "========================================="
echo ""
echo "Created 3 follow-up requests:"
echo "  1. Bob Smith - \$400 (Monitor + Accessories) - Revised request"
echo "  2. Alice Johnson - \$600 (Hotel) - Would total \$850 with previous"
echo "  3. Emma Wilson - \$59 (Practice labs) - Would total \$658 with previous"
echo ""
echo "Scenarios to test:"
echo "  - Bob: Should approve (within \$1000 after first denial)"
echo "  - Alice: Should deny (total \$850 exceeds budget if \$250 approved)"
echo "  - Emma: Should flag/review (total \$658, large training spend)"
echo ""
echo "Next: Process these in Montgomery and see updated budget tracking"
echo ""

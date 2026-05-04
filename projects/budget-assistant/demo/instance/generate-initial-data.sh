#!/bin/bash
# Generate initial demo data
# CUSTOMIZE THIS with your scenario-specific data!

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Read configuration
API_KEY=$(grep 'api_key:' "$SCRIPT_DIR/config.yaml" | awk '{print $2}' | tr -d '"')
SERVICE_PORT=$(grep 'SERVICE_PORT=' "$SCRIPT_DIR/start.sh" | head -1 | cut -d'=' -f2 | tr -d '"')
API_URL="http://localhost:$SERVICE_PORT/api/news"

echo "========================================="
echo "Generating Demo Data"
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

echo "Creating budget request data..."
echo ""

# Budget Request 1: Alice Johnson - Small within-budget travel request (SHOULD APPROVE)
post_news \
    "Budget Request: Alice Johnson - Conference Registration" \
    "**Employee:** Alice Johnson
**Amount:** \$250
**Category:** Travel
**Justification:** Registration fee for PyCon 2026. This is a key Python conference that will help me stay current with latest frameworks and best practices. The conference is May 15-20 in Pittsburgh.

**Details:**
- Early bird registration: \$250
- Relevant to our Python microservices work
- Opportunity to network with other Python developers" \
    "\"type:budget-request\", \"employee:alice-johnson\", \"category:travel\", \"amount:250\"" \
    "$TODAY"

# Budget Request 2: Bob Smith - Large equipment request that exceeds budget (SHOULD DENY)
post_news \
    "Budget Request: Bob Smith - MacBook Pro" \
    "**Employee:** Bob Smith
**Amount:** \$2400
**Category:** Equipment
**Justification:** My current laptop is 5 years old and struggling with our development environment. I need a new MacBook Pro M3 to handle multiple Docker containers and IDEs efficiently.

**Details:**
- MacBook Pro 14\" M3 Pro
- 18GB RAM, 512GB SSD
- Critical for development work
- Current laptop frequently crashes" \
    "\"type:budget-request\", \"employee:bob-smith\", \"category:equipment\", \"amount:2400\"" \
    "$TODAY"

# Budget Request 3: Carol Davis - Software subscription (SHOULD APPROVE)
post_news \
    "Budget Request: Carol Davis - JetBrains All Products Pack" \
    "**Employee:** Carol Davis
**Amount:** \$149
**Category:** Software
**Justification:** Annual subscription to JetBrains All Products Pack. I use IntelliJ IDEA for Java development and PyCharm for Python. This subscription covers both plus other tools.

**Details:**
- Annual license: \$149
- Covers IntelliJ IDEA, PyCharm, WebStorm
- Individual license (not commercial)
- Renewal for existing subscription" \
    "\"type:budget-request\", \"employee:carol-davis\", \"category:software\", \"amount:149\"" \
    "$TODAY"

# Budget Request 4: David Martinez - Training course (SHOULD APPROVE)
post_news \
    "Budget Request: David Martinez - Kubernetes Certification Training" \
    "**Employee:** David Martinez
**Amount:** \$399
**Category:** Training
**Justification:** Certified Kubernetes Administrator (CKA) exam prep course. We're migrating more services to Kubernetes and this certification will help me better support our infrastructure.

**Details:**
- Linux Foundation CKA course: \$399
- Includes practice exams
- Certification exam included
- Aligns with Q2 infrastructure goals" \
    "\"type:budget-request\", \"employee:david-martinez\", \"category:training\", \"amount:399\"" \
    "$TODAY"

# Budget Request 5: Emma Wilson - Large training that's borderline (SHOULD APPROVE with note)
post_news \
    "Budget Request: Emma Wilson - AWS Solutions Architect Bootcamp" \
    "**Employee:** Emma Wilson
**Amount:** \$599
**Category:** Training
**Justification:** 3-day AWS Solutions Architect bootcamp with certification exam. Our team is expanding AWS usage and I'm leading the cloud architecture efforts. This will formalize my AWS knowledge.

**Details:**
- 3-day intensive bootcamp: \$599
- Includes AWS Solutions Architect Associate exam
- Online format (no travel costs)
- Scheduled for May 10-12" \
    "\"type:budget-request\", \"employee:emma-wilson\", \"category:training\", \"amount:599\"" \
    "$TODAY"

echo ""
echo "========================================="
echo "✓ Budget Request Data Generated!"
echo "========================================="
echo ""
echo "Created 5 budget requests:"
echo "  1. Alice Johnson - \$250 (Conference) - Within budget"
echo "  2. Bob Smith - \$2400 (Laptop) - EXCEEDS budget"
echo "  3. Carol Davis - \$149 (Software) - Within budget"
echo "  4. David Martinez - \$399 (Training) - Within budget"
echo "  5. Emma Wilson - \$599 (Training) - Large but within budget"
echo ""
echo "Total if all approved: \$3797"
echo "Expected approvals (excluding Bob): \$1397"
echo ""
echo "Next: Launch Montgomery agent and process requests"
echo ""

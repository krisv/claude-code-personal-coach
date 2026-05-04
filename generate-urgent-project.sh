#!/bin/bash
# Generate initial data for Personal Coach testing
# Posts 3 messages about Agent Stewart project assignment

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Read API key from .apikey file
if [ -f "$SCRIPT_DIR/.apikey" ]; then
    API_KEY=$(grep '^API_KEY=' "$SCRIPT_DIR/.apikey" | cut -d'=' -f2)
else
    echo "Error: .apikey file not found"
    exit 1
fi

# Default port for news service
SERVICE_PORT="8414"
API_URL="http://localhost:$SERVICE_PORT/api/news"

echo "========================================="
echo "Generating Agent Stewart Project Data"
echo "========================================="
echo ""
echo "API URL: $API_URL"
echo "Generating: 3 messages"
echo ""

# Helper function to post news
post_news() {
    local title="$1"
    local content="$2"
    local labels="$3"
    local timestamp="$4"

    local response=$(curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -H "X-API-KEY: $API_KEY" \
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
        echo "  Response: $response"
    fi
}

# Calculate dates
# Message 1: Yesterday (urgent meeting request for next working day 9am)
# Message 2: Today 10am (meeting summary)
# Message 3: Today 10:35am (project details)
MSG1_DATE=$(date -d "1 day ago" -u +"%Y-%m-%dT16:00:00Z" 2>/dev/null || date -u -v-1d +"%Y-%m-%dT16:00:00Z" 2>/dev/null || echo "2026-04-22T16:00:00Z")
MSG2_DATE=$(date -u +"%Y-%m-%dT10:00:00Z" 2>/dev/null || echo "2026-04-23T10:00:00Z")
MSG3_DATE=$(date -u +"%Y-%m-%dT10:35:00Z" 2>/dev/null || echo "2026-04-23T10:35:00Z")

echo "Message 1 date: $MSG1_DATE"
echo "Message 2 date: $MSG2_DATE"
echo "Message 3 date: $MSG3_DATE"
echo ""
echo "Posting messages..."
echo ""

# Message 1: Urgent meeting request from manager
post_news \
    "Urgent Meeting Request from Manager" \
    "My manager requested an urgent meeting at 9am to discuss a critical new project opportunity.

This appears to be time-sensitive and important." \
    "\"type:meeting-request\", \"priority:urgent\"" \
    "$MSG1_DATE"

# Message 2: Meeting summary - new project assignment
post_news \
    "Meeting Summary: Agent Stewart Project Assignment" \
    "Just finished meeting with my manager about a critical new project.

**Key Points:**
- Red Hat is launching a new personal agent initiative called Agent Stewart
- I'm being assigned to this project for the next 3 weeks
- Requires at least 75% of my time commitment
- Need to clear my schedule and reprioritize other work

**Immediate Actions:**
- Review project collateral materials ASAP
- Attend kickoff meeting tomorrow
- Assess impact on current commitments and communicate with stakeholders
- **BLOG POST:** Create a blog draft about Agent Stewart immediately - I want to share what we're building and explain how this personal productivity agent will help automate repetitive work across Red Hat. Use the /blog-draft skill to create it now.

This is a high-visibility project with executive sponsorship. Need to make this my top priority." \
    "\"type:meeting-summary\", \"project:Agent Stewart\", \"priority:high\", \"duration:3-weeks\"" \
    "$MSG2_DATE"

# Message 3: Agent Stewart project details
post_news \
    "Agent Stewart: Project Overview and Context" \
    "Did some research on Agent Stewart after this morning's meeting. Here's what this project is about:

**Project Vision:**
Agent Stewart is Red Hat's new personal productivity agent focused on automating repetitive work for employees across the organization.

**Core Capabilities:**
- Automated email triage and response drafting
- Meeting scheduling and calendar optimization
- Task extraction from communications
- Document summarization and research
- Integration with Red Hat's internal tools (Jira, Confluence, email)

**Project Goals:**
- Demonstrate value of AI-powered personal assistants in enterprise
- Build reusable agent framework for other Red Hat automation use cases
- Pilot with 100 employees by end of Q2
- Public announcement at Red Hat Summit if pilot is successful

**My Role:**
Lead technical implementation for the next 3 weeks (75% time allocation) to get the core agent capabilities working and prepare for pilot launch.

**Timeline:**
- **Kickoff Meeting:** Tomorrow
- **Read collateral materials:** ASAP (this week)
- **Pilot Launch Target:** 12 weeks from now

**Why Agent Stewart?**
Named after the legendary actor James Stewart - representing a trusted, helpful, and reliable assistant.

This is a high-visibility project with potential for significant impact across Red Hat. Excited but also need to quickly ramp up and deliver." \
    "\"type:project-details\", \"project:Agent Stewart\", \"company:Red Hat\", \"focus:automation\"" \
    "$MSG3_DATE"

echo ""
echo "========================================="
echo "✓ Data Generation Complete!"
echo "========================================="
echo ""
echo "Created:"
echo "  - 3 messages about Agent Stewart project"
echo ""
echo "Messages:"
echo "  1. Urgent meeting request from manager"
echo "  2. Meeting summary - project assignment"
echo "  3. Agent Stewart project details"
echo ""


#!/bin/bash
# Create a complete demo with project structure
# Usage: ./create-demo.sh <project-name> [service-port] [db-port]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Check arguments
if [ -z "$1" ]; then
    echo "Usage: $0 <project-name> [service-port] [db-port]"
    echo ""
    echo "Example: $0 budget-assistant 8090 15440"
    echo ""
    echo "This will create:"
    echo "  projects/<project-name>/demo/instance/    - News service instance"
    echo "  projects/<project-name>/demo/agent/       - Agent project"
    echo "  projects/<project-name>/demo/README.md    - Demo documentation"
    exit 1
fi

PROJECT_NAME="$1"
SERVICE_PORT="${2:-$((8080 + RANDOM % 920))}"
DB_PORT="${3:-$((15432 + RANDOM % 568))}"

DEMO_DIR="$WORKSPACE_ROOT/projects/$PROJECT_NAME/demo"
INSTANCE_NAME="${PROJECT_NAME}-instance"
AGENT_NAME="${PROJECT_NAME}-agent"

echo "========================================="
echo "Creating Complete Demo Project"
echo "========================================="
echo "Project: $PROJECT_NAME"
echo "Demo directory: $DEMO_DIR"
echo "Service port: $SERVICE_PORT"
echo "Database port: $DB_PORT"
echo ""

# Check if demo directory already exists
if [ -d "$DEMO_DIR" ]; then
    echo "Error: Demo directory already exists at $DEMO_DIR"
    exit 1
fi

# Create demo directory structure
echo "Creating demo directory structure..."
mkdir -p "$DEMO_DIR/instance"
mkdir -p "$DEMO_DIR/agent"
echo "✓ Created $DEMO_DIR"
echo ""

# Get absolute paths
INSTANCE_DIR="$DEMO_DIR/instance"
AGENT_DIR="$DEMO_DIR/agent"

# Create instance using the same logic as create-instance.sh
echo "Creating news service instance..."

DB_USER="newsuser"
DB_PASSWORD=$(python3 -c "import secrets; print(secrets.token_urlsafe(16))" 2>/dev/null || openssl rand -base64 16 | tr -d '\n')
API_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))" 2>/dev/null || openssl rand -base64 32 | tr -d '\n')

# Create config file
cat > "$INSTANCE_DIR/config.yaml" <<EOF
# News Service Configuration for $INSTANCE_NAME
# Auto-generated on $(date)

database:
  host: host.docker.internal
  port: $DB_PORT
  database: $INSTANCE_NAME
  username: $DB_USER
  password: $DB_PASSWORD
  min_connections: 1
  max_connections: 10
  connection_timeout: 5
  max_retries: 3

security:
  api_key: "$API_KEY"
EOF
echo "✓ Config created: instance/config.yaml"

# Create schema.sql in instance directory
cat > "$INSTANCE_DIR/schema.sql" <<'EOFSCHEMA'
-- News Service Database Schema
-- PostgreSQL 12+

-- News items table
CREATE TABLE IF NOT EXISTS news_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    source_url TEXT,
    labels TEXT[] DEFAULT '{}',
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    news_id UUID NOT NULL REFERENCES news_items(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    content TEXT NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_news_items_timestamp ON news_items(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_news_items_labels ON news_items USING GIN(labels);
CREATE INDEX IF NOT EXISTS idx_news_items_source_url ON news_items(source_url) WHERE source_url IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_comments_news_id ON comments(news_id);
CREATE INDEX IF NOT EXISTS idx_comments_timestamp ON comments(timestamp DESC);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_news_items_updated_at ON news_items;
CREATE TRIGGER update_news_items_updated_at
    BEFORE UPDATE ON news_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
EOFSCHEMA
echo "✓ Schema created: instance/schema.sql"

# Create start script
cat > "$INSTANCE_DIR/start.sh" <<EOFSTART
#!/bin/bash
# Start news service instance: $INSTANCE_NAME

set -e

SCRIPT_DIR="\$(cd "\$(dirname "\$0")" && pwd)"
INSTANCE_NAME="$INSTANCE_NAME"
DB_CONTAINER="postgres-\${INSTANCE_NAME}"
SERVICE_CONTAINER="news-service-\${INSTANCE_NAME}"
DB_VOLUME="postgres-data-\${INSTANCE_NAME}"
DB_PORT="$DB_PORT"
SERVICE_PORT="$SERVICE_PORT"
DB_USER="$DB_USER"
DB_PASSWORD="$DB_PASSWORD"
SCHEMA_FILE="\$SCRIPT_DIR/schema.sql"

echo "========================================="
echo "Starting News Service: \$INSTANCE_NAME"
echo "========================================="
echo ""

# Check if this is first run
FIRST_RUN=false
if ! docker volume inspect "\$DB_VOLUME" > /dev/null 2>&1; then
    FIRST_RUN=true
    echo "Creating Docker volume: \$DB_VOLUME"
    docker volume create "\$DB_VOLUME"
fi

# Stop existing containers
if docker ps -a --format '{{.Names}}' | grep -q "^\${DB_CONTAINER}\$"; then
    echo "Stopping existing database container..."
    docker stop "\$DB_CONTAINER" 2>/dev/null || true
    docker rm "\$DB_CONTAINER" 2>/dev/null || true
fi

if docker ps -a --format '{{.Names}}' | grep -q "^\${SERVICE_CONTAINER}\$"; then
    echo "Stopping existing service container..."
    docker stop "\$SERVICE_CONTAINER" 2>/dev/null || true
    docker rm "\$SERVICE_CONTAINER" 2>/dev/null || true
fi

# Start PostgreSQL
echo "Starting PostgreSQL container..."
docker run -d \\
    --name "\$DB_CONTAINER" \\
    -p "\$DB_PORT:5432" \\
    -v "\$DB_VOLUME:/var/lib/postgresql/data" \\
    -e POSTGRES_USER="\$DB_USER" \\
    -e POSTGRES_PASSWORD="\$DB_PASSWORD" \\
    -e POSTGRES_DB="\$INSTANCE_NAME" \\
    postgres:16-alpine

echo "✓ PostgreSQL started on port \$DB_PORT"
echo ""

# Wait for PostgreSQL
echo "Waiting for PostgreSQL..."
for i in {1..30}; do
    if docker exec "\$DB_CONTAINER" pg_isready -U "\$DB_USER" > /dev/null 2>&1; then
        echo "✓ PostgreSQL is ready"
        break
    fi
    if [ \$i -eq 30 ]; then
        echo "Error: PostgreSQL failed to start"
        docker logs "\$DB_CONTAINER"
        exit 1
    fi
    sleep 1
done
echo ""

# Initialize schema on first run
if [ "\$FIRST_RUN" = true ]; then
    echo "Initializing database schema..."
    docker exec -i "\$DB_CONTAINER" psql -U "\$DB_USER" -d "\$INSTANCE_NAME" < "\$SCHEMA_FILE"
    echo "✓ Schema initialized"
else
    echo "Using existing database data"
fi
echo ""

# Start news service
echo "Starting news service..."
docker run -d \\
    --name "\$SERVICE_CONTAINER" \\
    --add-host host.docker.internal:host-gateway \\
    -p "\$SERVICE_PORT:8080" \\
    -v "\$SCRIPT_DIR/config.yaml:/app/config.yaml:ro" \\
    -e API_KEY="\$(<"\$SCRIPT_DIR/config.yaml" grep 'api_key:' | awk '{print \$2}' | tr -d '"')" \\
    quay.io/krisv/news-service:latest

echo "✓ Service started on port \$SERVICE_PORT"
echo ""

echo "========================================="
echo "Instance Started Successfully!"
echo "========================================="
echo ""
echo "Service URL:  http://localhost:\$SERVICE_PORT"
echo "Database:     localhost:\$DB_PORT"
echo "API Key:      \$(<"\$SCRIPT_DIR/config.yaml" grep 'api_key:' | awk '{print \$2}' | tr -d '"')"
echo ""
EOFSTART

chmod +x "$INSTANCE_DIR/start.sh"
echo "✓ Created instance/start.sh"

# Create stop script
cat > "$INSTANCE_DIR/stop.sh" <<'EOFSTOP'
#!/bin/bash
set -e
INSTANCE_NAME="INSTANCE_NAME_PLACEHOLDER"
docker stop "postgres-${INSTANCE_NAME}" "news-service-${INSTANCE_NAME}" 2>/dev/null || true
docker rm "postgres-${INSTANCE_NAME}" "news-service-${INSTANCE_NAME}" 2>/dev/null || true
echo "✓ Instance stopped"
EOFSTOP

sed -i "s/INSTANCE_NAME_PLACEHOLDER/$INSTANCE_NAME/g" "$INSTANCE_DIR/stop.sh"
chmod +x "$INSTANCE_DIR/stop.sh"
echo "✓ Created instance/stop.sh"

# Create status script
cat > "$INSTANCE_DIR/status.sh" <<'EOFSTATUS'
#!/bin/bash
INSTANCE_NAME="INSTANCE_NAME_PLACEHOLDER"
echo "Instance Status: $INSTANCE_NAME"
echo "Database: $(docker ps --filter "name=postgres-$INSTANCE_NAME" --format '{{.Status}}' || echo 'Not running')"
echo "Service: $(docker ps --filter "name=news-service-$INSTANCE_NAME" --format '{{.Status}}' || echo 'Not running')"
EOFSTATUS

sed -i "s/INSTANCE_NAME_PLACEHOLDER/$INSTANCE_NAME/g" "$INSTANCE_DIR/status.sh"
chmod +x "$INSTANCE_DIR/status.sh"
echo "✓ Created instance/status.sh"

# Create clean script
cat > "$INSTANCE_DIR/clean.sh" <<'EOFCLEAN'
#!/bin/bash
# Clean/reset news service instance: INSTANCE_NAME_PLACEHOLDER
# WARNING: This will delete all database data!

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTANCE_NAME="INSTANCE_NAME_PLACEHOLDER"
DB_CONTAINER="postgres-${INSTANCE_NAME}"
SERVICE_CONTAINER="news-service-${INSTANCE_NAME}"
DB_VOLUME="postgres-data-${INSTANCE_NAME}"

echo "========================================="
echo "Clean Instance: $INSTANCE_NAME"
echo "========================================="
echo ""
echo "⚠️  WARNING: This will DELETE ALL DATA!"
echo ""
echo "Docker volume: $DB_VOLUME"
echo ""
read -p "Are you sure? Type 'yes' to continue: " -r
echo ""

if [ "$REPLY" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

# Stop containers first
echo "Stopping containers..."
"$SCRIPT_DIR/stop.sh"
echo ""

# Remove Docker volume
if docker volume inspect "$DB_VOLUME" > /dev/null 2>&1; then
    echo "Deleting Docker volume..."
    docker volume rm "$DB_VOLUME"
    echo "✓ Data deleted"
else
    echo "⚠ Docker volume not found"
fi

echo ""
echo "✓ Instance cleaned"
echo ""
echo "The instance has been reset to initial state."
echo "Run start.sh to create a fresh database."
EOFCLEAN

sed -i "s/INSTANCE_NAME_PLACEHOLDER/$INSTANCE_NAME/g" "$INSTANCE_DIR/clean.sh"
chmod +x "$INSTANCE_DIR/clean.sh"
echo "✓ Created instance/clean.sh"

# Create generate-initial-data.sh template
cat > "$INSTANCE_DIR/generate-initial-data.sh" <<'EOFDATA'
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

echo "Creating demo data..."
echo ""

# NOTE: Use $TODAY for all timestamps for cross-platform compatibility
# Avoid date arithmetic (e.g., 'date -d "2 hours ago"') - it fails on Windows Git Bash
# If you need different timestamps, use ISO format strings directly

# TODO: Customize with your demo data!

post_news \
    "Demo Data Ready" \
    "This is a template. Customize generate-initial-data.sh with your scenario-specific news items." \
    "\"type:demo\"" \
    "$TODAY"

echo ""
echo "✓ Demo data generated"
echo "Remember to customize this script!"
EOFDATA

chmod +x "$INSTANCE_DIR/generate-initial-data.sh"
echo "✓ Created instance/generate-initial-data.sh (customize this!)"
echo ""

# Create agent project
echo "Creating agent project..."

mkdir -p "$AGENT_DIR/.claude/skills"
mkdir -p "$AGENT_DIR/data"
mkdir -p "$AGENT_DIR/logs"

# Copy skills
cp -r "$WORKSPACE_ROOT/.claude/skills/log" "$AGENT_DIR/.claude/skills/"
cp -r "$WORKSPACE_ROOT/.claude/skills/redhat-news" "$AGENT_DIR/.claude/skills/"
echo "✓ Copied skills"

# Patch news_monitor.py to read from .newsservice file instead of hardcoded URL
NEWS_MONITOR_FILE="$AGENT_DIR/.claude/skills/redhat-news/news_monitor.py"
python3 -c "
import sys
content = open('$NEWS_MONITOR_FILE').read()
content = content.replace(
    'NEWS_SERVICE_BASE_URL = \"http://localhost:8414/\"',
    '''# Read news service URL from .newsservice file
NEWSSERVICE_FILE = SCRIPT_DIR.parent.parent.parent / \".newsservice\"
if NEWSSERVICE_FILE.exists():
    NEWS_SERVICE_BASE_URL = NEWSSERVICE_FILE.read_text().strip()
    if not NEWS_SERVICE_BASE_URL.endswith(\"/\"):
        NEWS_SERVICE_BASE_URL += \"/\"
else:
    NEWS_SERVICE_BASE_URL = \"http://localhost:8414/\"  # Fallback'''
)
open('$NEWS_MONITOR_FILE', 'w').write(content)
"
echo "✓ Patched news_monitor.py to use .newsservice file"

# Copy core files
cp "$WORKSPACE_ROOT/news_retriever.py" "$AGENT_DIR/"
cp "$WORKSPACE_ROOT/preferences.md" "$AGENT_DIR/"
cp "$WORKSPACE_ROOT/.claude/settings.local.json" "$AGENT_DIR/.claude/" 2>/dev/null || true
echo "✓ Copied core files"

# Create .apikey and .newsservice
echo "$API_KEY" > "$AGENT_DIR/.apikey"
echo "http://localhost:$SERVICE_PORT" > "$AGENT_DIR/.newsservice"
echo "✓ Created .apikey and .newsservice"

# Create CLAUDE.md
cat > "$AGENT_DIR/CLAUDE.md" <<'EOFCLAUDE'
@AGENTS.md

**Note:** Customize AGENTS.md to define agent behavior for your demo scenario.
EOFCLAUDE
echo "✓ Created CLAUDE.md"

# Create template AGENTS.md
cat > "$AGENT_DIR/AGENTS.md" <<'EOFAGENTS'
# Demo Agent

Customize this file to define your agent's behavior.

## Agent Name

**Demo Agent** - Use this exact name for logging and memory operations.

## Scenario

[Describe your scenario here]

## Core Context Files

The agent maintains these files in `data/`:

[Define your data structure here]

## Instructions

### When Asked: "Process new updates"

1. Fetch updates using news_retriever.py
2. Read current context files
3. Analyze updates and extract relevant information
4. Update context files
5. Generate overview
6. Provide recommendations
7. Update memory

## Processing Guidelines

[Define how to process updates for your scenario]
EOFAGENTS
echo "✓ Created AGENTS.md template"

# Create .gitignore
cat > "$AGENT_DIR/.gitignore" <<'EOFGITIGNORE'
.apikey
.newsservice
logs/
__pycache__/
*.pyc
.env
EOFGITIGNORE
echo "✓ Created .gitignore"

# Create dashboard template
cat > "$AGENT_DIR/dashboard.html" <<'EOFDASHBOARD'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agent Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: #f5f6f8;
            min-height: 100vh;
            padding: 0;
            margin: 0;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        .header {
            background: white;
            padding: 20px 30px;
            margin: -20px -20px 20px -20px;
            border-bottom: 1px solid #e0e0e0;
        }

        .header h1 {
            color: #2c3e50;
            font-size: 1.8em;
            margin-bottom: 5px;
            font-weight: 600;
        }

        .header p {
            color: #7f8c8d;
            font-size: 0.95em;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .stat-card {
            background: white;
            padding: 25px 30px;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
            border: 1px solid #e8e8e8;
        }

        .stat-card h3 {
            color: #95a5a6;
            font-size: 0.85em;
            font-weight: 500;
            margin-bottom: 15px;
            text-transform: none;
            letter-spacing: 0;
        }

        .stat-card .value {
            font-size: 2.2em;
            font-weight: 600;
            color: #2c3e50;
        }

        .section {
            background: white;
            padding: 25px 30px;
            border-radius: 4px;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
            border: 1px solid #e8e8e8;
        }

        .section h2 {
            color: #2c3e50;
            font-size: 1.1em;
            font-weight: 600;
            margin-bottom: 20px;
            padding-bottom: 0;
            border-bottom: none;
        }

        .empty-state {
            text-align: center;
            padding: 60px 40px;
            color: #bdc3c7;
            font-size: 0.95em;
        }

        .timestamp {
            text-align: right;
            color: #95a5a6;
            margin-top: 20px;
            font-size: 0.85em;
            padding-right: 10px;
        }

        .customize-note {
            background: #fef9e7;
            border-left: 4px solid #f39c12;
            padding: 20px 25px;
            margin-bottom: 0;
            border-radius: 4px;
        }

        .customize-note h3 {
            color: #e67e22;
            margin-bottom: 12px;
            font-size: 1em;
            font-weight: 600;
        }

        .customize-note p {
            color: #7f8c8d;
            line-height: 1.7;
            font-size: 0.9em;
        }

        .customize-note code {
            background: white;
            padding: 2px 8px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
            color: #e67e22;
            border: 1px solid #f39c12;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Agent Dashboard</h1>
            <p>Demo Dashboard Template</p>
        </div>

        <div class="section">
            <div class="customize-note">
                <h3>📝 Customize This Dashboard</h3>
                <p>
                    This is a template dashboard. Customize it to display data from your agent's <code>data/</code> files.
                    <br><br>
                    <strong>Ideas:</strong>
                    <br>• Add stats cards showing key metrics
                    <br>• Display current state from context files
                    <br>• Show recent updates or pending items
                    <br>• Add progress bars or charts
                    <br><br>
                    <strong>To use:</strong> Open <code>dashboard.html</code> in your browser to see the current state visually.
                </p>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <h3>Metric 1</h3>
                <div class="value">--</div>
            </div>
            <div class="stat-card">
                <h3>Metric 2</h3>
                <div class="value">--</div>
            </div>
            <div class="stat-card">
                <h3>Metric 3</h3>
                <div class="value">--</div>
            </div>
            <div class="stat-card">
                <h3>Metric 4</h3>
                <div class="value">--</div>
            </div>
        </div>

        <div class="section">
            <h2>Current State</h2>
            <div class="empty-state">
                Customize this section to display your agent's data
            </div>
        </div>

        <div class="timestamp">
            Template created - customize with real data
        </div>
    </div>
</body>
</html>
EOFDASHBOARD
echo "✓ Created dashboard.html template (customize this!)"
echo ""

# Create demo README
cat > "$DEMO_DIR/README.md" <<EOFREADME
# $PROJECT_NAME Demo

Demo created on $(date)

## Structure

\`\`\`
demo/
  instance/               # News service instance
    config.yaml
    start.sh
    stop.sh
    status.sh
    generate-initial-data.sh
  agent/                  # Agent project
    CLAUDE.md
    AGENTS.md
    dashboard.html        # Web dashboard (customize!)
    data/
  README.md               # This file
\`\`\`

## Setup

1. **Customize the scenario**
   - Edit \`agent/AGENTS.md\` with agent behavior
   - Edit \`instance/generate-initial-data.sh\` with demo data
   - Create data structure in \`agent/data/\`
   - Edit \`agent/dashboard.html\` to display your data (optional but recommended!)

2. **Start the instance**
   \`\`\`bash
   cd instance
   ./start.sh
   ./generate-initial-data.sh
   \`\`\`

3. **Run the agent**
   \`\`\`bash
   cd ../agent
   code .  # Open in Claude Code
   # Say: "Process new updates"
   \`\`\`

## Quick Start

\`\`\`bash
# From demo directory
cd instance && ./start.sh && cd ..
# Customize: nano instance/generate-initial-data.sh
cd instance && ./generate-initial-data.sh && cd ..
cd agent && code .
\`\`\`

## Instance Info

- Service URL: http://localhost:$SERVICE_PORT
- Database Port: $DB_PORT
- API Key: See instance/config.yaml

## Next Steps

1. Customize agent/AGENTS.md
2. Define data structure in agent/data/
3. Customize agent/dashboard.html (optional - visual state display)
4. Customize instance/generate-initial-data.sh
5. Start instance and generate data
6. Run agent in Claude Code
7. Open dashboard.html in browser to see visual state
EOFREADME

echo "✓ Created README.md"
echo ""

echo "========================================="
echo "Demo Project Created Successfully!"
echo "========================================="
echo ""
echo "Location: $DEMO_DIR"
echo ""
echo "Structure:"
echo "  instance/              - News service"
echo "  agent/                 - Agent project"
echo "  README.md              - Documentation"
echo ""
echo "Next steps:"
echo "  1. Customize agent/AGENTS.md"
echo "  2. Customize agent/dashboard.html (optional)"
echo "  3. Customize instance/generate-initial-data.sh"
echo "  4. cd $DEMO_DIR/instance && ./start.sh"
echo "  5. cd $DEMO_DIR/agent && code ."
echo ""

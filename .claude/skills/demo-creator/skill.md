---
name: demo-creator
description: Create complete end-to-end demo environments for news service instances
---

# News Service Demo Creator

Create a complete end-to-end demo environment for the news service with isolated PostgreSQL database and customizable demo data.

## When to use

Use this skill when the user asks to:
- Create a new demo
- Set up a news service demo
- Create a demo instance
- Generate a project demo with sample data

## Demo Structure

- **Script location**: `.claude/skills/demo-creator/`
- **Instance location**: `.claude/skills/demo-creator/instances/<instance-name>/`
- **Required tools**: Docker, bash
- **Components**: PostgreSQL container, news service container, demo data generation script

## Complete Demo Creation Process

Creating a demo involves **two major workflows**:

1. **Planning Workflow** - Design the scenario and data structure
2. **Implementation Workflow** - Create instance, agent, and data

### When to Use Each Workflow

**Use Planning Workflow when:**
- Starting a new demo from scratch
- User provides a use case/scenario
- Need to design custom agent behavior and data structure

**Use Implementation Workflow when:**
- You already have a scenario planned
- Creating a standard Personal Coach demo
- Following existing templates

## Planning Workflow (Scenario-Driven Demo)

**Use this workflow when user provides a specific use case.**

### Phase 1: Understand the Use Case

**Ask the user:**
1. What's the scenario/use case for this demo?
2. What kind of "news" will the agent be processing?
3. What should the agent be tracking/building?
4. Who is the target audience for this demo?

**Example use cases:**
- **Product team updates** - Track features, releases, feedback
- **Engineering team status** - Track projects, deployments, incidents
- **Customer success** - Track customer feedback, issues, wins
- **Research project** - Track experiments, findings, papers

### Phase 2: Design the Scenario

Based on the use case, design:

**1. Agent persona:**
- What role does the agent play?
- What's the agent's purpose?
- Example: "Product Manager Assistant" or "Engineering Lead Coach"

**2. Data structure:**
- What files should live in `data/`?
- What projects need tracking?
- Example for Product Team:
  ```
  data/
    product_vision.md        # Product strategy and goals
    features_roadmap.md      # Feature planning and status
    customer_feedback.md     # Customer insights
    team_members.md          # Team roster and roles
    projects/
      feature-x/project.md   # Individual feature tracking
      feature-y/project.md
  ```

**3. News content strategy:**
- What types of news items make sense?
- What labels/categories to use?
- How much initial data (1 week? 2 weeks?)
- What progression/story to tell?

**4. Update strategy:**
- What kind of follow-up updates?
- What actions should the agent recommend?
- How to demonstrate value?

### Phase 3: Create AGENTS.md

Based on the scenario design, create a custom **AGENTS.md** file:

**Template structure:**
```markdown
# {Agent Name} Agent

{Description of agent's purpose}

## Scenario

{Describe the scenario - who, what, why}

## Core Context Files

The agent maintains these files in `data/`:
- `file1.md` - Purpose
- `file2.md` - Purpose
- `projects/X/project.md` - Purpose

## Instructions

### When Asked: "Process new updates"

**Workflow:**
1. Fetch updates from news service
2. Read current context files
3. Analyze updates for:
   - {What to look for in updates}
4. Update context files:
   - {How to update files}
5. Generate overview showing:
   - {What overview should show}
6. Recommend actions:
   - {What actions to suggest}

## Processing Guidelines

{Specific rules for this scenario}
```

Use `AGENTS.md.template` as a starting point and fill in the placeholders.

### Phase 4: Plan Initial Data

Design **2 weeks of news items** that tell a story:

**Week 1 - Setup:**
- Project kickoffs
- Team introductions
- Initial goals/milestones
- 5-10 news items

**Week 2 - Progress:**
- Status updates
- Milestones reached
- Issues encountered
- Decisions made
- 10-15 news items

**Data design principles:**
- **Realistic** - Use believable names, dates, content
- **Progressive** - Show evolution over time
- **Varied** - Different types of updates
- **Labeled** - Use consistent labels for filtering

### Phase 5: Plan Update Data

Design **follow-up updates** (1 week later) that:
- Show continued progress
- Introduce new issues/opportunities
- Create scenarios for agent recommendations
- 5-10 additional news items

**Goal:** Demonstrate that the agent can:
- Track changes over time
- Identify trends
- Recommend relevant actions
- Update its knowledge base

### Phase 6: Generate Scripts

Create **two data generation scripts**:

**1. generate-initial-data.sh** - 2 weeks of initial data
**2. generate-update-data.sh** - Follow-up updates

Both should use the same structure:
```bash
#!/bin/bash
# Generate demo data
set -e

# Extract API key and service port from config
API_KEY=$(grep 'api_key:' "$SCRIPT_DIR/config.yaml" | awk '{print $2}' | tr -d '"')
SERVICE_PORT=$(grep 'SERVICE_PORT=' "$SCRIPT_DIR/start.sh" | head -1 | cut -d'"' -f2)
API_URL="http://localhost:$SERVICE_PORT/api/news"

# Helper function
post_news() {
    # ... same as template ...
}

# Week 1 data
post_news "Title" "Content" "\"labels\"" "$WEEK1_DATE"
# ... more items ...

# Week 2 data
post_news "Title" "Content" "\"labels\"" "$WEEK2_DATE"
# ... more items ...
```

### Phase 7: Document the Demo

Create a **README.md** for the demo that explains:
- The scenario/use case
- What the demo demonstrates
- How to run it
- What to look for
- Expected agent behavior

**Example README structure:**
```markdown
# {Demo Name}

## Scenario
{Description}

## What This Demonstrates
- Agent processing news updates
- Building knowledge base over time
- Generating insights and recommendations

## Running the Demo

1. Start instance: `./start.sh`
2. Generate initial data: `./generate-initial-data.sh`
3. Launch agent: `cd ../../{agent-project} && code .`
4. Process updates: "Process new updates"
5. View overview
6. Generate update data: `./generate-update-data.sh`
7. Process again: "Process new updates"
8. View updated overview and recommendations

## Expected Results
{What should happen}
```

## Implementation Workflow (Standard Demo)

**Use this workflow for standard demos or after planning is complete.**

## Demo Creation Workflow

### Step 1: Create instance

Use `create-instance.sh` to create a new isolated news service instance.

```bash
cd .claude/skills/demo-creator
./create-instance.sh <instance-name> [service-port] [db-port]
```

**What this creates:**
- Instance directory: `instances/<instance-name>/`
- Config file: `config.yaml` (database connection, API key)
- Management scripts: `start.sh`, `stop.sh`, `status.sh`, `clean.sh`, `backup.sh`, `restore.sh`
- **Data generation template**: `generate-initial-data.sh` (ready to customize!)

**Examples:**
```bash
# Random ports
./create-instance.sh my-demo

# Specific ports
./create-instance.sh customer-demo 8080 15432
```

### Step 2: Start the instance

Navigate to the instance directory and start both database and service containers.

```bash
cd instances/<instance-name>
./start.sh
```

**What happens:**
1. Creates Docker volume for persistent database storage (first run only)
2. Starts PostgreSQL container with dedicated port
3. Waits for database to be ready
4. Initializes database schema (first run only)
5. Starts news service container
6. Shows service URL, database connection, and API key

**Output includes:**
- Service URL: `http://localhost:<service-port>`
- Database: `localhost:<db-port>`
- API Key: (from config.yaml)

### Step 3: Verify instance is running

Check that both containers are up and healthy.

```bash
./status.sh
```

**Expected output:**
```
Instance Status: my-demo
=========================================

Database Container (postgres-my-demo):
  Status: ✓ Running
  Port: 0.0.0.0:15432->5432/tcp

Service Container (news-service-my-demo):
  Status: ✓ Running
  Port: 0.0.0.0:8080->8080/tcp

Data Volume (postgres-data-my-demo):
  Status: ✓ Exists
  Size: 8.5MB
```

**Troubleshooting:**
- If containers aren't running, check logs: `docker logs news-service-<instance-name>`
- If database connection fails, verify PostgreSQL is ready: `docker exec postgres-<instance-name> pg_isready -U newsuser`

### Step 4: Customize demo data script

**IMPORTANT:** Before running the data generation script, you MUST customize it with your demo-specific content!

Edit `generate-initial-data.sh` in the instance folder:

```bash
# Edit the script
nano instances/<instance-name>/generate-initial-data.sh
# or
code instances/<instance-name>/generate-initial-data.sh
```

**What to customize:**

1. **Update the example news items** - Replace the sample titles and content
2. **Add more post_news calls** - Create multiple news items for your demo scenario
3. **Adjust timestamps** - Use appropriate dates for your demo timeline
4. **Customize labels** - Use relevant labels for filtering and organization

**Template structure:**
```bash
# Helper function is already provided
post_news() {
    local title="$1"
    local content="$2"
    local labels="$3"
    local timestamp="$4"
    # ... posts to API
}

# Add your demo data like this:
post_news \
    "Demo Title Here" \
    "Your detailed content here...

Can be multi-line with formatting." \
    "\"label1:value\", \"label2:value\"" \
    "$TODAY"
```

**Example scenarios:**
- **Team status updates**: Weekly status from 5-10 team members across 2-3 projects
- **Product launches**: Announcements, milestones, retrospectives
- **Customer feedback**: Issues, feature requests, success stories
- **Engineering updates**: Deployments, incidents, architectural decisions

### Step 5: Run the data generation script

Once customized, run the script to populate the database with demo data.

```bash
./generate-initial-data.sh
```

**What happens:**
1. Reads API key from `config.yaml`
2. Reads service port from `start.sh`
3. Posts each news item to the API via HTTP
4. Shows success/failure for each item

**Expected output:**
```
=========================================
Generating Demo Data: my-demo
=========================================

API URL: http://localhost:8080/api/news

Creating demo data...

✓ Posted: Demo: Getting Started
✓ Posted: Project X - Week 1 Update
✓ Posted: Team Status - Sarah Chen

=========================================
✓ Demo Data Generation Complete!
=========================================

Next steps:
  1. Customize this script with your demo data
  2. Run it again to add more data
  3. Access the web UI: http://localhost:8080
```

### Step 6: Verify demo data

Check that the data is in the database and accessible via the web UI.

**Option 1: Web UI**
```bash
# Open in browser
open http://localhost:<service-port>
# or
curl http://localhost:<service-port>/api/news
```

**Option 2: Database CLI**
```bash
docker exec -it postgres-<instance-name> psql -U newsuser -d <instance-name>

# Check data
SELECT id, title, created_at FROM news ORDER BY created_at DESC LIMIT 10;
```

**Option 3: API Check**
```bash
# Get all news items
curl http://localhost:<service-port>/api/news | jq '.'

# Get specific item
curl http://localhost:<service-port>/api/news/<id> | jq '.'

# Filter by label
curl "http://localhost:<service-port>/api/news?label=project:X" | jq '.'
```

### Step 7: Iterate on demo data (optional)

You can continue to refine the demo data:

1. **Edit** `generate-initial-data.sh` with more items or corrections
2. **Clean the database** (if you want to start fresh):
   ```bash
   ./clean.sh  # WARNING: Deletes all data!
   ./start.sh  # Creates fresh database
   ```
3. **Run** the data generation script again
4. **Verify** the updated data

**Tip:** You can run `generate-initial-data.sh` multiple times without cleaning - it will add new items each time.

## Complete Example Workflow

```bash
# Navigate to skill directory
cd .claude/skills/demo-creator

# Step 1: Create instance
./create-instance.sh acme-corp-demo 8080 15432

# Step 2: Start instance
cd instances/acme-corp-demo
./start.sh

# Step 3: Check status
./status.sh

# Step 4: Customize data script (use your editor)
nano generate-initial-data.sh
# ... edit to add demo-specific news items ...

# Step 5: Generate demo data
./generate-initial-data.sh

# Step 6: Verify data
open http://localhost:8080
# or
curl http://localhost:8080/api/news | jq '.[] | {id, title, created_at}'

# Optional: Query database directly
docker exec -it postgres-acme-corp-demo psql -U newsuser -d acme-corp-demo \
  -c "SELECT COUNT(*) as total_news FROM news;"
```

## Instance Management

**Stop instance** (data preserved):
```bash
./stop.sh
```

**Restart instance** (data restored from volume):
```bash
./start.sh
```

**Backup database**:
```bash
./backup.sh
# Creates: backups/<instance-name>_YYYYMMDD_HHMMSS.tar.gz
```

**Restore from backup**:
```bash
./restore.sh <backup-file>
```

**Clean/reset** (delete all data):
```bash
./clean.sh
# WARNING: This deletes the Docker volume and all data!
```

**Delete instance completely**:
```bash
./stop.sh
cd ../..
rm -rf instances/<instance-name>
```

## Docker Resources

**Container names:**
- Database: `postgres-<instance-name>`
- Service: `news-service-<instance-name>`

**Volume name:**
- Data: `postgres-data-<instance-name>`

**View logs:**
```bash
docker logs -f news-service-<instance-name>
docker logs -f postgres-<instance-name>
```

**Connect to database:**
```bash
docker exec -it postgres-<instance-name> psql -U newsuser -d <instance-name>
```

## Troubleshooting

**Instance won't start:**
1. Check Docker is running: `docker ps`
2. Check port conflicts: `netstat -an | grep <port>`
3. View container logs: `docker logs postgres-<instance-name>`

**Data generation fails:**
1. Verify instance is running: `./status.sh`
2. Check service is accessible: `curl http://localhost:<port>/api/news`
3. Verify API key in `config.yaml` matches what service expects

**Database connection errors:**
1. Check PostgreSQL is ready: `docker exec postgres-<instance-name> pg_isready -U newsuser`
2. Verify port in `config.yaml` matches actual database port
3. Check database logs: `docker logs postgres-<instance-name>`

**Want to start fresh:**
```bash
./clean.sh          # Delete all data
./start.sh          # Create fresh database
./generate-initial-data.sh  # Repopulate with demo data
```

## Tips for Creating Great Demos

1. **Tell a story** - Organize news items chronologically to show progression
2. **Use realistic data** - Make titles, content, and labels believable
3. **Show variety** - Include different types of updates (projects, people, incidents, etc.)
4. **Use labels effectively** - Help with filtering and organization
5. **Include timestamps** - Create a realistic timeline (weeks/months of data)
6. **Add comments** - You can also add comments to news items via the API
7. **Test the demo** - Verify all key scenarios work before presenting

## Advanced: Multiple Demo Instances

You can run multiple isolated demos simultaneously:

```bash
# Create multiple instances
./create-instance.sh demo-retail 8080 15432
./create-instance.sh demo-finance 8081 15433
./create-instance.sh demo-healthcare 8082 15434

# Each has its own:
# - Database (isolated data)
# - Service (isolated API)
# - API key (isolated security)
# - Demo data script (customized content)

# Start all
cd instances/demo-retail && ./start.sh && cd ../..
cd instances/demo-finance && ./start.sh && cd ../..
cd instances/demo-healthcare && ./start.sh && cd ../..

# Access each
open http://localhost:8080  # retail
open http://localhost:8081  # finance
open http://localhost:8082  # healthcare
```

## Creating Agent Projects

Once you have a demo instance running with data, you can create an agent project that uses it.

### What is an Agent Project?

An agent project is a complete workspace for a Personal Coach agent that:
- Connects to a news service instance
- Maintains context files (goals, actions, people, projects)
- Uses session-based logging
- Tracks your priorities and progress

### Agent Creation Workflow

Use `create-agent.sh` to bootstrap a new agent project from an existing instance.

```bash
cd .claude/skills/demo-creator
./create-agent.sh <instance-name> <agent-project-name>
```

**What this creates:**

A complete agent project with:
- **CLAUDE.md** - Agent instructions (Personal Coach behavior)
- **news_retriever.py** - Fetch news updates from the instance
- **preferences.md** - Configure news filtering
- **.apikey** - API key (extracted from instance config)
- **.newsservice** - Service URL (extracted from instance)
- **data/** - Context files (profile, goals, people, actions, projects)
- **.claude/skills/** - Copied skills (log, redhat-news)
- **logs/** - Session logs directory
- **.gitignore** - Ignore sensitive files

**Example:**

```bash
# Navigate to demo-creator
cd .claude/skills/demo-creator

# Create agent project from instance
./create-agent.sh my-demo my-coach-agent

# Output shows:
# - Instance connection details
# - Created files
# - Next steps
```

### Using the Agent Project

After creation, customize and use your agent:

**1. Navigate to the project:**
```bash
cd my-coach-agent
```

**2. Customize context files:**

Edit these files with your actual information:
- `data/profile.md` - Your role, focus areas, priorities
- `data/goals_current.md` - Your current goals with deadlines
- `data/people_active.md` - Key relationships
- `data/actions.md` - Your action items and priorities

**3. Configure news preferences:**

Edit `preferences.md` to filter news:
```markdown
# Preferences

## Labels
project:my-project, type:update

## Exclude
type:spam, priority:low
```

**4. Test news retrieval:**

```bash
python news_retriever.py
```

Expected output:
```json
{
  "status": "success",
  "session_id": "20260427-120000",
  "new_articles": [
    {
      "id": 1,
      "title": "Demo Article",
      "content": "...",
      "labels": ["project:X"]
    }
  ]
}
```

**5. Open in Claude Code:**

```bash
# From agent project directory
code .
```

Then use Claude Code to interact with your Personal Coach agent using the instructions in CLAUDE.md.

### Complete Example: Demo + Agent

Create a complete demo environment with an agent:

```bash
cd .claude/skills/demo-creator

# Step 1: Create news service instance
./create-instance.sh customer-demo 8080 15432

# Step 2: Start the instance
cd instances/customer-demo
./start.sh
./status.sh

# Step 3: Customize and generate demo data
nano generate-initial-data.sh
# ... add customer-specific news updates ...
./generate-initial-data.sh

# Step 4: Verify data
curl http://localhost:8080/api/news | jq '.'

# Step 5: Create agent project
cd ../..
./create-agent.sh customer-demo customer-agent

# Step 6: Customize agent
cd ../../customer-agent
nano data/profile.md
nano data/goals_current.md
nano preferences.md

# Step 7: Test integration
python news_retriever.py

# Step 8: Open in Claude Code
code .
```

Now you have:
- ✅ News service running with demo data
- ✅ Agent project configured and connected
- ✅ Ready to use Personal Coach in Claude Code

### Agent Project Structure

```
my-coach-agent/
├── CLAUDE.md                 # Agent instructions
├── news_retriever.py         # Fetch updates from news service
├── preferences.md            # News filtering preferences
├── .apikey                   # API key (gitignored)
├── .newsservice              # Service URL (gitignored)
├── .gitignore                # Ignore sensitive files
├── data/
│   ├── profile.md            # Your role and priorities
│   ├── goals_current.md      # Current goals with deadlines
│   ├── people_active.md      # Key relationships
│   ├── actions.md            # Action items
│   └── projects/
│       └── blog/
│           ├── project.md    # Blog tracking
│           └── ideas.md      # Blog post ideas
├── .claude/
│   ├── skills/
│   │   ├── log/              # Session logging
│   │   └── redhat-news/      # News service integration
│   └── settings.local.json   # Local settings
└── logs/                     # Session logs (gitignored)
```

### Workflow: Agent + Demo

**Typical workflow when using an agent project:**

1. **Morning check:**
   ```bash
   python news_retriever.py
   # Shows new updates since last check
   ```

2. **Process in Claude Code:**
   - Open agent project in Claude Code
   - Ask: "Process my latest updates"
   - Agent reads news, suggests context file updates
   - You approve changes
   - Agent updates data files, logs session

3. **Set priorities:**
   - Ask: "What should I focus on today?"
   - Agent analyzes goals, deadlines, news
   - Suggests 3-5 priorities for today
   - Updates actions.md with your priorities

4. **Weekly review:**
   - Ask: "Weekly checkpoint"
   - Agent reviews completed vs. incomplete items
   - Suggests next week's priorities
   - Updates actions.md for the coming week

### Tips for Agent Projects

1. **Keep context files up to date** - The agent is only as good as the context you give it
2. **Use session logs** - Review `logs/` to see agent reasoning
3. **Customize preferences.md** - Filter noise from your news feed
4. **Regular checkpoints** - Daily priority setting, weekly reviews
5. **Multiple agents** - Create multiple agent projects for different contexts (work, personal, etc.)

### Troubleshooting Agent Projects

**Agent can't connect to news service:**
```bash
# Check .newsservice file
cat .newsservice
# Should show: http://localhost:PORT

# Verify instance is running
cd .claude/skills/demo-creator/instances/my-demo
./status.sh
```

**Authentication errors:**
```bash
# Check .apikey file
cat .apikey
# Should contain the API key

# Compare with instance config
grep 'api_key' .claude/skills/demo-creator/instances/my-demo/config.yaml
```

**No news updates:**
```bash
# Test news retrieval directly
python news_retriever.py

# Check if there's data in the instance
curl http://localhost:PORT/api/news

# Check preferences.md filters
cat preferences.md
```

**Want to reset agent context:**
```bash
# Back up current context
cp -r data data.backup

# Reset to minimal state
rm data/*.md
rm -rf data/projects/*

# Re-run create-agent.sh will show how to recreate minimal files
```

## Demo Execution Workflow (Running the Complete Demo)

This workflow demonstrates the **full cycle**: create instance → generate data → create agent → process data → show results → update data → reprocess → show updated results.

### Overview

**The complete demo workflow:**

1. **Setup Phase** - Create instance and agent
2. **Initial Processing** - Agent processes baseline data
3. **Show Baseline** - Display what agent built
4. **Update Phase** - Add new data to news service
5. **Reprocessing** - Agent processes updates
6. **Show Changes** - Display updated overview and recommendations

### Complete Execution Example

**Scenario:** Product team tracking features and customer feedback

```bash
# ============================================
# SETUP PHASE
# ============================================

cd .claude/skills/demo-creator

# Step 1: Create news service instance
./create-instance.sh product-demo 8080 15432

# Step 2: Start instance
cd instances/product-demo
./start.sh
./status.sh  # Verify running

# Step 3: Create and customize initial data script
nano generate-initial-data.sh
# ... add 2 weeks of product team updates ...
#     - Feature kickoffs
#     - Customer feedback
#     - Sprint progress
#     - Team status updates

# Step 4: Generate initial data (2 weeks)
./generate-initial-data.sh
# ✓ Posted 15 news items (2 weeks of history)

# Step 5: Verify data in service
curl http://localhost:8080/api/news | jq '.[] | {id, title, labels}'

# Step 6: Create agent project
cd ../..
./create-agent.sh product-demo product-agent

# Step 7: Customize agent
cd ../../product-agent

# Create custom AGENTS.md for this scenario
nano AGENTS.md
# ... define product agent behavior ...

# Update CLAUDE.md to reference AGENTS.md
echo "@AGENTS.md" > CLAUDE.md

# Customize data structure
mkdir -p data/projects/{feature-a,feature-b,feature-c}
nano data/features_roadmap.md
nano data/customer_feedback.md

# ============================================
# INITIAL PROCESSING PHASE
# ============================================

# Step 8: Launch agent in Claude Code
code .

# In Claude Code, say:
# "Process new updates"

# Agent will:
# 1. Fetch 15 news items from news service
# 2. Analyze each item for feature updates, feedback, etc.
# 3. Build initial data structure:
#    - features_roadmap.md (3 features in progress)
#    - customer_feedback.md (feedback themes)
#    - projects/feature-a/project.md (detailed tracking)
# 4. Log all operations
# 5. Generate overview

# ============================================
# SHOW BASELINE PHASE
# ============================================

# In Claude Code, say:
# "Show me an overview of what you've built"

# Expected overview:
# ========================================
# Product Team Overview
# ========================================
#
# Features in Progress (3):
# - Feature A: Authentication Redesign
#   Status: Sprint 2 of 3
#   Progress: 65%
#   Next: Complete UI mockups
#
# - Feature B: Mobile App
#   Status: Sprint 1 of 4  
#   Progress: 20%
#   Next: API integration
#
# - Feature C: Analytics Dashboard
#   Status: Design phase
#   Progress: 10%
#   Next: Stakeholder review
#
# Customer Feedback Themes (5):
# 1. Login UX issues (8 mentions) → Feature A addresses this
# 2. Mobile app requested (12 mentions) → Feature B in progress
# 3. Better reporting needed (6 mentions) → Feature C planned
# 4. Performance concerns (3 mentions)
# 5. Integration requests (4 mentions)
#
# Team Status:
# - 3 active projects
# - 8 team members
# - 2 sprints completed this cycle
# ========================================

# ============================================
# UPDATE PHASE
# ============================================

# Step 9: Create update data script
cd .claude/skills/demo-creator/instances/product-demo

nano generate-update-data.sh
# ... add Week 3 updates showing ...
#     - Feature A completed sprint 2
#     - Feature B encountered blocker
#     - New customer feedback arrived
#     - Decision needed on Feature C timeline

chmod +x generate-update-data.sh

# Step 10: Generate update data
./generate-update-data.sh
# ✓ Posted 7 new news items (Week 3 updates)

# ============================================
# REPROCESSING PHASE
# ============================================

# Step 11: Back to agent in Claude Code
cd ../../../../product-agent

# In Claude Code, say:
# "Process new updates"

# Agent will:
# 1. Fetch 7 new news items
# 2. Update existing context files:
#    - features_roadmap.md (update Feature A → 85%, Feature B → blocked)
#    - customer_feedback.md (add new themes)
#    - projects/feature-b/project.md (document blocker)
# 3. Log all changes
# 4. Generate updated overview
# 5. Identify recommended actions

# ============================================
# SHOW CHANGES PHASE
# ============================================

# In Claude Code, say:
# "Show me an updated overview with recommendations"

# Expected updated overview:
# ========================================
# Product Team Overview (Updated)
# ========================================
#
# Recent Changes:
# ✅ Feature A progressed from 65% → 85% (completed Sprint 2)
# ⚠️  Feature B blocked at 25% (API integration issue)
# 📝 New customer feedback: 4 new items this week
#
# Features in Progress (3):
# - Feature A: Authentication Redesign
#   Status: Sprint 3 of 3 (FINAL SPRINT!)
#   Progress: 85% (↑ from 65%)
#   Next: Final testing & deployment prep
#   Timeline: On track for end of month
#
# - Feature B: Mobile App
#   Status: ⚠️ BLOCKED
#   Progress: 25% (↑ from 20%)
#   Blocker: External API authentication changes
#   Impact: 1 week delay likely
#
# - Feature C: Analytics Dashboard
#   Status: Design phase
#   Progress: 15% (↑ from 10%)
#   Next: DECISION NEEDED on timeline
#
# Customer Feedback Update:
# - Login UX issues: 2 new positive mentions (Feature A preview)
# - Mobile app: 3 new urgent requests
# - Performance: 1 new concern
# - NEW THEME: Data export requested (5 mentions)
#
# 🎯 RECOMMENDED ACTIONS:
#
# URGENT (this week):
# 1. Unblock Feature B - Coordinate with API team on auth changes
# 2. Feature A deployment - Schedule deployment window
# 3. Decide on Feature C timeline - Stakeholder meeting needed
#
# IMPORTANT (this month):
# 4. Address mobile urgency - Consider prioritizing Feature B recovery
# 5. Investigate new data export theme - Product roadmap discussion
#
# MONITORING:
# 6. Feature A final sprint - Daily standups for launch prep
# 7. Feature B blocker - Daily check-ins with API team
# ========================================

# Session log: logs/Product-Agent-20260427-140000.log
```

### Creating generate-update-data.sh

The update script should be created in the instance folder:

```bash
cd .claude/skills/demo-creator/instances/<instance-name>

cat > generate-update-data.sh <<'EOFUPDATE'
#!/bin/bash
# Generate update data (Week 3 and beyond)
# Shows progression and new scenarios

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Read configuration
API_KEY=$(grep 'api_key:' "$SCRIPT_DIR/config.yaml" | awk '{print $2}' | tr -d '"')
SERVICE_PORT=$(grep 'SERVICE_PORT=' "$SCRIPT_DIR/start.sh" | head -1 | cut -d'"' -f2)
API_URL="http://localhost:$SERVICE_PORT/api/news"

echo "========================================="
echo "Generating Update Data"
echo "========================================="
echo "API URL: $API_URL"
echo ""

# Helper function to post news
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
        echo "  Response: $response"
    fi
}

# Calculate Week 3 date
WEEK3_DATE=$(date -u +"%Y-%m-%dT12:00:00Z")

echo "Creating Week 3 updates..."
echo ""

# TODO: Customize with your scenario-specific updates
# These should show:
# - Progress on existing items
# - New issues/blockers
# - New opportunities
# - Scenarios that require action

# Example updates:
post_news \
    "Feature A - Sprint 2 Complete!" \
    "Great progress on Authentication Redesign.

Completed this sprint:
- UI mockups finalized and approved
- Backend API implementation complete
- Integration testing passed

Status:
- Progress: 85% (was 65%)
- Timeline: On track
- Next: Final sprint - testing and deployment prep

Ready for final sprint next week!" \
    "\"project:feature-a\", \"type:progress\", \"status:on-track\"" \
    "$WEEK3_DATE"

post_news \
    "Feature B - BLOCKER: API Changes" \
    "Mobile app development hit a blocker.

Issue:
- External authentication API deprecated our integration method
- Need to migrate to new OAuth2 flow
- Estimated impact: 1 week delay

Current status:
- Progress: 25% (was 20%)
- Timeline: At risk
- Blocker severity: High

Action needed:
- Coordinate with API team this week
- Update integration code
- Re-test authentication flow" \
    "\"project:feature-b\", \"type:blocker\", \"priority:urgent\"" \
    "$WEEK3_DATE"

post_news \
    "NEW: Data Export Feature Requests" \
    "Multiple customers requesting data export capability.

This week's feedback:
- 5 customers mentioned need for data export
- Use cases: reporting, compliance, data migration
- Requested formats: CSV, JSON, Excel

This is emerging as a new theme.

Recommendation: Consider for roadmap discussion." \
    "\"type:customer-feedback\", \"theme:data-export\", \"priority:medium\"" \
    "$WEEK3_DATE"

# Add more updates as needed for your scenario

echo ""
echo "========================================="
echo "✓ Update Data Generation Complete!"
echo "========================================="
echo ""
echo "Next: Return to agent project and process these updates"
echo "  cd ../../<agent-project>"
echo "  # In Claude Code: 'Process new updates'"
echo ""
EOFUPDATE

chmod +x generate-update-data.sh

echo "✓ Created generate-update-data.sh"
```

### Demo Execution Tips

**1. Plan the story arc:**
- Initial data shows setup and early progress
- Update data shows challenges and opportunities
- Agent recommendations demonstrate value

**2. Use realistic timing:**
- Initial data: 1-2 weeks of history
- Update data: 1 week of new updates
- Allows agent to show change over time

**3. Create action opportunities:**
- Include blockers needing attention
- Show items nearing deadlines
- Highlight new themes/patterns
- Agent can make smart recommendations

**4. Show agent capabilities:**
- Data aggregation (building knowledge base)
- Pattern recognition (identifying themes)
- Progress tracking (comparing old vs. new)
- Action synthesis (smart recommendations)

**5. Make it interactive:**
- After showing overview, ask questions:
  - "What's the status of Feature A?"
  - "What customer feedback themes have emerged?"
  - "What should I focus on this week?"
- Agent can query its knowledge base

### Customizing for Different Scenarios

**Engineering team demo:**
- Track: Projects, deployments, incidents, on-call
- Updates: Sprint progress, production issues, architecture decisions
- Recommendations: Technical debt, deployment readiness, incident follow-ups

**Sales team demo:**
- Track: Deals, customers, pipeline, quotas
- Updates: Deal progress, customer meetings, wins/losses
- Recommendations: Follow-ups, at-risk deals, forecast accuracy

**Research team demo:**
- Track: Experiments, papers, findings, collaborations
- Updates: Experiment results, paper submissions, conferences
- Recommendations: Next experiments, paper deadlines, collaboration opportunities

**Customer success demo:**
- Track: Accounts, health scores, issues, renewals
- Updates: Customer check-ins, support tickets, usage metrics
- Recommendations: At-risk accounts, expansion opportunities, onboarding tasks

The pattern is the same - just customize:
1. Data structure (what files in data/)
2. News content (what types of updates)
3. Agent instructions (how to process updates)
4. Overview format (what to show)
5. Recommendations (what actions to suggest)

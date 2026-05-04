# Demo Creator Skill

Create complete end-to-end demo environments with news service instances and AI agents.

## Quick Start

```bash
cd .claude/skills/demo-creator

# Create complete demo (instance + agent + dashboard)
./create-demo.sh budget-assistant 8090 15440

# Output: projects/budget-assistant/demo/
#   - instance/  (news service)
#   - agent/     (agent project with dashboard)
#   - README.md  (demo documentation)
```

**Next steps:**

1. **Customize the scenario**
   ```bash
   cd ../../projects/budget-assistant/demo
   nano agent/AGENTS.md              # Define agent behavior
   nano agent/dashboard.html         # Customize visual dashboard
   nano instance/generate-initial-data.sh  # Create demo data
   ```

2. **Start and populate**
   ```bash
   cd instance
   ./start.sh
   ./generate-initial-data.sh
   ```

3. **Run the agent**
   ```bash
   cd ../agent
   code .  # Open in Claude Code
   # Say: "Process new updates"
   ```

4. **View dashboard** (optional)
   ```
   Open agent/dashboard.html in browser
   ```

## What's Included

### Main Script

- **`create-demo.sh <project-name> [service-port] [db-port]`** - Creates complete demo structure

### Instance Scripts (auto-generated)

- `start.sh` - Start database and service
- `stop.sh` - Stop containers (data preserved)
- `status.sh` - Check status
- `generate-initial-data.sh` - Populate with demo data (customize this!)
- `clean.sh` - Reset database

### Templates

- **`AGENTS.md.template`** - Template for custom agent scenarios
- Dashboard template (auto-included in agent/)

### Documentation

- **`skill.md`** - Complete skill documentation

## Demo Structure

When you run `create-demo.sh budget-assistant`, it creates:

```
projects/budget-assistant/demo/
├── instance/                         # News service instance
│   ├── config.yaml                   # DB connection, API key
│   ├── schema.sql                    # Database schema
│   ├── start.sh                      # Start containers
│   ├── stop.sh                       # Stop containers
│   ├── status.sh                     # Check status
│   ├── clean.sh                      # Reset database
│   └── generate-initial-data.sh      # Demo data (customize!)
├── agent/                            # Agent project
│   ├── CLAUDE.md                     # References AGENTS.md
│   ├── AGENTS.md                     # Agent behavior (customize!)
│   ├── dashboard.html                # Visual dashboard (customize!)
│   ├── news_retriever.py             # Fetch updates
│   ├── preferences.md                # Filter news
│   ├── .apikey                       # API key (gitignored)
│   ├── .newsservice                  # Service URL (gitignored)
│   ├── data/                         # Context files (create these!)
│   ├── .claude/skills/
│   │   ├── log/                      # Session logging
│   │   └── redhat-news/              # News integration
│   └── logs/                         # Session logs (gitignored)
└── README.md                         # Demo documentation
```

## Example: Budget Assistant Demo

See `projects/budget-assistant/demo/` for a complete working example:

**Scenario:** Montgomery reviews employee budget requests against $1000/month limits

**Data structure:**
- `employees_budget.md` - Track spending per employee
- `requests_pending.md` - Awaiting approval
- `requests_approved.md` - Approved requests
- `requests_denied.md` - Denied with reasons
- `policy.md` - Budget rules

**News updates:**
- Budget requests from employees
- Categories: equipment, training, travel, software

**Agent behavior:**
- Analyze requests against monthly limit
- Recommend approve/deny with reasoning
- Get user confirmation
- Post comments on news items
- Update budget tracking

**Dashboard:**
- Employee budget status with progress bars
- Pending requests queue
- Monthly statistics

## Custom Scenarios

### Product Manager Demo

**Scenario:** Track features and customer feedback

**Data structure:**
- `features_roadmap.md` - Feature planning
- `customer_feedback.md` - Customer insights
- `team_members.md` - Team roster
- `projects/feature-x/project.md` - Per-feature tracking

### Engineering Lead Demo

**Scenario:** Track projects and incidents

**Data structure:**
- `projects_active.md` - Active initiatives
- `incidents_log.md` - Production issues
- `architecture_decisions.md` - Tech decisions
- `team_capacity.md` - Team allocation

## Common Tasks

### View Instance Status

```bash
cd projects/<project-name>/demo/instance
./status.sh
```

### Add More Demo Data

```bash
cd projects/<project-name>/demo/instance
nano generate-update-data.sh  # Create new script
./generate-update-data.sh
```

### Check News Service

```bash
# Via API
curl http://localhost:8090/api/news | jq '.'

# Via database
docker exec -it postgres-<instance-name> psql -U newsuser -d <instance-name>
SELECT id, title, created_at FROM news_items ORDER BY created_at DESC LIMIT 10;
```

### Reset and Start Over

```bash
cd projects/<project-name>/demo/instance
./clean.sh                     # Deletes all data
./start.sh                     # Fresh database
./generate-initial-data.sh     # Repopulate
```

### Update Dashboard

Edit `agent/dashboard.html` to display your agent's data:

```html
<!-- Example: Show stats from data files -->
<div class="stat-card">
    <h3>Total Approved</h3>
    <div class="value">$2,456</div>
</div>
```

Open `dashboard.html` in browser to see current state visually.

## Workflow

1. **Create demo** with `create-demo.sh`
2. **Customize**:
   - Define agent behavior in `agent/AGENTS.md`
   - Design data structure in `agent/data/`
   - Create demo data in `instance/generate-initial-data.sh`
   - Customize `agent/dashboard.html` (optional)
3. **Start** instance and generate data
4. **Run** agent in Claude Code
5. **Verify** files and dashboard look correct
6. **Git checkpoint** - commit initial state
7. **Add updates** with `generate-update-data.sh`
8. **Reprocess** in agent to show evolution

## Tips

1. **Start with a clear scenario** - What problem does the agent solve?
2. **Design data structure first** - What files track what information?
3. **Realistic demo data** - Use believable names, dates, content
4. **Tell a story** - Initial data → Updates → Agent actions
5. **Use the dashboard** - Visual state is powerful for demos
6. **Test thoroughly** - Run through before presenting
7. **Log everything** - Session logs show agent reasoning
8. **Git checkpoint** - Commit before adding updates

## Cross-Platform Notes

- All scripts use relative paths (work anywhere)
- Date commands use simple `$TODAY` (Windows compatible)
- Dashboard uses standard HTML/CSS (works in any browser)

## Troubleshooting

**Instance won't start:**
```bash
docker ps  # Check Docker is running
cd instance && ./status.sh
```

**Agent can't connect:**
```bash
cat agent/.newsservice  # Should show http://localhost:<port>
cat agent/.apikey       # Should have API key
curl http://localhost:<port>/api/news  # Test service
```

**No news appearing:**
```bash
curl http://localhost:<port>/api/news  # Check if data exists
# If empty, run generate-initial-data.sh again
```

## Learn More

See `skill.md` for complete documentation including:
- Detailed planning workflow
- Agent customization guide
- Advanced usage patterns

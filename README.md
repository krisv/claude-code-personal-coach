# Personal Coach Agent

AI-powered personal coach that helps you maintain focus on priorities through context tracking and guided conversations.

**Coaching Philosophy:** Your coach suggests and asks questions, not commands. It holds you accountable to your goals and commitments, but you make all the decisions.

## Overview

The Personal Coach agent retrieves your free-form personal updates from a news service, processes them intelligently, and maintains grounded context files to help you stay focused on what matters.

## Quick Start

### 1. Set up your context

Fill in the template files in the `data/` folder with your information:

**Main context:**
- `data/profile.md` - Your role, interests, priorities, and recurring cadences
- `data/goals_current.md` - 3-5 active goals with measurable targets and deadlines
- `data/people_active.md` - Static relationship context (who people are, why they matter)
- `data/actions.md` - Prioritized action items (This Week, Next, Backlog) with deadlines

**Project tracking:**
- `data/projects/<project-name>/project.md` - Detailed tracking per active project
- Examples: `blog/`, `agentic-workforce/`, `AIRR/`

### 2. Post personal updates

Post free-form updates to the news service at `http://localhost:8414`:

Example updates:
- "Met with Sarah today about the AI project demo"
- "Published article on machine learning best practices"
- "Completed follow-up with Alex on the proposal"

### 3. Process updates

Ask Claude Code: **"Get my latest updates"**

The coach will:
- Fetch new updates from the news service
- Analyze contacts, interactions, goal progress, commitments
- **Suggest** updates to context files (asks your approval first)
- Summarize what changed after you approve
- Update memory to track processed articles

### 4. Daily & weekly coaching

**Daily (recommended morning):**
```
Ask: "What should I focus on today?" or "Set daily priorities"
```
Coach will:
1. Fetch latest news updates automatically
2. Suggest updates based on news (waits for your approval)
3. **Suggest** your Current priorities (3-5 items for TODAY) based on deadlines and goals
4. Ask for your input and adjust based on your feedback
5. Update files only after you approve
6. Remind you if it's time for a weekly checkpoint (7+ days)

**Weekly (recommended Sunday/Monday):**
```
Ask: "Weekly checkpoint" or "Review this week"
```
Coach will:
1. Fetch latest news updates automatically
2. Suggest updates based on news (waits for your approval)
3. Run daily priorities first if needed (not done in 24h)
4. Review completed items and **ask you to reflect**
5. **Suggest** next week's priorities based on deadlines and goals
6. Get your input and adjust
7. Provide goal progress summary with accountability questions

**Ongoing:**
Ask for help anytime:
- "Help me set goals for next quarter"
- "What should I focus on?"
- "How am I doing on my goals?"

## Architecture

```
User Updates → News Service → news_monitor.py → Personal Coach
                                                → Context Files
                                                → Memory Tracking
```

## File Structure

```
.
├── CLAUDE.md                   # Instructions for Claude Code
├── AGENTS.md                   # Personal Coach workflow
├── README.md                   # This file
├── data/                       # Context files
│   ├── profile.md              # Stable context (role, priorities, cadences)
│   ├── goals_current.md        # Current goals (measurable, with deadlines)
│   ├── people_active.md        # Relationship context (static)
│   ├── actions.md              # Action items (prioritized with deadlines)
│   └── projects/               # Project-specific tracking
│       ├── blog/
│       │   └── project.md      # Blog & knowledge sharing details
│       ├── agentic-workforce/
│       │   └── project.md      # Agentic platform development
│       └── AIRR/
│           └── project.md      # UK AIRR positioning project
├── article_memory.json         # Last processed article ID
├── news_retriever.py           # News retrieval script
├── logs/                       # Session logs
│   └── Personal Coach-YYYYMMDD-HHMMSS.log
└── .claude/
    └── skills/
        ├── log/                # Logging skill
        │   └── log.py
        └── redhat-news/        # News monitoring skill
            ├── Skill.md
            └── news_monitor.py
```

## Context Files (in `data/` folder)

### data/profile.md
**Stable context** - Your role, focus areas, how to prioritize, recurring cadences.
Updates rarely (only on major changes).

### data/goals_current.md
**Current focus** - 3-5 active goals for current quarter/month.
**Requirements:** Measurable targets, explicit deadlines, why it matters, how progress shows.
Refresh each period.

### data/people_active.md
**Static relationship context** - Important contacts and why they matter.
Each entry: name, role, why they matter, regular cadence (if any).
**No tracking** of open loops or next actions - that goes in actions.md.

### data/actions.md
**Prioritized action items** - What needs to be done with deadlines.
**Sections:** This Week (3-5 items), Next (upcoming with deadlines), Backlog (no deadline yet).
Use checkboxes for tracking completion.

### data/projects/<name>/project.md
**Project-specific details** - Deep tracking for active projects.
Each project folder contains one `project.md` with:
- Overview, status, and project-specific goals
- Dated progress entries
- Upcoming milestones
- Stakeholders and technical notes
- Learnings and context

**When to use:**
- High-level overview → Use main context files (goals, actions)
- Project details → Use project files (architecture, detailed milestones, dated progress)

## Features

- **Free-form updates** - No structured format required
- **Intelligent processing** - Extracts contacts, interactions, progress
- **Grounded context** - Maintains 4 focused context files
- **Conversational coaching** - Guided conversations for goals and priorities
- **Memory tracking** - Remembers last processed article
- **Session logging** - All operations logged with timestamps

## Configuration

News service URL: `http://localhost:8414`
Agent name: `Personal Coach`

Edit in `news_monitor.py` if needed:
- Line 32: `NEWS_SERVICE_BASE_URL`
- Line 46: Default agent name

## Requirements

- Python 3.7+
- News service running at `http://localhost:8414`
- Claude Code with access to this directory

## Example Workflow

```bash
# User posts to news service:
# "Met with Sarah Chen about AI demo. Needs follow-up next week."
# "Published weekly blog post on ML best practices."

# Ask Claude Code: "Get my latest updates"

# Coach responds:
✓ Fetched 2 new updates
✓ Suggests: Update agentic-workforce project with demo progress
✓ Suggests: Update blog project with article (Apr 22)
✓ Suggests: Add "Follow up Sarah" to This Week actions
✓ Asks: "Does this sound right? Any changes?"
[You approve]
✓ Updates files as approved
✓ Updated memory with latest article ID
✓ Session logged to logs/Personal Coach-20260422-144502.log

# Later ask: "What should I focus on today?"

Coach responds:
"Looking at your context, here's what I see:

⚠️ URGENT (2 days away):
- Sarah follow-up is Friday - ready for that conversation?

📅 THIS WEEK:
- Still need 1 more knowledge share by Sunday (you're at 1/2)

🎯 GOAL CHECK:
- Knowledge sharing: Behind pace (need to hit 2/week consistently)
- Agentic workforce: On track (2/3 agents done)

I suggest making today's priorities:
1. Prep for Sarah follow-up (Friday)
2. Draft and post one knowledge share (weekly goal)
3. Personal Coach features (goal progress)

What do you think? Want to adjust?"

[You discuss and decide together]
```

## Notes

- Updates are free-form - coach extracts meaning intelligently
- Context files are the source of truth - keep them current
- Coach only updates files when changes are warranted
- Always ends update sessions by saving latest article ID to memory
- Use for planning, reflection, and maintaining focus

# Personal Coach Agent

AI-powered personal coach that helps you maintain focus on priorities through context tracking and guided conversations.

**Coaching Philosophy:** Your coach suggests and asks questions, not commands. It holds you accountable to your goals and commitments, but you make all the decisions.

## Overview

The Personal Coach agent processes your updates, maintains grounded context files, and helps you stay focused on what matters through guided conversations.

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
- Example: `data/projects/sample-project/project.md`

### 2. Daily & weekly coaching

**Daily (recommended morning):**
```
Ask: "What should I focus on today?" or "Set daily priorities"
```
Coach will:
1. Review your context files
2. **Suggest** your Current priorities (3-5 items for TODAY) based on deadlines and goals
3. Ask for your input and adjust based on your feedback
4. Update files only after you approve
5. Remind you if it's time for a weekly checkpoint (7+ days)

**Weekly (recommended Sunday/Monday):**
```
Ask: "Weekly checkpoint" or "Review this week"
```
Coach will:
1. Review completed items and **ask you to reflect**
2. **Suggest** next week's priorities based on deadlines and goals
3. Get your input and adjust
4. Provide goal progress summary with accountability questions

**Ongoing:**
Ask for help anytime:
- "Help me set goals for next quarter"
- "What should I focus on?"
- "How am I doing on my goals?"

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
│       └── sample-project/
│           └── project.md      # Example project structure
├── article_memory.json         # Last processed article ID (if using news service)
├── news_retriever.py           # News retrieval script
├── logs/                       # Session logs (excluded from git)
│   └── Personal Coach-YYYYMMDD-HHMMSS.log
└── .claude/
    └── skills/
        ├── log/                # Logging skill
        │   └── log.py
        └── redhat-news/        # News monitoring skill (optional)
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
**Sections:**
- **Current priorities** - 3-5 items for TODAY (updated daily)
- **This Week** - Items due this week (updated weekly)
- **Next** - Upcoming items with deadlines
- **Backlog** - No deadline yet

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

- **Conversational coaching** - Guided conversations for goals and priorities
- **Grounded context** - Maintains 4 focused context files plus project details
- **Accountability** - Tracks commitments and holds you accountable to deadlines
- **Collaborative** - Suggests changes, gets your approval before updating files
- **Session logging** - All operations logged with timestamps

## Example Workflow

```bash
# Ask: "What should I focus on today?"

Coach responds:
"Looking at your context, here's what I see:

⚠️ URGENT (tomorrow):
- Stakeholder presentation is Tuesday - ready to present?

📅 THIS WEEK:
- Quarterly report due Wednesday
- Technical blog post by Sunday

🎯 GOAL CHECK:
- Technical Leadership: 6/8 articles done (on track)
- Project Alpha: MVP deadline in 4 weeks

I suggest these 3 priorities for today:
1. Finalize stakeholder presentation (tomorrow - urgent!)
2. Draft quarterly report (due Wednesday)
3. Continue Project Alpha feature work

What do you think? Want to adjust?"

[You discuss and decide together]
```

## Requirements

- Claude Code with access to this directory
- Optional: News service integration (see AGENTS.md for details)

## Getting Started

1. Review the sample data in `data/` folder
2. Replace with your own information
3. Start conversations with Claude Code using prompts like:
   - "What should I focus on today?"
   - "Help me set my Q2 goals"
   - "Weekly checkpoint"

## Notes

- Context files are the source of truth - keep them current
- Coach only updates files with your approval
- Use for planning, reflection, and maintaining focus
- Customizable to your workflow and preferences

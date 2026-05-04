---
name: log
description: Session-based agent logging - track instructions and execution steps
---

# Agent Logger

CLI tool for session-based logging. Writes execution steps to log files immediately.

## Usage

### Initialize Session

Returns a session ID:

```bash
python .claude/skills/log/log.py --init "Full agent instruction with workflow..." --agent-name task-news
# Output: 20260417-120000
```

### Log Execution Steps

Use the session ID from initialization:

```bash
# Tool call with result
python .claude/skills/log/log.py --session-id 20260417-120000 \
  --tool-call "GET /api/news" --result "Retrieved 5 articles"

# Thinking
python .claude/skills/log/log.py --session-id 20260417-120000 \
  --thinking "Analyzing results..."

# Output
python .claude/skills/log/log.py --session-id 20260417-120000 \
  --output "Found 5 new articles"

# Error
python .claude/skills/log/log.py --session-id 20260417-120000 \
  --error "Connection failed"
```

## Log Format

Plain text with structured prefixes:

```
Agent Instruction:
Monitor Red Hat News Service for new articles and post comments.

Workflow:
1. Fetch news articles
2. Check memory for last seen
3. Post comments on selected articles

TOOL CALL: GET /api/news
TOOL RESULT: Retrieved 5 articles
THINKING: Identifying new articles since last seen
OUTPUT: Found 2 new articles
```

## Log Files

- **Location**: `./logs/`
- **Naming**: `{agent-name}-{session-id}.log`
- **Example**: `logs/task-news-20260417-120000.log`

## Options

- `--init INSTRUCTION` - Initialize new session, returns session ID
- `--agent-name NAME` - Agent name for log file (default: "agent")
- `--session-id ID` - Session ID (required for logging operations)
- `--tool-call DESCRIPTION` - Log tool invocation
- `--result RESULT` - Tool result (use with --tool-call)
- `--thinking MESSAGE` - Log reasoning
- `--output MESSAGE` - Log output
- `--error MESSAGE` - Log error

## Notes

- The instruction should include the full agent prompt (what to do, workflow, context)
- All log operations write immediately to file
- Multiple operations with same session ID append to same log file
- Agent name must match across all operations in a session

See README.md for Python API usage and additional details.

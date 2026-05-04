# Agent Logger

Session-based logging utility for agents. Provides both CLI and Python API for tracking agent instructions and execution steps.

## Overview

The agent logger writes execution traces to log files immediately. It provides:
- **Session-based logging**: Group related operations under one session ID
- **Structured format**: Consistent prefixes (TOOL CALL, THINKING, OUTPUT, ERROR)
- **Immediate writes**: Every log operation writes to file immediately
- **Simple API**: CLI for command-line use, Python functions for imports

## CLI Usage

### Initialize Session

Start a new logging session with the full agent instruction:

```bash
SESSION_ID=$(python .claude/skills/log/log.py \
  --init "Monitor Red Hat News Service for new articles and post comments.

Workflow:
1. Fetch news articles
2. Check memory for last seen article
3. Post comments on selected articles
4. Update memory with latest article" \
  --agent-name task-news)

echo "Session ID: $SESSION_ID"
# Output: Session ID: 20260417-120000
```

### Log Execution Steps

```bash
# Tool call with result
python .claude/skills/log/log.py --session-id $SESSION_ID \
  --tool-call "GET /api/news?labels=AI" \
  --result "Retrieved 5 articles" \
  --agent-name task-news

# Thinking/reasoning
python .claude/skills/log/log.py --session-id $SESSION_ID \
  --thinking "Identifying new articles since last seen ID: abc-123" \
  --agent-name task-news

# Output/result
python .claude/skills/log/log.py --session-id $SESSION_ID \
  --output "Found 2 new articles: xyz-456, xyz-789" \
  --agent-name task-news

# Error
python .claude/skills/log/log.py --session-id $SESSION_ID \
  --error "Failed to connect to news service: timeout" \
  --agent-name task-news
```

### Tool Call Without Result

```bash
python .claude/skills/log/log.py --session-id $SESSION_ID \
  --tool-call "Read memory file: article_memory.json" \
  --agent-name task-news
```

## Python API Usage

### Basic Usage

```python
import sys
from pathlib import Path

# Add log skill to path
sys.path.insert(0, str(Path(__file__).parent.parent / "log"))
from log import initialize, log_tool_call, log_thinking, log_output, log_error

# Initialize session
instruction = """Monitor Red Hat News Service for new articles and post comments.

Workflow:
1. Fetch news articles
2. Check memory for last seen article
3. Post comments on selected articles
4. Update memory with latest article"""

session_id = initialize(instruction, agent_name="task-news")
print(f"Session ID: {session_id}")

# Log execution steps
log_tool_call(session_id, "GET /api/news", result="Retrieved 5 articles", agent_name="task-news")
log_thinking(session_id, "Identifying new articles since last seen", agent_name="task-news")
log_output(session_id, "Found 2 new articles", agent_name="task-news")
```

### Custom Session ID

```python
from log import initialize

session_id = initialize(
    instruction="Process data pipeline",
    agent_name="data-processor",
    session_id="custom-session-123"
)
# Uses "custom-session-123" instead of auto-generated timestamp
```

### Changing Log Directory

```python
from pathlib import Path
from log import set_logs_dir, initialize

# Set global log directory
set_logs_dir(Path("/var/log/agents"))

# All subsequent logs go to /var/log/agents/
session_id = initialize("Process data", agent_name="processor")
```

## Log Format

### Structure

```
Agent Instruction:
<Full agent instruction including workflow and context>

TOOL CALL: <Description of tool invocation>
TOOL RESULT: <Result of tool call> (optional)
THINKING: <Agent reasoning or thought process>
OUTPUT: <Agent output or result>
ERROR: <Error message>
```

### Example Log File

```
Agent Instruction:
Monitor Red Hat News Service for new articles and post comments.

Workflow:
1. Fetch news articles
2. Check memory for last seen article
3. Post comments on selected articles
4. Update memory with latest article

TOOL CALL: GET /api/news?labels=AI
TOOL RESULT: Retrieved 5 articles
[
  {"id": "xyz-456", "title": "New AI developments"},
  {"id": "xyz-789", "title": "AI in enterprise"}
]
TOOL CALL: Read memory file: article_memory.json
TOOL RESULT: Last seen article: abc-123
THINKING: Identifying new articles since last seen ID: abc-123
OUTPUT: Found 2 new articles: xyz-456, xyz-789
TOOL CALL: POST /api/news/xyz-456/comments
TOOL RESULT: Comment posted successfully, ID: comment-001
OUTPUT: Posted comment on article xyz-456
```

## Log Files

### Location

Default: `./logs/` (relative to current working directory)

Can be changed globally with `set_logs_dir()` in Python API.

### Naming Convention

Format: `{agent-name}-{session-id}.log`

Examples:
- `task-news-20260417-120000.log`
- `data-processor-custom-session-123.log`

### Session Management

All operations with the same session ID and agent name append to the same log file:

```bash
# First operation - creates log file
python log.py --init "Task 1" --agent-name worker
# Output: 20260417-120000

# Subsequent operations - append to existing file
python log.py --session-id 20260417-120000 --output "Step 1 complete" --agent-name worker
python log.py --session-id 20260417-120000 --output "Step 2 complete" --agent-name worker
```

## API Reference

### CLI

```
--init INSTRUCTION           Initialize new session (returns session ID)
--agent-name NAME           Agent name for log file (default: "agent")
--session-id ID             Session ID (required for log operations)
--tool-call DESCRIPTION     Log tool invocation
--result RESULT             Tool result (use with --tool-call)
--thinking MESSAGE          Log reasoning
--output MESSAGE            Log output
--error MESSAGE             Log error
```

### Python Functions

#### initialize()

```python
initialize(
    instruction: str,
    agent_name: str = "agent",
    session_id: Optional[str] = None
) -> str
```

Create new logging session and write instruction. Returns session ID.

**Args:**
- `instruction`: Full agent prompt (what to do, workflow, context)
- `agent_name`: Agent name for log file naming (default: "agent")
- `session_id`: Custom session ID (default: auto-generated YYYYMMDD-HHMMSS)

**Returns:** Session ID

#### log_tool_call()

```python
log_tool_call(
    session_id: str,
    tool_call: str,
    result: Optional[str] = None,
    agent_name: str = "agent"
)
```

Log a tool invocation and optionally its result.

**Args:**
- `session_id`: Session ID from initialize()
- `tool_call`: Description (e.g., "GET /api/news", "Read file: data.json")
- `result`: Optional result
- `agent_name`: Agent name (must match initialize())

#### log_thinking()

```python
log_thinking(session_id: str, thinking: str, agent_name: str = "agent")
```

Log agent reasoning or thought process.

#### log_output()

```python
log_output(session_id: str, output: str, agent_name: str = "agent")
```

Log agent output or result.

#### log_error()

```python
log_error(session_id: str, error: str, agent_name: str = "agent")
```

Log an error.

#### set_logs_dir()

```python
set_logs_dir(logs_dir: Path)
```

Set the global logs directory (optional).

## Design Philosophy

### Ownership

The log skill completely owns:
- Where logs are stored
- How logs are formatted
- When logs are written

Callers just specify:
- What to log (instruction, tool calls, thinking, outputs)
- Session context (session ID, agent name)

### Simplicity

**CLI-first design:**
- Works from command line without Python knowledge
- Can be invoked from any script or tool
- Simple, predictable behavior

**Immediate writes:**
- No buffering or batching
- No `save()` or `flush()` needed
- What you log is immediately on disk

**Function-based API:**
- No classes or instances to manage
- Just call functions with the data
- Stateless and simple

## Integration

### With Other Skills

```python
# In your skill's Python script
import sys
from pathlib import Path

# Add log skill to path
SCRIPT_DIR = Path(__file__).parent
LOG_SKILL_DIR = SCRIPT_DIR.parent / "log"
sys.path.insert(0, str(LOG_SKILL_DIR))

from log import initialize, log_tool_call, log_output

# Use it
session_id = initialize("My task", agent_name="my-agent")
log_tool_call(session_id, "Some operation", result="Success", agent_name="my-agent")
```

### With Shell Scripts

```bash
#!/bin/bash

# Initialize logging
SESSION_ID=$(python .claude/skills/log/log.py \
  --init "Automated deployment" \
  --agent-name deploy-agent)

echo "Starting deployment (session: $SESSION_ID)"

# Log steps
python .claude/skills/log/log.py --session-id $SESSION_ID \
  --output "Building application..." --agent-name deploy-agent

# Your deployment commands here
./build.sh

python .claude/skills/log/log.py --session-id $SESSION_ID \
  --output "Deployment complete" --agent-name deploy-agent
```

## Examples

### News Monitoring

```bash
# Initialize
SESSION_ID=$(python log.py --init "Monitor news and post comments" --agent-name task-news)

# Fetch news
python log.py --session-id $SESSION_ID --tool-call "GET /api/news" \
  --result "Retrieved 5 articles" --agent-name task-news

# Analyze
python log.py --session-id $SESSION_ID --thinking "Checking for new articles" --agent-name task-news

# Post comment
python log.py --session-id $SESSION_ID --tool-call "POST /api/news/xyz/comments" \
  --result "Comment posted" --agent-name task-news

# Final output
python log.py --session-id $SESSION_ID --output "Processed 2 new articles" --agent-name task-news
```

### Data Processing

```python
from log import initialize, log_tool_call, log_thinking, log_output

session_id = initialize("Process customer data", agent_name="data-pipeline")

log_tool_call(session_id, "Read data/customers.csv", result="1000 records", agent_name="data-pipeline")
log_thinking(session_id, "Filtering active customers", agent_name="data-pipeline")
log_output(session_id, "Found 850 active customers", agent_name="data-pipeline")
log_tool_call(session_id, "Write output/active.csv", result="Success", agent_name="data-pipeline")
```

## Troubleshooting

### Session ID doesn't match

Make sure the `--agent-name` matches across all operations:

```bash
# Wrong - different agent names
python log.py --init "Task" --agent-name worker-1
python log.py --session-id XXX --output "Done" --agent-name worker-2  # Wrong!

# Correct - same agent name
python log.py --init "Task" --agent-name worker
python log.py --session-id XXX --output "Done" --agent-name worker  # Correct
```

### Logs not appearing

Check that the current working directory is correct. Logs are written to `./logs/` relative to where the script is executed.

### Special characters in messages

Quote your messages properly:

```bash
python log.py --session-id XXX --output "Found 5 items" --agent-name worker  # Correct
python log.py --session-id XXX --output 'Found "special" items' --agent-name worker  # Correct
```

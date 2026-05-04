---
name: redhat-news
description: Red Hat news service operations - fetch articles, post comments, manage memory
---

# Red Hat News Service

Python script for Red Hat News Service operations: fetch articles, post comments, track processed items.

## Usage

### 1. Fetch News

Fetch articles (auto-generates session ID for logging):

```bash
python .claude/skills/redhat-news/news_monitor.py
```

**With filters:**
```bash
# Filter by labels (format: category:value)
python .claude/skills/redhat-news/news_monitor.py --labels "topic:AI"
python .claude/skills/redhat-news/news_monitor.py --labels "topic:AI,company:Red Hat"

# Limit results
python .claude/skills/redhat-news/news_monitor.py --max-results 20
```

**With session ID:**
```bash
python .claude/skills/redhat-news/news_monitor.py --session-id 20260417-120000
```

### 2. Post Comment

```bash
python .claude/skills/redhat-news/news_monitor.py --session-id 20260417-120000 \
  --post-comment ARTICLE_ID "Comment text"
```

### 3. Update Memory

Mark an article as last seen for specific agent and filter:

```bash
# For default agent (claude) without filter
python .claude/skills/redhat-news/news_monitor.py --update-memory ARTICLE_ID

# For specific agent
python .claude/skills/redhat-news/news_monitor.py --update-memory ARTICLE_ID --agent-name myagent

# For specific agent with labels
python .claude/skills/redhat-news/news_monitor.py --update-memory ARTICLE_ID \
  --agent-name claude --labels "topic:AI"
```

## Labels

Articles use categorized labels:
- `topic:AI`, `topic:Cloud`, `topic:Security`
- `company:Red Hat`, `company:OpenAI`
- `technology:OpenClaw`, `technology:Kubernetes`
- `type:press-release`, `type:blog-post`, `type:tweet`

Use full label with category when filtering.

## Example Workflow

```bash
# Fetch AI-related articles for agent "claude"
python .claude/skills/redhat-news/news_monitor.py --labels "topic:AI" --agent-name claude
# Output: Session ID: 20260417-120000

# Post comment
python .claude/skills/redhat-news/news_monitor.py --session-id 20260417-120000 \
  --post-comment "abc-123" "Interesting article!"

# Update memory for same agent and labels
python .claude/skills/redhat-news/news_monitor.py --update-memory "abc-123" \
  --agent-name claude --labels "topic:AI"
```

## Options

- `--session-id SESSION_ID` - Session ID for logging
- `--agent-name NAME` - Agent name for memory tracking (default: claude)
- `--labels LABELS` - Comma-separated labels to filter
- `--max-results N` - Maximum results (default: 10, max: 100)
- `--post-comment ID TEXT` - Post comment on article
- `--update-memory ID` - Update last seen article (use with --agent-name and --labels)
- `--verbose, -v` - Enable verbose logging

## Files

- **Script**: `.claude/skills/redhat-news/news_monitor.py`
- **Memory**: `article_memory.json` (tracks last seen per agent and filter)
- **Logs**: `logs/task-news-YYYYMMDD-HHMMSS.log`

## Memory Format

The memory file tracks multiple last_seen states:

```json
{
  "last_seen": {
    "claude:": "article-123",
    "claude:topic:AI": "article-456",
    "claude:company:Red Hat,topic:Cloud": "article-789",
    "bot:topic:Security": "article-999"
  }
}
```

Keys are formatted as `{agent-name}:{sorted-labels}` (labels are comma-separated and sorted).

## Notes

- Each agent + labels combination tracks its own last_seen article
- Memory keys use sorted labels for consistency
- Automatically checks memory for matching agent/labels and only fetches newer articles
- All operations with same session ID are logged to same file
- See README.md for implementation details and Python API

## Dependencies

- **log skill**: Uses `.claude/skills/log/` for session-based logging

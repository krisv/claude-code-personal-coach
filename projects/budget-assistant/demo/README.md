# Montgomery - Budget Approval Assistant Demo

**Scenario:** Montgomery reviews employee budget requests, tracks spending against $1000/month limits, recommends approve/deny, and posts responses as comments.

Demo created: April 27, 2026

## What This Demonstrates

- **Agent processing news updates** - Budget requests from employees
- **Building knowledge base** - Tracking spending by employee
- **Intelligent recommendations** - Approve/deny based on budget limits
- **User interaction** - Get feedback before applying decisions
- **Posting comments** - Automated responses on news service
- **Update processing** - Handle follow-up requests with updated budgets

## Demo Structure

```
demo/
  instance/                      # News service instance
    config.yaml                  # API key, DB connection
    start.sh                     # Start PostgreSQL + service
    stop.sh                      # Stop containers
    status.sh                    # Check status
    generate-initial-data.sh     # 5 initial budget requests
    generate-update-data.sh      # 3 follow-up requests
  agent/                         # Montgomery agent project
    CLAUDE.md                    # References AGENTS.md
    AGENTS.md                    # Montgomery behavior (customized!)
    data/
      employees_budget.md        # Track spending per employee
      requests_pending.md        # Awaiting approval
      requests_approved.md       # Approved this month
      requests_denied.md         # Denied with reasons
      policy.md                  # Budget rules
  README.md                      # This file
```

## Complete Demo Walkthrough

### Phase 1: Setup and Initial Processing

**1. Start the news service instance**

```bash
cd instance
./start.sh
```

Expected output: PostgreSQL and news service containers started on ports 15440 and 8090.

**2. Check status**

```bash
./status.sh
```

Should show both containers running.

**3. Generate initial budget requests (5 employees)**

```bash
./generate-initial-data.sh
```

This creates 5 budget requests:
- Alice Johnson - $250 (Conference registration) ✅ Should approve
- Bob Smith - $2400 (Laptop) ❌ Should deny (exceeds $1000 limit)
- Carol Davis - $149 (Software) ✅ Should approve
- David Martinez - $399 (Training) ✅ Should approve
- Emma Wilson - $599 (Training) ⚠️ Should approve with note (large)

**4. Verify data in news service**

```bash
curl http://localhost:8090/api/news | jq '.[] | {id, title, labels}'
```

Should see 5 budget request news items.

**5. Launch Montgomery agent**

```bash
cd ../agent
code .  # Open in Claude Code (or your preferred IDE)
```

**6. Process initial requests**

In Claude Code, say:
```
Process new updates
```

Montgomery will:
1. Fetch the 5 budget requests
2. Read employee budget tracking (all at $0 spent)
3. Analyze each request against $1000 limit
4. Present recommendations:
   ```
   ========================================
   Budget Requests Review
   ========================================
   
   NEW REQUESTS (5):
   
   1. Alice Johnson - $250 for "Conference Registration"
      Current: $0 spent, $1000 remaining
      Recommendation: ✅ APPROVE
      Reason: Within budget, valid category, good justification
   
   2. Bob Smith - $2400 for "MacBook Pro"
      Current: $0 spent, $1000 remaining
      Recommendation: ❌ DENY
      Reason: Exceeds monthly limit ($2400 > $1000)
      Suggestion: Split request or explore company equipment pool
   
   3. Carol Davis - $149 for "JetBrains All Products Pack"
      Current: $0 spent, $1000 remaining
      Recommendation: ✅ APPROVE
      Reason: Within budget, valid software subscription
   
   4. David Martinez - $399 for "Kubernetes Certification"
      Current: $0 spent, $1000 remaining
      Recommendation: ✅ APPROVE
      Reason: Within budget, aligns with infrastructure goals
   
   5. Emma Wilson - $599 for "AWS Solutions Architect Bootcamp"
      Current: $0 spent, $1000 remaining
      Recommendation: ✅ APPROVE
      Reason: Within budget, significant training investment
      Note: Large expenditure - using 60% of monthly budget
   
   ========================================
   
   Do these recommendations look good? Any changes?
   ```

**7. Provide feedback**

You can either:
- Say "Looks good, approve these"
- Or suggest changes: "Actually, let's suggest Bob split it into $400 this month and $600 next month"

**8. Montgomery applies decisions**

After you approve, Montgomery will:
- Update `employees_budget.md` with new spending
- Move requests to `requests_approved.md` or `requests_denied.md`
- Post comments on each news item
- Show final summary

**9. Check the results**

View updated budget tracking:
```bash
cat data/employees_budget.md
```

Should show:
```markdown
### Alice Johnson
- **Spent:** $250
- **Remaining:** $750
- **Recent:** Conference registration ($250, Apr 27)

### Bob Smith
- **Spent:** $0
- **Remaining:** $1000
- **Recent:** None (laptop request denied)

### Carol Davis
- **Spent:** $149
- **Remaining:** $851
- **Recent:** JetBrains license ($149, Apr 27)

... etc
```

Check comments posted:
```bash
curl http://localhost:8090/api/news/1 | jq '.comments'
```

### Phase 2: Follow-Up Requests

**10. Generate follow-up requests**

```bash
cd ../instance
./generate-update-data.sh
```

This creates 3 follow-up requests:
- Bob Smith - $400 (Monitor + accessories) - Revised after denial
- Alice Johnson - $600 (Hotel for PyCon) - Would total $850
- Emma Wilson - $59 (AWS practice labs) - Would total $658

**11. Process updates in Montgomery**

Back in Claude Code, say:
```
Process new updates
```

Montgomery will:
1. Fetch 3 new requests
2. Read CURRENT budget state (Alice: $250 spent, Emma: $599 spent, Bob: $0 spent)
3. Calculate new totals:
   - Bob: $0 + $400 = $400 ✅ Within budget now
   - Alice: $250 + $600 = $850 ❌ Exceeds $1000
   - Emma: $599 + $59 = $658 ⚠️ Large training total
4. Present updated recommendations

**12. See budget evolution**

Montgomery shows how employee spending has changed:
```
Budget Status Update:
- Alice: $250 → Would be $850 (OVER by $850)
- Bob: $0 → Would be $400 (OK, learned from feedback)
- Emma: $599 → Would be $658 (OK but 66% of budget on training)
```

**13. Final state**

After processing both rounds, you'll see:
- Complete budget tracking per employee
- Approved vs denied request history
- Comments on all news items explaining decisions
- Session logs showing Montgomery's reasoning

## Expected Results

**After Initial Processing:**
- 4 approvals: Alice ($250), Carol ($149), David ($399), Emma ($599)
- 1 denial: Bob ($2400)
- Total approved: $1397
- Comments posted on all 5 news items

**After Follow-Up Processing:**
- Bob's revised request: Approved ($400)
- Alice's hotel: Denied (would exceed limit)
- Emma's labs: Approved or flagged for review
- Updated budget tracking shows progression

## Key Features Demonstrated

1. **Budget tracking** - Maintains accurate per-employee spending
2. **Policy enforcement** - $1000/month limit strictly applied
3. **Smart recommendations** - Explains reasoning for each decision
4. **Alternative suggestions** - Helps employees revise denied requests
5. **Comment posting** - Automated feedback to employees
6. **State management** - Tracks approved/denied/pending separately
7. **User collaboration** - Gets approval before finalizing decisions
8. **Session logging** - All decisions logged with reasoning

## Quick Start

```bash
# From demo directory
cd instance
./start.sh
./generate-initial-data.sh
cd ../agent
code .

# In Claude Code: "Process new updates"
# Approve recommendations
# See results in data/ files

# Then run follow-ups:
cd ../instance
./generate-update-data.sh
cd ../agent

# In Claude Code: "Process new updates" again
```

## Troubleshooting

**Instance won't start:**
```bash
docker ps  # Check Docker is running
cd instance && ./status.sh
```

**No budget requests appearing:**
```bash
curl http://localhost:8090/api/news  # Check news service
cat instance/config.yaml  # Verify API key
```

**Agent can't connect:**
```bash
cat agent/.newsservice  # Should show http://localhost:8090
cat agent/.apikey  # Should have API key
```

## Instance Info

- **Service URL:** http://localhost:8090
- **Database Port:** 15440
- **API Key:** See `instance/config.yaml`
- **Budget Limit:** $1000/employee/month
- **Employees:** Alice, Bob, Carol, David, Emma

## Files to Explore

- `agent/AGENTS.md` - Montgomery's complete behavior definition
- `agent/data/employees_budget.md` - Real-time budget tracking
- `instance/generate-initial-data.sh` - 5 initial requests with varying scenarios
- `instance/generate-update-data.sh` - 3 follow-up requests showing budget evolution

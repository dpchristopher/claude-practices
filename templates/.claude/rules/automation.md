---
paths:
  - "**/pipeline*.py"
  - "**/*cron*"
  - "**/scheduled*"
  - "scripts/**/*"
---

# Automation Rules

> Auto-loaded at session start. Apply to any scripted pipeline, scheduled task, or batch process.

---

## Core Principle: Idempotence

Every automation script must be safe to run twice. If it runs again on the same input, it produces the same result without duplicating or corrupting data.

**How to achieve it:**
- Check if output already exists before creating it
- Use upserts (insert or update) instead of blind inserts
- Track processed items in a state file or database column
- Delete and recreate rather than appending blindly

---

## Error Handling Requirements

Every automation script must:

1. **Log what it's doing** — timestamp, input, output, row counts
2. **Fail loudly** — raise exceptions, don't swallow errors silently
3. **Report partial failures** — if 3 of 100 items fail, log which 3 and continue
4. **Leave a trace** — write a summary to a log file or stdout on completion

```python
import logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s',
    handlers=[logging.FileHandler('run.log'), logging.StreamHandler()]
)
```

---

## Testing Before Scheduling

Before scheduling any script:

- [ ] Run manually with a small sample (10-20 records) and verify output
- [ ] Run again on same sample — verify idempotent (no duplicates)
- [ ] Run with empty input — verify graceful handling
- [ ] Run with bad/malformed input — verify error is logged, not crash
- [ ] Verify log output is readable and actionable
- [ ] Test the scheduled trigger (cron syntax, event condition) in isolation

---

## Scheduling Pattern

```python
# Good: script checks its own preconditions
def main():
    if already_ran_today():
        logging.info("Already ran today, skipping")
        return
    
    records = fetch_pending_records()
    if not records:
        logging.info("No pending records, nothing to do")
        return
    
    process(records)
    mark_completed()
    logging.info(f"Completed: {len(records)} records processed")

if __name__ == "__main__":
    main()
```

---

## Pipeline Testing

For multi-step pipelines:

1. Test each step independently with fixtures
2. Test the full pipeline end-to-end with a small sample
3. Assert on output shape, type, and value ranges — not just "no crash"
4. Keep fixtures in `tests/fixtures/` — small, representative, checked into git

---

## Dependency Pinning

```bash
# After installing deps, always pin:
pip freeze > requirements.txt

# On a new machine:
pip install -r requirements.txt
```

Never use unpinned dependencies in production automation — a library update can silently break behavior.

---

## State File Pattern

For long-running or resumable pipelines, track progress in a state file:

```json
{
  "last_run": "2026-06-16T14:30:00",
  "last_processed_id": 10482,
  "records_processed": 3847,
  "status": "completed"
}
```

On next run, read state file first. Resume from `last_processed_id` if interrupted.

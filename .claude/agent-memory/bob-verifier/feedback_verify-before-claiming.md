---
name: verify-before-claiming
description: Before reporting a finding, check the test suite for a test that asserts the behavior deliberately — and run a probe script rather than reasoning about semantics
metadata:
  type: feedback
---

Two rules that keep adversarial reviews honest on this user's work:

1. **Grep the test suite for the behavior before calling it a bug.** If a test asserts it with a
   rationale docstring, it is a design decision, not a gap.
2. **Write a throwaway probe script and run it.** Do not reason about Python equality, NaN,
   subclass, or serialization semantics from memory.

**Why:** In the `surgical-change` review I nearly reported `Decimal('100.00') == Decimal('100.0')`
being treated as unchanged as a fail-open bug; `test_decimal_trailing_zeros_are_not_a_change`
documents it as intentional (scale normalization would cause constant false alarms). The user's
hard rule is no done/fixed claims without pasted command + output — the same standard applies to
*gap* claims.

**How to apply:** For every candidate finding, produce (a) a concrete input, (b) actual observed
output from a run, (c) a check that no existing test blesses the behavior. Drop anything failing
any of the three. Say plainly when a category yields nothing rather than filling it.

3. **A plan's `grep -c "exact string"` evidence command failing is NOT a finding.** In the Wave 7
   review, four plan greps returned the "wrong" count purely because prose wrapped across lines
   ("inherits the maker's blind spots"), a heading gained a cross-reference (counted twice), or
   the shipped wording improved on the planned wording ("state two numbers" vs "state the child
   count"). Every one was sound in substance. Read the actual text before reporting a grep miss —
   and report the criterion as *not machine-checkable as written*, not as a failure.

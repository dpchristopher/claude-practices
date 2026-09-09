# Safe Autonomy Rules

> Auto-loaded at session start. Applies whenever Claude runs unattended — loops, scheduled
> jobs, or any work you are not watching step by step. Cap what the agent *can* do, not just
> what it does.

---

## Environment First

Contain at the environment layer before trusting behavior. The deterministic boundary is what
holds when the model misjudges. Prefer a sandbox / container / git worktree with limited scope
over "the model will be careful."

---

## Never — on a repo with real credentials, data, or push access:

- Run with all permission prompts disabled (`--dangerously-skip-permissions`). That is *no
  protection*. Reserve unattended full-auto for throwaway sandboxes only.
- Let an unattended loop touch: production databases, `.env` / secrets / keystores, `git push`
  to main or a remote, branch deletion, or anything outside the project worktree.
- Let a loop both **modify** and **push** in the same unsupervised run.

---

## Every Unattended Loop Needs Brakes

- A hard **iteration cap** and a **token/cost ceiling**, set BEFORE it runs.
- A clean `git status` **checkpoint commit** between iterations, so a bad iteration is revertable.
- **Stop-and-escalate on no progress:** if the same command fails ~3 times, stop and flag —
  don't spin and burn tokens.
- **State in a file** outside the conversation (a progress log), so the loop can resume or be
  audited.

---

## Allowlist = Capability Grant

Every network destination or credential you expose to the loop is attack surface. Keep it
minimal. Credentials stay in the host — never inside the loop's environment.

---

## Auto-approval Is Not Safety

Auto-approving actions cuts toil; it does not make unattended work safe on anything high-stakes
(real client data, production systems, financial records). When the blast radius is real, a
human stays in the loop.

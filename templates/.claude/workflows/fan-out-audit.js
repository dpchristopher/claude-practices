// fan-out-audit.js — audit every changed file in parallel, then merge findings into one ranked list.
// Adapt the agent prompts/names to your repo. Run via: "use a workflow to run fan-out-audit"
// or save/run as a command. Native caps: 16 concurrent / 1000 total agents per run.
export const meta = {
  name: 'fan-out-audit',
  description: 'Audit each changed file for correctness + security, then merge into one ranked report.',
}

// 1. Discover the changed files.
const changed = await agent(
  'List every file changed vs. the main branch (git diff --name-only main). Return just the paths.',
  { schema: { type: 'object', required: ['files'], properties: { files: { type: 'array', items: { type: 'string' } } } } },
)

// 2. Fan out: one focused review per file (cheap-model per-file pass).
const findings = await pipeline(changed.files, file =>
  agent(`Review ${file} for correctness bugs and hardcoded secrets. List concrete issues with line refs, or "clean".`, { label: file }),
)

// 3. Merge: one agent ranks and de-duplicates all findings.
const report = await agent(
  `Merge these per-file review results into ONE ranked, de-duplicated findings list, most severe first:\n${JSON.stringify(findings)}`,
)
return report

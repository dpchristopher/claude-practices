// fix-until-green.js — run the project check, fix failures, repeat until green or stalled.
// This is the runnable form of the loop rule's stuck-loop-detection doctrine.
// Adapt CHECK_CMD to your stack. Run via: "use a workflow to run fix-until-green".
export const meta = {
  name: 'fix-until-green',
  description: 'Run the project check and keep fixing failures until it passes or two rounds make no progress.',
}

const CHECK_CMD = (args && args.check) || 'npm test'   // pass {check:"pytest -q"} to override
const MAX_ROUNDS = 6
let lastFailures = null

for (let round = 1; round <= MAX_ROUNDS; round++) {
  const result = await agent(
    `Run \`${CHECK_CMD}\`. If it passes, reply exactly "GREEN". If it fails, fix the FIRST failure only, then reply with a one-line summary of what failed.`,
    { label: `round ${round}` },
  )
  if (typeof result === 'string' && result.includes('GREEN')) return `Passed on round ${round}.`
  // Stuck-loop detection: same failure signature twice in a row → stop and surface.
  if (lastFailures !== null && String(result) === lastFailures) {
    return `Stopped at round ${round}: no progress (same failure twice). Human review needed.\nLast failure: ${result}`
  }
  lastFailures = String(result)
}
return `Stopped after ${MAX_ROUNDS} rounds without going green. Human review needed.`

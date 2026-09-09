# Phase 5 — Client-Facing Patterns

> **Assembly note.** The Phase 5 agent dispatched four children, returned a status update as
> its final answer, and terminated — orphaning them and writing nothing. See the Phase 5
> process-failure section in `FINDINGS-LEDGER.md`. This file is being assembled by the parent
> session from the orphans' returns as they land, so the work already paid for is not wasted.
> Sections appear in the order the orphans return, not the order of the original questions.

**Status: COMPLETE — all 4 orphans salvaged.** Verdict at the foot of this file.


---

## Q1 / Q5 — What consultancies actually deliver, and how they price

*Source: orphaned child agent, returned 2026-09-08. Labels are the agent's own; it separated
practitioner accounts from vendor marketing throughout, which is the discipline that makes this
section usable at all.*

### The one genuinely useful engagement account

**Ed Forson — 4-week engagement, data-analytics startup**
[edforson.substack.com](https://edforson.substack.com/p/from-60-to-98-inside-a-4-week-ai) · 2025 ·
**PRACTITIONER** — named individual describing a specific engagement.

Deliverables were concrete and, notably, mostly *verification infrastructure*:

- An evaluation suite of 35 test cases across 6 business domains
- A four-agent pipeline (planner, code generator, verifier, summarizer)
- A self-healing retry mechanism, capped at 3 attempts
- 79 unit tests plus the eval suite
- Architecture docs and handover materials

Measured result: query completion 60% → 98%; response time down to 20–30s.

A real pivot, disclosed: they started on OpenAI's advanced reasoning model, found it took
"over 60 seconds for simple queries and was intermittently flaky," and swapped to a faster,
less capable model.

The line worth stealing, on methodology:

> "Demand evidence before pivots. If someone tells you to throw out an architecture, the right
> response is 'show me the eval results.'"

No pricing disclosed.

**Why this one matters for Daniel:** the deliverable was an eval suite and a verifier agent —
the same shape as this kit's `carl-evals` and `bob-verifier`. The retry cap of 3 independently
matches `loop-cost-discipline.md`'s 3-iteration cap. Convergent, not borrowed.

### Solo-consultant positioning, from someone who failed at it first

**Claudia Faith — tried enterprise, closed zero, pivoted to SMEs**
[levelupwithai.substack.com](https://levelupwithai.substack.com/p/i-tried-to-close-big-companies-this) ·
2026 · **PRACTITIONER**, recounting her own failure.

Reasons she gives for zero enterprise closes: every big firm already has an AI practice; "one
person doesn't look safe to a team signing off on six figures"; enterprise budget cycles do not
match a solo consultant's cash flow.

Her pivot, and the two lines that transfer directly:

> "Sell to people who can actually say yes" — in SMEs "the person you are talking to usually
> *is* the decision. No committee, no procurement department."

> "Offer to bring them customers. Money coming in beats money saved every time."

**Direct application:** Betsey Brown Travel is exactly the SME shape she describes — the owner
is the decision-maker. And the second quote reframes the pitch: an inquiry-form that captures
more leads is revenue, whereas a systems audit is cost-saving. The first sells more easily.

### Published price points

Only one source attaches real dollar figures to a described scope, and it is vendor marketing:

| Source | Scope | Price |
|---|---|---|
| [alejandroarce.com](https://alejandroarce.com/blog/claude-code-data-entry-automation/) (**VENDOR**) | "AI Audit," creditable toward a build | $1,500 flat |
| same | Invoice automation into QuickBooks | $3,200 |
| same | Multi-supplier inventory reconciliation | $4,500 |
| [justinmckelvey.com](https://justinmckelvey.com/blog/why-ai-implementations-fail) (**VENDOR**) | Two-week "AI Readiness Assessment" | $2,500 flat |

Marketplace context, all vendor/aggregator content and **not verified** — market-rate signal only:
Fiverr guides put simple rule-based workflows at $100–300 and mid-level ML/API work at $300–800;
Upwork lists automation engineers around $35–60/hr; SEO aggregators claim solo rates of
$75–200/hr and retainers of $2,500–15,000/month.

The pattern across every practitioner source: **flat fee tied to a defined deliverable**, not
hourly. Upwork's own guidance says project pricing is preferred "to tie investment to a defined
deliverable rather than open-ended hours."

### Scoping discipline

**Elliott Johnson (EKB Labs)**, [Fiverr community blog](https://community.fiverr.com/en/public/blogs/i-sell-results-not-ai-why-my-ai-consultant-clients-return-for-15-projects-2025-12-03) ·
2025-12-03 · **PRACTITIONER but self-promotional** — posted on the platform where he sells.

> "tight scoping, honest conversations about what AI can and cannot do, and designing for
> failure paths"

> "Clients do not need another shiny chatbot. They need a reliable colleague."

> "I rarely sell 'AI'. I sell fewer manual hours, faster response times."

His retention and ROI figures (80% retention, 4.2x ROI, €1,900/month saved) are self-reported
on his own marketing surface with no corroboration — **claims, not facts.**

### The credibility problem, stated by an outsider

[HN thread](https://news.ycombinator.com/item?id=45409024) · 2025 · practitioner commentary.
A commenter describes a course being promoted on the premise that "anyone can label themselves
'AI automation expert' and charge thousands of dollars for it, then just use vibe coding tools
to do the job or outsource it."

Worth knowing as market context: Daniel will be selling into a category with a live credibility
problem. The Forson-style answer — lead with an eval suite and measured before/after — is the
differentiator, and it is one this kit is unusually well set up to deliver.

### Not verified / discarded

- `goingsolo.substack.com/p/embracing-the-solo-consulting-mindset` — **404**, unusable
- `devblog.xero.com/build-a-crm-with-claude-code-xero` — **403** on fetch; snippet suggests a
  Xero Developer blog post on building a CRM with Claude Code, but unverified. Worth a manual
  retry — it is the only potential Claude-Code-specific client build found.
- `thedataecosystem.substack.com/p/consulting-in-an-ai-world` — fetched; contains no concrete
  pricing, scope, timeline, or maintenance detail. Flagged so it is not mistaken for data.
- All self-reported vendor metrics (96%/93%/99% accuracy, $53M+ client revenue, 10-week ROI) —
  claims on the seller's own page, no third-party corroboration.
- **No genuine post-mortem was found.** A piece titled "why AI implementations fail" looked
  promising and turned out to be an archetype framework funnelling to a $2,500 assessment, with
  zero named engagements. The absence of honest failure write-ups in this space is itself a
  finding.
- No substantive Reddit discussion surfaced despite targeted search; results returned Gumroad
  listings and SEO blogs. May exist, was not found.

---

## Q3 — Travel-agency automation (applies to Betsey Brown Travel)

*Source: orphaned child agent, returned 2026-09-08. Its own summary: "overwhelmingly vendor/SEO
content-marketing noise." ~15 searches, ~10 full fetches, and it found **zero** verifiable
accounts of an independent travel agent describing their own automation workflow. Reporting that
plainly rather than dressing thin material up.*

### The finding that actually matters for Betsey

**90% of unsupervised AI itineraries contain an error.**
[north9.agency](https://north9.agency/ai-travel-itineraries/) · 2024-04-08 ·
**Independent study, but published by a travel-marketing agency** — not peer-reviewed, not
replicated, and it tested vanilla ChatGPT rather than a purpose-built workflow. Directional, not
definitive.

Method: 10 two-day itineraries for each of 10 major cities, manually checked.

| Failure | Rate |
|---|---|
| At least one error | 90% |
| Venue suggested outside opening hours | 52% |
| Routing requiring illogical backtracking | 25% |
| **Permanently closed venue recommended** | **24%** |

One itinerary cited a fabricated Rome cafe ("Antico Caffe Ponit").

**Why this is the most useful thing in the phase:** it is a concrete, numerate argument for
where Betsey's value actually sits. A luxury travel agent's product is *curation that is
verified* — the 24% closed-venue rate is precisely the failure a client would blame her for.
This says: draft with AI, never send unreviewed, and the review step is the billable expertise
rather than an overhead. It also cautions against any "AI itinerary generator" feature on her
site.

### The one credible practitioner account (not travel-specific)

[beginnersinai.org](https://beginnersinai.org/automated-small-business-ai/) · 2026-05 ·
**PRACTITIONER**, one-person consulting business. Site also sells courses, so commercial
incentive exists — but the account reads as genuine, and the tell is the candor below.

Tracked before/after via Toggl across two months:

| Task | Before | After |
|---|---|---|
| Customer support email | 12 hrs/wk | 3 |
| Content creation | 8 | 3 |
| Meeting scheduling and prep | 4 | 0.5 |
| Bookkeeping and quotes | 6 | 4 |

Claimed ~19.5 hrs/week recovered and 35% revenue growth — self-reported, unverified.

**The part worth copying is where he pulled back:** he refused full auto-send on client emails,
rejected AI for sensitive matters, and *rehired a human bookkeeper at $180/month* rather than
automate bookkeeping. That "here's what I chose not to automate" detail is what distinguishes a
real account from vendor copy — and it is the honest shape of a proposal to a client.

### Vendor claims, recorded as claims

Two consultancy write-ups describe travel-client engagements. Both are written by the seller,
neither has client-side corroboration:

- [aistrategywithmaramsay](https://aistrategywithmaramsay.substack.com/p/how-we-helped-a-travel-agency-owner) ·
  2025-04-03 · Tally → Zapier → Zoho Zia → ChatGPT → Motion → MailerLite. Claims 80% faster
  inquiry response and doubled lead-to-booking conversion — measured **7 days** after launch.
- [connex.digital](https://connex.digital/blog/how-airtable-and-zapier-transformed-a-travel-companys-customer-experience/) ·
  2024-12-10 · Australian youth-adventure operator, 4,000+ travelers/yr. Rezdy → Airtable →
  Zapier → Timeline.ai. Claims 600+ automated WhatsApp messages monthly.

The **stack shape** is the transferable part — intake form, then CRM, then automation, then
messaging — not the numbers.

### A caution worth keeping despite its source

Repeated across several vendor CRM-cleanup pages, and sensible even though no practitioner is
attached to it:

> AI cannot fix your CRM processes. If new duplicates are created daily because there is no
> dedup logic at the point of entry, AI cleanup is a recurring expense instead of a one-time fix.

Directly relevant to Betsey's systems-audit workstream: fix the intake path, or the cleanup
becomes a subscription.

### Gaps the agent flagged honestly

- **Reddit was inaccessible** — WebFetch is blocked on reddit.com, and indexed search surfaced
  no thread content. `r/travelagents` almost certainly has real practitioner discussion on
  exactly this. A human with a browser should check it; that is not a research failure so much
  as a tooling limit.
- Facebook groups for independent travel advisors are where this shop-talk actually happens and
  are not crawlable at all.
- Host Agency Reviews has published agent-survey data and runs a podcast; blog content was
  vendor-grade, but transcripts were not reached.
- A travel-agent byline piece ("Stop Trusting AI for Travel Planning," 2025-12-01) turned out to
  cite third-party incidents rather than his own client cases — anecdotal, not documented.

---

## Q4 / Q6 — Handing Claude to a non-technical client, and liability

*Source: orphaned child agent, returned 2026-09-08. The strongest of the four returns.*

### The finding with real consequences

**A consultant doing client work on a personal Pro or Max account is under consumer terms with
no DPA.** Anthropic's own scoping says so:

- The [DPA](https://support.claude.com/en/articles/7996862-how-do-i-view-and-sign-your-data-processing-addendum-dpa)
  applies **only** to commercial products — Claude for Work and the API. Not Free, Pro, or Max.
- The [consumer privacy page](https://privacy.claude.com/en/articles/10458704-how-does-anthropic-protect-the-personal-data-of-claude-users)
  states it covers Free/Pro/Max/Claude Code and is "not commercial products like Claude for Work
  or the API, which have separate privacy documentation."
- And when working inside a client's own subscription: "If you access Claude via a third-party
  platform or service provider, your use of Claude in those cases is governed by the third-party
  platform's terms of service." **Whose account does the accessing determines whose terms apply.**

Doc-grounded, not inferred. It bears directly on the Betsey engagement, which runs through
Daniel's own accounts against her Drive and Asana.

A practitioner reaches the same conclusion independently. **Bradford Tobin**,
[bradfordtobin.substack.com](https://bradfordtobin.substack.com/p/using-ai-in-client-work),
multi-industry consultant writing from his own practice:

> "The biggest risk isn't the output; it's the input. Uploading a client's sensitive PII... into
> a standard (non-Enterprise) AI account can be a breach of your NDA and data privacy laws like
> GDPR or CCPA."

His practice is "only use Team or Enterprise tiers for client work" — immediately caveated with
"even when using an enterprise account, nothing is safe!"

His contract disclosure clause, worth copying close to verbatim:

> "Consultant utilizes AI-assisted tools to enhance efficiency and analysis. Consultant maintains
> human oversight over all outputs, remains responsible for the accuracy of final deliverables."

Three-tier disclosure framework: none needed for mechanical work (grammar, formatting);
discretionary when AI collaborates; **mandatory when AI creates the substance**, for IP and
liability reasons. Plus: "Never let AI have the final word. If you didn't verify it, don't send
it out."

### What actually breaks for non-technical users

1. **Terminal intimidation is the top blocker for Claude Code.** Michael Crist
   ([michaelcrist.substack.com](https://michaelcrist.substack.com/p/claude-code)) reports an
   employee who avoided it entirely "specifically because the terminal was too intimidating."
   People don't push through — they don't start.
2. **Fear of irreversible action.** Crist: "Every time it asked to do something on my computer,
   I'd Google the command just to make sure it wasn't going to break something."
3. **Anthropic's own safety guidance assumes security literacy ordinary users lack.** Simon
   Willison, [on Cowork](https://simonwillison.net/2026/Jan/12/claude-cowork/): *"I do not think
   it is fair to tell regular non-programmer users to watch out for 'suspicious actions that may
   indicate prompt injection'!"* — the sharpest line in the phase, and it lands directly on
   ledger items B7 and P5.
4. **UI friction in Cowork** — Willison hit a sidebar/artifact layout bug on first use.
5. **Bimodal misuse**: users either treat Claude as a plain chatbot and get mediocre results, or
   assume customization is too technical and never touch skills or instructions. Corroborated
   across several authors; only Crist fetched in full.

**Implication for both clients: hand them claude.ai with Projects and Skills, never Claude Code.**
The terminal is the adoption cliff.

### The handoff path (official docs)

- **[Projects](https://support.claude.com/en/articles/9517075-what-are-projects)** — self-contained
  workspaces with their own knowledge base and instructions. Free tier gets 5; paid expands
  retrieval "tenfold." Team/Enterprise share org-wide with view/edit roles.
- **[Skills](https://support.claude.com/en/articles/12512180-use-skills-in-claude)** — on every
  tier including Free, but **requires code execution enabled** (Settings > Capabilities).
  Non-technical path: Customize > Skills, toggle on. "Claude will automatically use these tools
  when relevant. You don't need to explicitly invoke them."
- **[Cowork](https://support.claude.com/en/articles/13345190-get-started-with-claude-cowork)** —
  paid only. Local file access, scheduled cloud tasks, browser control, produces real deliverables.
  No session sharing yet.

### Security guidance worth adopting

From [General Analysis](https://generalanalysis.com/guides/security-guidance-for-claude-cowork-and-risks),
an AI-security firm — vendor-adjacent but specific and tradeoff-aware:

- "Create dedicated Cowork working folders for approved tasks. Keep credential stores, .env
  files, SSH keys, cloud config, browser profiles, shell history, finance exports, legal
  archives, and customer data **out** of those folders."
- "Use least-privilege OAuth scopes and avoid broad admin grants. Require approval for external
  sends, public links, permission changes, record deletion, customer-impacting actions."

The first already matches `C:\Clients\CLAUDE.md`'s client-data rule. The second is implemented
nowhere.

### Not verified

- **The actual DPA text was never fetched.** All specifics (SCCs, UK IDTA, Irish law,
  zero-retention, HIPAA BAA) come from third-party compliance-vendor summaries. **Read the real
  DPA before relying on any of it.**
- Google Workspace connector claims — "mirrors your existing permissions," "not trained on
  connector data" — from a search snippet, not the live page. Verify before quoting to a client.
- Contract-template sites (liability caps at 3 months' fees, 30-day deletion) are template-vendor
  copy, **not** practitioner-validated norms.

---

## Q2 — Nonprofit automation (applies to The Caregiver Club)

*Source: orphaned child agent, returned 2026-09-08. Its verdict: dominated by near-identical
vendor listicles recycling the same unsourced claims. Genuine accounts from a specific person at
a specific small org are rare.*

### The immediately actionable finding

**Claude for Nonprofits exists: up to 75% off Team/Enterprise, and Team at $8/user/month with a
2-seat minimum for orgs under 20 people.**
[claude.com/solutions/nonprofits](https://claude.com/solutions/nonprofits) ·
[announcement](https://www.anthropic.com/news/claude-for-nonprofits) · 2025-12-02

Eligibility: 501(c)(3) and international equivalents, verified through Goodstack.

**This changes the Caregiver Club engagement.** The assumption was a zero-budget org on free
tiers. $16/month for two seats on Team is a different proposition — and per the Q4/Q6 section
above, **Team is also the tier that carries a DPA.** The cheap path and the defensible-data-
handling path turn out to be the same path.

Listed use cases match the brief exactly: grant-proposal drafting, donor segmentation and email
sequences, volunteer role descriptions and onboarding, turning survey data into board decks.

Caveats worth stating: the named case studies (Epilepsy Foundation, IRC, IDinsight, Robin Hood)
are all mid-to-large orgs with technical staff. The Blackbaud/Benevity/Candid connectors are
enterprise-CRM integrations, not something a no-technical-staff org sets up alone. And the "16×
faster" style figures are partner-reported, not independently verified.

### The best small-org workflow found

**SisterLove** (~18 people, reproductive-justice nonprofit), via a
[Zapier case study](https://zapier.com/blog/how-sisterlove-scaled-content-creation-with-ai-and-automation/) —
vendor-published, but it names a real org and a real staffer, which is more than most:

A staffer types a keyword into a Google Sheet cell. Zapier sends it to an LLM, which returns an
800–1,000 word blog post into the matching row — then fans out to generate an email, a
short-video outline, social captions, and text messages. A Google Form lets other staff submit
ideas into the same pipeline.

Claimed: 6–8 hours per topic down to minutes; 190+ hours saved in under 9 months. Vendor-reported,
unverified.

**The transferable shape is the spreadsheet-as-interface.** A non-technical person types in a
cell; automation does the rest. That sidesteps every adoption blocker in the Q4/Q6 section — no
terminal, no prompt engineering, no new tool to learn.

### A zero-budget pilot framework

[The CLASS Consulting Group](https://www.theclassconsultinggroup.org/post/how-small-nonprofits-can-pilot-ai-operations-without-new-software-or-budget) —
consultant advice, not a documented case:

Identify repetitive tasks → pick one free tool → build a shared Google Doc of prompt templates →
run a 2-week test measuring time saved → compute ROI. Their illustrative math: 20 min/week × 52
weeks × $30/hr ≈ $510/year reclaimed.

Notably one of the few sources naming **Claude.ai alongside ChatGPT** as a viable free-tier
option for a small org.

### Honest friction, which the vendor content never shows

Deb Stuligross, a nonprofit-technology consultant, [strefatech.substack.com](https://strefatech.substack.com/p/116-bro-wtf) ·
2025-02-05 — a real internal pilot at a ~25-person remote nonprofit. A data analyst tried to get
an LLM to turn CRM exports into a decent bar chart and got repeatedly "drab" output, prompting
the post's title. Kept here precisely because it is a failure account, and the only one found.

### Sector survey data

TechSoup + Tapp Network AI Benchmark Report, via
[blog.techsoup.org](https://blog.techsoup.org/posts/what-ai-means-for-nonprofits-in-2025-insights-from-the-ai-benchmark-report) ·
2025-02-21. TechSoup is a nonprofit-tech intermediary rather than an AI vendor, so this is closer
to independent sector research:

- ~25% of orgs use AI to streamline grant writing
- ~30% cite financial limits as the primary adoption barrier
- **>75% have no formal AI strategy**
- >60% of orgs under $1M budget are "exploring" AI

The full report may break out donor-management and volunteer-scheduling rates; only the summary
was read.

### Not verified

- OpenAI's nonprofit case studies (a "$20,000 grant in 12 minutes," 200+ applications vs. 90)
  read as marketing hyperbole and are vendor-published with no corroboration.
- Reddit's r/nonprofit was unreachable — same tooling limit as the other phases.
- The full TechSoup benchmark PDF was not accessed.

---

## Verdict

**The phase cleared its bar.** It required 2 patterns genuinely applicable to Betsey or The
Caregiver Club; it produced four that change what to actually do:

1. **Claude for Nonprofits at $8/user/month** — and Team is the tier that carries a DPA, so the
   cheap path and the compliant path coincide.
2. **The consumer-tier/no-DPA gap** — directly relevant to how the Betsey audit is being run today.
3. **The 90%-itinerary-error study** — a numerate argument that Betsey's verification *is* the
   billable expertise, and a caution against any AI-itinerary feature on her site.
4. **Spreadsheet-as-interface** — the handoff shape that avoids every adoption blocker found.

**Recommendation for the recurring sweep: KEEP, but narrow.** The general "what do AI
consultancies do" search is almost pure noise and should be dropped. The two threads worth
re-running monthly are Anthropic's own nonprofit/business program changes, and the
liability/data-handling picture — both are official-source questions with real answers, and both
change what Daniel can defensibly offer.

**A structural gap across all four returns:** Reddit and Facebook groups — where practitioners
in both of these industries actually talk — were unreachable by every agent. That is a tooling
limit, not an absence of material, and it means this phase systematically under-samples the most
candid sources.

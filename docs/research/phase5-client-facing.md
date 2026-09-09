# Phase 5 — Client-Facing Patterns

> **Assembly note.** The Phase 5 agent dispatched four children, returned a status update as
> its final answer, and terminated — orphaning them and writing nothing. See the Phase 5
> process-failure section in `FINDINGS-LEDGER.md`. This file is being assembled by the parent
> session from the orphans' returns as they land, so the work already paid for is not wasted.
> Sections appear in the order the orphans return, not the order of the original questions.

**Status: PARTIAL — 2 of 4 orphans returned.** Verdict on the phase's bar (2 patterns genuinely
applicable to Betsey or The Caregiver Club) is deferred until the rest land.

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

*Sections for Q2 (nonprofit automation) and Q4/Q6 (client handoff, liability) pending the
remaining orphans.*

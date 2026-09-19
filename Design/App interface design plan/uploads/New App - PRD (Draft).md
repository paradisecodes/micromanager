# New App — PRD (Draft)

2026-09-16 · @Someone

## Problem & Vision

Most people can't accurately account for where their time actually goes day to day — intentions and actual behavior diverge, and there's no easy way to see the gap. This app closes it: users log their activity in 15-minute increments over a two-week capture period, then receive an analysis of that data along with recommendations for improving how they spend their time.

## Target Users

Productivity-minded professionals and anyone looking to gain control over their calendar — people who suspect a gap between how they intend to spend their time and how they actually spend it, and want objective data to close it.

## Goals & Success Metrics

For the user: complete the two-week capture period, then receive an AI-generated report that categorizes how time was actually spent, illuminates patterns, and recommends specific ways to become more efficient.

For the app: audit completion rate — the percentage of users who finish a full two-week capture relative to total downloads — is the primary success metric.

## Core Features & MVP Scope

- **Time capture**: hourly notification prompts covering the prior 4 15-minute blocks; each block can be filled independently or copied forward with a quick "same as above" action (e.g., a 45-minute commute logs as driving in block one, then "same as above" for the next two)
- **Categories**: a default category set is provided on account creation; users can add, edit, or remove categories, with every 15-minute block required to fall into one
- **Daily qualitative check-in**: each morning, a quick follow-up about the previous day — mood and energy — captured once per day rather than per block, so the AI can correlate time-use patterns with how the day actually felt
- **Full-day accounting**: every 15-minute block across all 24 hours must be accounted for, with options to mark a block or period as sleep or skip
- **Two-week audit window**: capture runs for a fixed two-week period per audit
- **AI-generated report**: after the audit, time is categorized and analyzed to show where and how time is spent, cross-referenced against daily mood/energy ratings, with specific recommendations for improving efficiency
- **Repeatable audits**: since access is a one-time purchase, users can run a new audit whenever they want (e.g., after a calendar or role change)

## Out of Scope for v1

Deferred to future versions:

- Android app
- Apple Watch companion app
- Calendar or screen-time integrations
- Team or family sharing
- Web dashboard
- Multi-language support

## Competitive Landscape

Several apps already validate the core mechanic — structured, interval-based self-report over a fixed window — but none pair it with AI-generated analysis and recommendations the way this app plans to.

| App | Pricing | Capture method | AI-driven recommendations |
| --- | --- | --- | --- |
| [TimeAudit™](https://apps.apple.com/eg/app/timeaudit/id6498926800) | One-time purchase | Customizable interval (e.g., 15 min) over 3 days to 2 weeks; manual entry of activity, mood, and energy | No — manual charts and CSV export only |
| [ThenAudit](https://apps.apple.com/us/app/thenaudit-weekly-time-audit/id6753599426) | Freemium; IAP tiers up to a $119 lifetime unlock | 15-minute intervals over one 7-day audit | No — explicitly markets "no AI coaching" |
| [Attentionly](https://apps.apple.com/us/app/attentionly-adhd-time-audit/id6761147386) | Free, no paywall | Random notification nudges, freeform answer, no fixed categories | No — explicitly markets "no AI coaching" |
| [RescueTime](https://www.capterra.com/p/103317/RescueTime/reviews/Capterra___3373464/) | Subscription, \~$6.50–$12/month | Automatic background tracking of apps and websites | Categorization and productivity scoring, not personalized recommendations |
| [Toggl Track](https://www.capterra.com/p/247745/Toggl/) | Subscription, \~$9–$18/user/month | Manual timer start/stop, billable-hours focus | No |

As of September 2026: the direct competitors (TimeAudit™, ThenAudit, Attentionly) confirm demand for exactly this capture mechanic, and TimeAudit™'s pricing plus ThenAudit's lifetime IAP tier both show a one-time-purchase price point already works in this niche. The gap is the AI layer — turning captured blocks into specific, personalized efficiency recommendations rather than just charts or a single summary metric. The broader automatic-tracking tools (RescueTime, Toggl Track, Timeular) serve a different job — continuous background monitoring or freelancer billing — and compete less directly.

## Technical Approach

- **Platform & stack**: iOS, built in SwiftUI with a Supabase backend, consistent with the developer's other apps
- **Team**: solo build
- **Speech-to-text**: on-device, via Apple's Speech framework — no cloud dependency or per-use cost
- **AI analysis engine**: not yet selected; the choice needs to balance cost against accuracy for categorization and recommendation quality (see Risks & Open Questions)

## Design & Visual Identity

Minimal, iOS-native direction: mostly system components (SF Symbols, native grouped lists, Swift Charts for the report screen), full Dynamic Type support, and no heavy custom chrome. A single accent color — deep indigo (#3D3B8E) — carries key actions and data highlights; everything else stays close to the platform default. Standalone visual identity, intentionally unconnected to the developer's other apps.

## Monetization & Business Model

One-time purchase for app access (price TBD), which includes the initial audit. Additional audits beyond what's included are purchased as credits, so ongoing AI-processing cost per audit is covered by revenue rather than absorbed indefinitely on a single lifetime fee.

## Risks & Open Questions

- **AI model selection**: not yet chosen; needs to balance cost per audit against categorization and recommendation accuracy
- **Pricing**: the one-time purchase price and the additional-audit credit pricing/bundle size aren't set yet
- **Missed check-ins**: no decision yet on what happens when a user ignores an hourly prompt entirely — a catch-up/backfill flow, or does that block simply count as unaccounted time?
- **Default category set**: the specific categories provided at account creation haven't been defined yet

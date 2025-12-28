# VBStats App Plan

## Goals
- Team-level, coach-entered rally outcomes; no player rosters.
- Tablet-first (works on phone), offline-first, quick logging during live sets.
- Open-ended sets; per-set starting rotation and serve/receive captured.
- Clear, rotation-aware scoring stats, sideout/point-scoring %, ratios, and momentum visualization.
- Easy review of past matches and per-set summaries; per-match JSON export/import.

## Scope (MVP)
- Match list with summaries; create new match (opponent, event/date optional) and add sets on demand.
- Live set logging: single-outcome per rally, rotation and serve/receive aware, auto score updates, undo/redo, edit rally.
- Stats: per set and match totals; rotation splits; sideout % and point-scoring % per rotation; ace:service-error and ace:receive-error ratios.
- Momentum step chart per set with run highlighting (3+ in same direction), labeled by rally reason.
- Set and match review screens; JSON export per match; JSON import to restore matches.

## Data Model (SQLite via Drift/Sqflite)
- Match: id, opponentName, eventName?, date, createdAt.
- Set: id, matchId, setIndex, startRotation (1-6), startServeReceive (serve/receive), ourScore, oppScore, createdAt.
- Rally: id, setId, rallyIndex, rotationAtStart (1-6), weWereServing (bool), outcome (enum), winner (us/them), timestamp.
  - Outcome enum (won): Ace, Kill, Block, Opponent Error/Fault.
  - Outcome enum (lost): Serve Error, Receive Error, Block Error (tooled), Dig Error, Cover Error, Rule Violation, Free Ball Error, Attack Error.
- Derived views: rotationStats per set; momentum series per set (rally order with cumulative score diff).

## Derived Metrics
- Sideout % (per set + per rotation): rallies starting in receive that we win / total rallies starting in receive.
- Point-scoring % (per set + per rotation): rallies starting in serve that we win / total rallies starting in serve.
- Totals: Aces, Kills, Blocks, Opponent Errors/Faults (points for us) and each loss reason.
- Ratios: Ace:Service Error, Ace:Receive Error (show "—" if divisor is 0).
- Runs: sequences of 3+ points in one direction for momentum highlighting.

## Logging Rules (assumptions to confirm)
- When we win while receiving: we sideout, switch to serving, and rotate (advance 1→6, wrap).
- When we win while serving: stay serving, no rotation.
- When we lose while serving: switch to receive, no rotation. (Confirm.)
- When we lose while receiving: opponent keeps serve; we stay receiving and rotate? (Typical is no rotation on loss in receive; confirm.)
- Undo/redo available; editing a rally recomputes downstream scores/metrics.

## UX Flow
- Home: list matches with per-set scores; CTA to create match; import JSON.
- New match: opponent, event/date optional; create first set; add more sets anytime.
- Start set: choose startRotation (1-6) and startServeReceive (serve/receive).
- Live set screen (tablet two-pane):
  - Left: score, serve/receive indicator, rotation indicator, quick outcome buttons (won/lost reasons), undo/redo.
  - Right: live stats (totals + rotation splits), ratios, sideout/point-scoring %, momentum step chart with labeled reasons and run highlights.
- Set summary: totals, rotation splits, ratios, momentum chart with runs.
- Match summary: aggregate stats across sets, list of sets, export JSON.

## Momentum Chart
- Step chart over rally index; up step = our point, down step = opponent point.
- Label boxes with short codes: Ace, Kill, Block, OE, SE, RE, BE, DE, CE, RV, FBE, AE.
- Highlight runs of 3+ in same direction (color band or thicker line).

## Offline & Export
- Local storage in SQLite; all flows work offline.
- Export per match to JSON (metadata, sets, rallies, derived totals optional); import to restore matches.

## Undo/Edit
- Undo/redo stack for recent actions.
- Edit dialog for a rally: change outcome/winner; recompute scores and metrics forward.

## Backlog (phased)
- MVP Build: data layer (SQLite schema, DAOs), domain models, momentum/run computation, set scoring/rotation logic, live logging UI, summary views, JSON export/import, undo/redo.
- Polish: tablet layout refinements, accessibility, haptics, quick filters, ratio edge cases (division by zero display), empty states.
- Later: phone-optimized layout, theming, cloud sync/backup, PDF/CSV exports, season/tournament grouping, multi-match dashboards.

## Decisions (confirmed)
- Rotation on losing while receiving: stay receiving, no rotation.
- Rotation on losing while serving: switch to receive, no rotation.
- Chart labels: short codes Ace, Kill, Block, OE, SE, RE, BE, DE, CE, RV, FBE, AE.
- Set labels: 1, 2, 3... in creation order.
- Layout: two-pane (controls left, stats/chart right) for tablet; collapse to single column on phone.

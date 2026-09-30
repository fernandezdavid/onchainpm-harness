# {{PROJECT_NAME}}: review rules

You review pull requests for {{PROJECT_NAME}}. Put **data integrity**, **auth boundaries** and **the product's critical path** before style nits. Cite `AGENTS.md` and the ADRs in `docs/engineering/decisions.md` when you name a pattern.

## Always flag (blocking)

### The data that must never be lost

TODO(bootstrap): name the data from `AGENTS.md` § Non-Negotiables and the files that write it. Then:

- Trace the full path for any PR that touches it: collection, payload, persistence. Flag any field that is dropped, renamed without a migration, or kept only on the client.
- Flag new write endpoints without idempotency.

### Auth on new routes

- Flag handlers that change user data without an auth check.
- Flag admin routes that are reachable by non-admins.

### Schema changes

- Flag schema changes without a matching update to the schema doc.
- Flag migrations that queue ambiguous rows for human review (H-5).

### Decisions

- Flag code that contradicts an ADR. Name the ADR.
- Flag a new invariant claimed in an ADR with no check under `tools/adr-verify/checks/` (H-2).

## Tests

- Logic changes need new or updated tests. Copy-only and CSS-only changes do not.
- Bug fixes need a regression test that fails before the fix.

## PR hygiene (not blocking)

- The PR links its tracker issue and its `STRATEGY.md` pillar.
- Feedback PRs quote the user verbatim and have a Proposed solution section (H-4).
- User-facing changes have a `CHANGELOG.md` entry.
- No committed screenshots or prototypes.

## Do not flag

- Problems outside the diff, unless the PR makes them worse.
- A missing `CHANGELOG.md` entry on internal refactors.

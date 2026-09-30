# Feedback triage routine

Pull new user feedback, remove duplicates against the tracker, and file everything real as an issue in Triage. Propose. Never implement features.

**Schedule**: daily.

Read first: `STRATEGY.md` (pillars and "Not building"), `AGENTS.md` § Product Rules, and the voice doc named in `docs/design/README.md`.

## Step 1: Pull feedback

Read the feedback source named in `WAYS_OF_WORKING.md` for the last 24 hours. Use read-only credentials. If the source errors, report the error and stop. If there is no new feedback, report "no new feedback" and stop.

## Step 2: Filter

Skip test, empty and gibberish submissions without comment.

## Step 3: Remove duplicates before you create anything

Search the tracker's open issues and recently closed ones.

- A near-duplicate exists: do not create an issue. Add a comment to the existing issue with the new quote, user and date, so the signal builds up on one item.
- Related but different: create the issue and link the related one.

## Step 4: Classify and file

Look past the literal request to the job the user is trying to do. Then classify:

- **Noise**: skip, and list it in the report with a one-line reason.
- **Bug**: title as a short imperative. Body: reproduction, observed against expected, affected users, a suggested approach.
- **Feature or improvement**: check it against `STRATEGY.md`. Off-strategy items are still filed, marked "off-strategy" with a one-line reason.

Create every issue in the **Triage** state (set it explicitly; tracker APIs often default to Backlog). Add the `user feedback` label. Use this body:

```
**Quote**
> <verbatim feedback>
> <user id> · <date> · <screen or context>

**Job to be done**
<what the user needs>

**Strategy fit**
<pillar, or "off-strategy: <reason>">

**Possible directions**
- <option 1>
- <option 2>

**Related**
<links>
```

No scope and no acceptance criteria. The owner sets those at promotion. UI proposals say "prototype first".

## Step 5: Report

- Feedback items pulled
- Items skipped as noise or duplicates
- Issues created, with links
- Comments added to existing issues

## Constraints

- Never write to the feedback source or the database.
- Never create an issue without the duplicate search.
- Never file outside the tracker project named in `AGENTS.md`.
- If the feedback is ambiguous, file it and name the ambiguity. Do not invent scope.

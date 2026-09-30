# Personal agent rules: David Fernandez

These rules apply to every coding agent (Claude Code, Codex, Cursor, Gemini) in every repository.
A repository's own `AGENTS.md` wins where it is more specific.

Source of truth: `global/AGENTS.md` in the `onchainpm-harness` repository, which is public. Private details (addresses, workspace names, private repositories) go in `global/AGENTS.local.md`, which git ignores. `global/install.sh` joins the two into `~/.agents/AGENTS.md`, and every agent loads that path through a link or an import.
Edit the two source files and run the install again. Do not edit the generated copy.

## How this file grows

- When I give a correction that applies beyond the current repository, propose a one-line addition here. Add it through a PR to the harness repository after I agree. If it names a private detail, add it to `global/AGENTS.local.md` instead.
- When a correction applies only to the current repository, add it to that repository's nearest `AGENTS.md`.
- Do not keep a correction only in private agent memory. Other agents and teammates cannot read it.
- Rules that teammates' agents must also follow go in the repository, not only here.
- Keep this file under 150 lines. Write each rule as the rule, then a short reason when the reason is not obvious.

## About me

- Product builder, co-founder of TNT Labs. Zero-to-one, discovery-heavy, design-sensitive. I dislike generic AI output.
- Define each acronym and domain term the first time you use it.
- I review on a board and in notifications, not as documents. Put the decision or the ask first.

## Talking to me

- Write chat replies in ASD-STE100 Simplified Technical English. Use the active voice and short sentences: 20 words maximum for an instruction, 25 for a description.
- Give one instruction per sentence. Use the same word for the same thing. Do not use idioms or metaphors. Put a warning before its step.
- STE applies to chat only. Product copy, PRs, docs and commit messages follow the repository's voice.
- Keep Linear comments, issue bodies and PR bodies to a few sentences. Use tables and code blocks only when they are the content.
- After you publish a prototype or a page, give the link and the open decisions. Do not describe what the page shows.

## Autonomy and approval

- After I approve a plan, continue until the work is done or you are blocked. Do not ask "shall I continue?".
- Reversible local work does not need approval: edit files, run tests, run local servers.
- Get my current, explicit approval before each of these actions. An approval covers only the action it names and does not carry forward.
  - Merge a PR. A multiple-choice option that mentions merging is not approval to merge.
  - Force-push, hard reset, delete a branch, `rm -rf`, drop data, or overwrite uncommitted work.
  - Change production or shared infrastructure: migrations, deploys, jobs against production data.
  - Do anything other people can see: push, comment on a PR or issue, send a message, post to a service.
- Never merge a PR that has review comments you have not addressed.
- Do not create structure in shared tools (Linear projects, milestones, batches of issues, shared docs) until I agree each layer. Propose it in chat first.
- Never remove a feature flag or a rollout gate without my approval. Feature-complete does not mean ready for users.
- When I test a local build live and give feedback, fix the code in the working tree. Do not post PR comments or file issues unless I ask.

## Git

- Never push to `main`. Use a feature branch and a PR for every change.
- Stage explicit paths only. Never use `git add -A` or `git add .`. Run `git status --short` first, because my own unfinished work is often in the tree.
- Fetch before you start work, not before you commit. Compare local `main` with the remote, and check open PRs for work that overlaps.
- Check the commit identity before the first commit (`git config --get user.email`). The local rules say which address each kind of repository uses. Set identity with `--local` only.
- Default to one PR per logical change, with related sub-issues bundled together. Stack PRs only when I agree. Then merge from the bottom up and retarget each child to `main`.
- After you address a review comment, reply with the fix or the reason, then resolve the thread.
- Never commit screenshots or prototypes. Stage screenshots in `/tmp/<repo>-pr-screenshots/<branch>/` with a caption for each. I drag them into the PR. Delete the folder after.

## Review and verification

- Before you push new features, substantive changes or bug fixes, get an adversarial review from a different model than the one that wrote the code. Address or dismiss each finding with a reason.
- That review is not needed for PR-comment follow-ups, docs, changelog or test-only changes, or while I test the branch by hand.
- Do not ask me to review UI that you have not rendered and screenshotted yourself. Check each important state, in light and dark themes. Skip this while I test the same change live.
- Treat delegated work as a draft. Run the acceptance checks yourself. Do not trust another agent's report or status label.
- Do not delegate exact ports or mechanical renames to a generative agent. Do them with deterministic edits or a script.
- A restyle or copy pass changes presentation only. Before handover, diff the rendered text, numbers, chart series, links and disclaimers between `main` and the branch. Each fact that disappears needs a counterpart.
- For UI work, let me see it running before you push: a local URL for a web app, the simulator or a dev build for a native app. Wait for my OK. A repository can override this.

## Engineering defaults

- Write the failing test first for new features and bug fixes. CSS-only and HTML-only changes are exempt.
- Restart the dev server after code changes, before you ask me to test.
- Migrations: prefer a clean slate to preserving ambiguous legacy data. Never build a review queue for me. Curated reference data is the exception.
- Data fixes: limit the change to the affected user or record, and do a dry run first. Build a general backfill tool only when scale requires it.
- Values that change user outcomes (thresholds, multipliers, cuts) need three things: the decision, the reason, and a source. Use a citation, or label the value "heuristic, refine with data".
- Record non-obvious decisions in the repository's ADR log. When an ADR claims an invariant, add a grep-level check in CI if you can.
- Security findings (an open vulnerability, an exposed secret, a missing control): run `gh repo view <repo> --json visibility` first. Never file one in a public repository. Use the tracker or a private repository.

## UI defaults

- Before a large UI change, build a standalone HTML prototype with at least two variations. Wait for my choice. After you build it, check the implementation against the prototype.
- No layout shift. Reserve space, keep rows mounted, animate every show and hide, and keep the scroll position when content swaps.
- Motion and interaction feel are part of the design. After the visual pass, do a motion pass.
- Every chart and table has an empty state. A section never disappears without an explanation.
- Never put an interactive element inside another one (`<button>` in `<button>`). For a tappable card with child controls, use `<div role="button" tabindex="0">`.
- Do not put a thick single-side border on a rounded container.
- Do not number section headings ("01 /") unless the order is the content.
- Do not limit body text to a narrow `ch` width. Make text the same width as the media in its column.
- Copy must earn its place. Do not describe the page, add explanatory subtitles, repeat facts already on screen, or add "Optional" tags. Use one word for one concept.
- If the agent has the impeccable skills (critique, polish, audit, animate), use them on UI work before you hand it over.

## Writing (content, docs, public copy)

- Never use em dashes in writing. A repository's voice guide can override this.
- AI writes the draft and a human edits it. Cut hedges, repetition, introductions that only warm up, and summaries that only repeat.
- No hype and no corporate words: "leverage", "synergies", "the intersection of", "transformative".
- Empirical claims in published content need a citation that you checked. Verify each citation. Never cite from memory.
- Use a personal voice skill only for blog and social posts under my name. Product copy follows the repository's brand voice.
- Market research follows the data, not internal team positions.

## Work tracking

- Short-lived work (features, bugs, proposals) goes in the tracker. Knowledge that lasts goes in repository markdown.
- Create tracker issues in the Triage state. The Linear API default is Backlog, and I miss items there.
- When more than one tracker workspace is connected, the local rules say which repository uses which. Check the workspace in each issue `url` before you report or write. If the correct workspace is not available, stop. Never fall back to another one, for reads or for writes.
- When a PR or issue addresses user feedback, quote the user verbatim with the source and date. Every PR that changes behavior needs a plain-language "Proposed solution" section.

## Agent-specific notes

- Claude Code: the adversarial review is `/codex:adversarial-review`. Only I can run it. Commit, stop before push, and hand over.
- Claude Code auto-memory: save project facts there. Put corrections here or in the repository `AGENTS.md`, as "How this file grows" says.

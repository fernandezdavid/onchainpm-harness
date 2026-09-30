# {{PROJECT_NAME}} design canon

This is the design home. It owns the **decisions**: who we design for, what the product may feel like, and the laws that stop the same argument from happening twice.

**Two things bind here.** A law is not advice. If a surface needs to break one, that is a design decision: raise it, record it, and do not quietly build around it. And every law carries **its own check**, because rules that nobody verifies do not hold.

The laws below are defaults from earlier products. Each one names the incident that earned it. In the bootstrap session, keep, change or delete each law. A law you keep needs a check that this project can run.

---

## Start here

| Read | For | Owns |
|---|---|---|
| **This doc** | Any UI or interaction work | The laws, the registers, the checks |
| TODO(bootstrap): design system doc | How it looks | Palette, type, geometry, tokens |
| TODO(bootstrap): voice doc | How it sounds | Voice, tone, words we use and avoid |
| TODO(bootstrap): design skill context (for example `.impeccable.md`), or "none" | Design skills: critique, polish, audit | Nothing. It is derived from this doc and the two above |

Those docs hold the detail. This doc holds the decision. Where they disagree with this one, this one is right and they are stale. Fix them.

---

## Who this is for

TODO(bootstrap): the user, where they are, what their hands and attention are doing, and what they already know. Then two lines: what that lets us do, and what it costs us.

---

## The four registers

Most copy and layout mistakes are a register error: one kind of statement dressed as another. There are four. They never borrow each other's words or components.

| Register | Says | Wears |
|---|---|---|
| **Choice** | what the user can set, and what it changes | the control itself |
| **Read** | what the system says the state is | a value cell, in the value type |
| **Annotation** | what a choice or read means | a callout |
| **Action** | what happens next | the primary button |

The failures look like this. A choice that states the current state can be contradicted by the read that follows it. A read computed on the client is a guess that looks like the system's answer. An annotation set as plain grey text gets skipped. An action whose label changes during a fetch promised something the system did not know yet.

---

## The laws

Each law states the rule, **how it is checked**, and how it was learned. The last part is the receipt. It is here so that nobody has to learn it again.

### L1 · Nothing moves that the user did not move

Answering, selecting, resolving, failing and retrying all leave the layout where it was. The only motion is motion the user asked for.

- **Check:** in a browser or component harness, assert that the primary action's position is the same in every state the surface can enter.
- **How it was learned:** a conditional dot inside a wrapping row added 14pt and rewrapped four chips under a reaching finger. Both versions looked fine in a screenshot.

### L2 · Every state change is animated, and only a measurement proves it

An instant show or hide is a bug. So is an animation you believe in but have not watched.

- **Check:** record the screen and measure one edge frame by frame. A real transition shows 10 or more distinct positions on an ease curve. A cut shows one step. Screenshots cannot tell these apart.
- **How it was learned:** an accordion shipped twice with no animation on device. The code looked animated, the checklist box was ticked, and the one harness we ran could not catch it.

### L3 · Answering never removes the control that answered

A control that folds itself away after a selection charges the user a full reopen to change their mind. A section closes when its own header closes it, and at no other time.

- **Check:** commit a value, then assert that the control is still present and accepts a second, different value with no navigation between.
- **How it was learned:** a form advanced itself after each answer. Picking one value and wanting the next one cost a fold, a reopen and a second tap.

### L4 · One surface, one polarity

Every scale on a surface runs the same direction: benign on the left, severe on the right.

- **Check:** read the first label of every scale on the surface. If one starts benign and another starts bad, it fails.
- **How it was learned:** one scale ran bad-to-good while the meter beside it filled mild-to-severe.

### L5 · A mark means one thing

A dot, a fill or a tint is the state of a settled answer. It is never decoration, never a colour key for a scale the words already state, and never repeated for the same fact twice on one screen.

- **Check:** count the marks on screen and name what each one means. Two marks for one meaning fails. One mark for two meanings is worse.
- **How it was learned:** five identical dots in one column stood for three different things.

### L6 · One concept, one phrasing

A concept gets one string, product-wide. No synonyms and no "reads better here" variants.

- **Check:** grep the candidate phrasings across the source. More than one phrasing for one concept is the bug. Keep shared labels in one file.
- **How it was learned:** one concept carried seven phrasings across one flow, and each review found a different pair.

### L7 · Reserve the slot before you need it

Anything conditional (a mark, an annotation, an error, an override) reserves its space from the first paint. When hidden it has no paint, no focus target and no accessibility entry, but it keeps its space.

- **Check:** measure the surface with the element absent and present. The difference is zero, or it is a bug.
- **How it was learned:** a label widened a chip and rewrapped four others. An error block took a different space than the value it replaced.

### L8 · The read belongs to the system; the choice belongs to the user

Nothing on a surface computes a result the server owns. A preview that returns deltas shows deltas. It never invents a total, and it never shows an old selection as a placeholder while a new one loads.

- **Check:** trace every displayed figure to its source. Client arithmetic that duplicates server logic is the bug.
- **How it was learned:** a surface showed a computed total that the server never returned. It was wrong whenever the server's rules changed.

### L9 · Quiet comes from size and placement, never from low contrast

Text that must be read is read at full contrast. Restraint means small, short and out of the way, not grey.

- **Check:** contrast-check every string against its real background in both themes. Body and label text meets WCAG AA.
- **How it was learned:** one annotation measured 1.07:1. It was invisible, not quiet. A grey sub-line went unseen until it became a pill beside the name.

### L10 · The accent is spent once

One accent colour, on one kind of thing per view worth noticing. Never on create/edit/delete controls, status chrome, progress or selected states.

- **Check:** count the kinds of thing in the accent per view. More than one kind fails, unless the extra kinds are reserved kinds listed here. A repeated mark in one column counts as one.
- **How it was learned:** a screen spent the accent on everything until nothing on it stood out.

### L11 · Type carries the register

Two registers never wear the same type treatment. One register wears one treatment across the surface. A label steps down clearly from its value.

- **Check:** dump the computed font size, weight and colour for one element per register. Same-register elements match, cross-register elements differ, and each label is smaller or lighter than its value.
- **How it was learned:** the user's answer and the system's read were byte-for-byte the same style, separated by nothing but a border.

### L12 · Copy earns its place

Every string tells the user something the title, the control or the moment does not already say. The product does not describe itself: no eyebrow that repeats the title, no subtitle that explains what the user just tapped, no `Optional` tag, no fact that is already on screen. When information matters, fold it into a string that exists, usually the title.

- **Check:** list every string the surface renders and strike each one in turn. If the user loses nothing, it goes. Grep for `Optional`; it never ships as a label.
- **How it was learned:** a picker stacked four strings above its search field. One carried information. It now lives in the title.

### L13 · A number states its basis

A change is written in the unit of the value it changes. A change in a percentage is written in percentage points (`-2 pp`), not as a relative percent. State the basis once, as a label.

- **Check:** for each delta on screen, compute it from the two values it compares. If the printed figure reads as a different change, it fails.
- **How it was learned:** a 5% to 3% change printed as `-2.00%` read as a 2% cut. It was a 40% cut.

---

## How a law gets checked

Three probes, in order of cost. A UI change leaves behind the probes that apply, so the next change cannot undo it without a failure.

| Probe | Catches | Cost |
|---|---|---|
| **Unit** | copy contracts, state machines, ordering | free |
| **Browser or component harness** | layout shift, touch targets, reachability, accessibility roles, both themes, narrow widths | minutes |
| **Device recording** | whether motion happens, and its curve | about 2 minutes, manual |

Know which probe can see which failure. A browser harness is right for layout and semantics and wrong for native motion, haptics, dynamic type and safe areas.

---

## When a law is wrong

Laws get things wrong. If a law blocks the right design, or prescribes a tool that no longer fits, say so, change the law, and record what it cost. Do not build around it in silence. Do not leave a stale law next to a working exception; that is how people learn to ignore this document.

---

## Changing this document

- A new law needs a **receipt**: the incident that earned it and the check that catches it. A law with no check is a preference.
- Decisions live here. Implementation detail goes to the engineering docs, and they link to this one instead of restating it.
- If a design tool keeps derived context (for example `.impeccable.md`), update it in the same commit as this document.

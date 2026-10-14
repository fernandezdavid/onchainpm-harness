# Evals for LLM features

An eval runs one fixed set of inputs through two or more versions of a feature that calls a large language model (LLM), and compares the results. It turns "the new model feels faster" into numbers that a decision record can cite.

## When to run one

Run an eval when a change alters what the model receives or how it answers:

- a new model, or a new version of the same model
- a prompt change
- a new output format (for example, minified JSON, a different key order, fewer fields)
- new thinking, effort or sampling settings
- a new retry, repair or fallback path

Do not run one for UI copy around the feature, or for code that does not change the request.

## Structure

One script, for example `scripts/eval-<feature>.mjs`, with these parts:

1. **Fixtures.** 8 to 12 inputs in `tests/fixtures/<feature>-eval/`. Cover the common case, each input that broke in the past, and the largest input you support. Use synthetic data only. Never copy a real user's data into a fixture.
2. **Variants.** Named configurations. The first is the baseline: the request that production sends today. Each candidate changes one thing where possible, so you know which change caused the result.
3. **Call path.** The eval calls the same function that production calls. An eval that builds its own request measures a different feature.
4. **Metrics per call.** Total time, time to the first useful output, input tokens, output tokens, cache tokens, cost, the validation result (pass, repaired, failed) and the number of retries.
5. **Report.** A table per variant: p50 and p90 (the median and the 90th percentile), maximum, cost per call and failures. Also an HTML page that shows the outputs side by side for human review. Attach it to the PR. Do not commit it.
6. **Spend guard.** Without `--yes-spend`, the script prints the estimated cost and stops. Flags such as `--fixtures` and `--variants` run a subset.

The script reads the API key from the environment and never prints it. Use a key with a spend limit.

## Estimate the cost before you run

```
calls        = fixtures x variants x repeats
cost per call = input tokens x input price
              + output tokens x output price
              + cache writes and reads at their own prices
estimate     = calls x cost per call x 2
```

The factor 2 covers retries and repair calls.

- Take token counts from production logs or from the preflight call. Do not guess them.
- Take prices from the provider's pricing page on the day of the run. Prices change and differ per model. Never use prices from memory.
- Show the estimate to the person who owns the budget, and wait for approval. After the run, report the actual spend next to the estimate.

For scale: ten fixtures, five variants and about 12,000 output tokens per call cost less than $5 in total.

## Preflight

Before the full run, send one call per variant with the smallest fixture. The preflight finds these failures for the cost of one call each:

- a key with no credit
- a model or mode that the account cannot use (for example, a rate limit of zero)
- a request shape that the API rejects
- a fixture that refers to data the feature does not have

Each of these has failed a full run before.

## Compare fairly

- Run every variant on the same fixtures, with the same concurrency. Interleave the variants, because API latency changes during the day.
- Measure what the user feels: the total time, and the time until the first output that the user can see.
- Check content parity, not only validity. A variant can be faster because it writes less. Compare the structure (counts of items, sections, list lengths) and the length of free-text fields. Report the difference as a number, for example "notes 35 to 50 percent shorter".
- A call that fails validation counts as a failure. Do not remove it from the percentiles.
- When results vary a lot, repeat the fixtures. Report p90 and the maximum, not only the average.

## Review quality

- A person reads the side-by-side report for at least three fixtures, including the hardest one, before the decision. The quality verdict is theirs.
- An LLM judge (a model that grades outputs against a rubric) is useful when the eval runs often. Calibrate it against human verdicts before you trust it.

## Keep a rollback

- Put the old behavior behind one switch, such as an environment variable. Add a snapshot test: with the switch on the old value, the request is the same, byte for byte, as before the change.
- When a setting works only on some models, make it a no-op on the others, and test that.

## Record the decision

- Write an ADR in `docs/engineering/decisions.md`: the variants, the numbers, the cost of the eval, the quality trade-off, the decision and the rollback switch.
- Put the full result table in the feature's spec, and link the report from the PR.
- Keep the script and the fixtures in the repository. The next model change runs the same eval.

## Before you run

- [ ] The fixtures are synthetic and include the inputs that broke before.
- [ ] The baseline variant sends the request that production sends today.
- [ ] The preflight passed for every variant.
- [ ] The budget owner approved the estimate.
- [ ] The report will show speed, cost, failures and content parity together.

---
name: root-cause
description: Investigate a service incident / 5xx surge / latency or DB-saturation problem and produce an evidence-backed root cause. Use when asked to find the root cause of an incident, re-check an RCA, explain why a service failed, or investigate errors/timeouts/outages. Enforces falsify-first discipline and confidence-rated cause→effect.
allowed-tools: Read, Bash, Grep, Glob, Write, Edit
---

# Root-Cause Investigation

Find the *real* root cause of an incident and state it with calibrated confidence — without the back-and-forth of confidently asserting wrong theories. This skill encodes the discipline from the INC2290111 investigation.

## Read this first

The general rules are in `~/.claude/CLAUDE.md` ("prove before writing"). This skill is the operational checklist.

## The one rule

**Do not write a root cause as fact until you've reproduced it or proven it from evidence.** State hypotheses as hypotheses. For each claim, run the **cheapest query that would FALSIFY it** before writing it down. Every confident-but-unproven claim costs a correction.

## Procedure (do this from the start)

1. **Separate noise from incident** — plot the metric over a wide window; investigate the bucket where it *breaks*, not the average.
2. **Raw logs, not `stats`/`table`** — structured views drop fields; read `_raw` for the real error string + flow fields.
3. **Rates, not counts** — `failures ÷ total` per dimension (method, pod, endpoint). Counts without denominators cause base-rate-fallacy conclusions.
4. **Falsifier first** — for each hypothesis, the cheapest test that would *kill* it, not confirm it.
5. **Count ≠ concurrency ≠ rate** — for "resource exhausted," derive in-flight concurrency (Σ overlap of each op's `[end−duration, end]`), not volume.
6. **Know what each latency metric's clock wraps** — app-side vs server-side; which pool/tier. Prefer the server-side (DB-log) duration.
7. **Quantify the control** — a peer service/store is only a control once you've shown it received *comparable* load. Drop it otherwise.
8. **Trace one failing request end-to-end** by correlation id to locate the stall step.
9. **Mechanism from code + schema + library source** — decompile/unzip the exact dependency version; don't reason from memory. `git log -S` / `blame` to classify intent (careless vs deliberate).
10. **Separate trigger vs amplifier vs mechanism** — name which one each claim is about.
11. **Prod is observe-only** — never flip a level/config/redeploy to investigate. Frame the fix as a falsifiable **RED→GREEN** test for preprod.

## Recurring traps (the corrections that cost rounds)

- **Base-rate fallacy** — biggest count ≠ most-impacted; use rates.
- **App latency ≠ DB latency** — know what the timer measures.
- **"True of all DBs/services" can't explain "only one died"** — find the differentiator.
- **Uncontrolled control** — quantify comparable load before comparing.
- **One sampled error ≠ the population** — check the error mix.
- **Verify topic/config wiring** before asserting a loop or data flow.
- **Recurrence test** — a routine, usually-harmless activity isn't the cause.

## Write-up

Produce a doc that:
- Tags every causal link **PROVEN / STRONG-INFERENCE / DISPROVEN** — only proven claims read as fact; name the one inference to confirm in preprod.
- Keeps a short **"hypotheses tested and falsified"** list so the next person doesn't relitigate dead ends.
- Says so explicitly when it **corrects an earlier claim**.
- States the fix as a **RED→GREEN** hypothesis (what fails today, what makes it pass).

Save investigation/RCA docs in a separate analysis repo, not in the service repo's `docs/`.

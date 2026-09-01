---
name: code-smell
description: Capture a code smell into the user's code-smell learning series in the matching analysis repo. Use when the user says "is this a code smell", "this smells like X", "document this smell", "add to code smell series", or invokes /code-smell. Follows the established 7-section template, finds the next NN, updates the series index, and grounds every claim in real code with file:line refs.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Code Smell Series — Capture Workflow

The user maintains a long-running code-smell learning series in their analysis repos. Each entry teaches one named smell using a real example from a working codebase, cited against canon. This skill enforces the conventions so entries stay consistent and the series compounds in value.

## The canon (cite these by name)

When citing rules in entries, draw from these four works. The `code-smell-canon-cheatsheet.md` in each analysis folder lists the specific items/chapters to reach for. The user works primarily on Java/JVM code, so all four sources are directly applicable.

1. **A Philosophy of Software Design**, Ousterhout (2nd ed.) — complexity, deep vs shallow modules, information hiding, precise naming, strategic vs tactical programming. The strongest single source for *interface design* and *cognitive load* arguments. **Reach for this first when the smell is about how an abstraction is shaped.**
2. **Refactoring**, Fowler (2nd ed.) — named smells (Data Clumps, Feature Envy, Primitive Obsession, Shotgun Surgery, etc.) and their canonical mechanical fixes. **Reach for this when the smell has a well-known name and a textbook refactor.**
3. **Effective Java**, Bloch (3rd ed.) — API design, overloading, parameter signatures, nullability. Use when the smell is at the *method signature* level.
4. **Clean Code**, Martin — naming, function shape, exception handling, the smells/heuristics chapter. Still a useful framing source, especially for naming and "tell, don't ask" style points.

### Citing Clean Code: a caution

Clean Code is fine to cite by **principle name** (e.g. "Tell, Don't Ask," "Avoid Disinformation," "Don't suppress exceptions"). What is **not** fine is citing numbered heuristics from memory:

- The 1st edition (2008) has a Chapter 17 "Smells and Heuristics" list numbered G1–G36. The 2nd edition (2025) reorganized the book and that exact numbered list is gone.
- Citations like "Clean Code ch. 17 G19" or "G23" therefore don't reliably resolve across editions, and a reader checking against a 2nd-edition copy will not find them. (This bit us in entry 05, where a fabricated G-number got through.)

**Rule for this series:** when citing Clean Code, cite the **named principle and the chapter topic** ("Clean Code — Tell, Don't Ask," "Clean Code — Don't suppress exceptions"). Do **not** invent or copy G-numbers from memory. If a specific G-number is genuinely needed and the user is reading the 1st edition, it's fine — but confirm it from an actual copy, not from training-data recall.

Entries should cite **≤ 3 canon rules total** (across the four works). Reach for Ousterhout first when the smell is fundamentally about **interface depth, information leakage, or cognitive load** — the others often miss those framings.

## When to invoke

Fire on:
- `/code-smell` (with or without args)
- "is this a code smell" / "is this a smell or fine"
- "this smells like …" / "smells of …"
- "add to (the) code smell series" / "document this smell"
- "another code smell" (continuing a discussion)

Do **not** fire on:
- General code review without explicit smell-naming intent
- "This code is bad" without a request to document it

## Repo → analysis folder map

This is the source of truth. To support a new repo, edit this table.

| Source repo (basename of cwd) | Analysis folder |
|---|---|
| _(none yet — add a row per repo you analyse)_ | |

If the current repo isn't mapped, **stop and ask the user** which analysis folder to use, then offer to add a row to this table.

## Workflow

### Step 1 — Confirm scope

If the user hasn't pointed at a specific code location, ask which file/method exemplifies the smell. Don't invent examples; the series's value comes from real code.

### Step 2 — Verify the claim

Before writing, **read the cited file(s) and confirm the smell exists as described.** If the user calls something a smell that on inspection is fine (or has a non-obvious justification), say so before proceeding. The series should not contain incorrect smell calls.

For "Data Clumps," "Feature Envy," "Repetition" smells: grep all callers and *count* them. The strength of an entry is the concrete count ("19 of 19 call sites do X"), not vibes.

### Step 3 — Locate the analysis folder

1. Determine current repo: `git rev-parse --show-toplevel` then take `basename`.
2. Look up in the table above. If missing, ask.
3. The series lives directly in that folder (no subfolder), prefixed `code-smell-`.

### Step 4 — Find the next NN

```bash
ls <analysis_folder>/code-smell-[0-9][0-9]-*.md 2>/dev/null | tail -1
```

Take the highest NN, increment, zero-pad to 2 digits. If no entries exist, start at `01`. NN `00` is reserved for the index.

### Step 5 — Choose a kebab topic slug

3–5 words, hyphen-separated, naming the smell — not the example. Good: `nullable-parameter-overuse`, `sentinel-empty-string`. Bad: `feature-flag-util-issue`, `bad-method`.

### Step 6 — Write the entry

Use this template exactly. Every section is required; if a section is genuinely N/A, write one sentence explaining why rather than deleting it.

```markdown
# NN — Title Case Smell Name

> *Smell names:* <comma-separated canonical names>
> *Canon:* <≤3 cited rules, e.g. "Effective Java Item 51 · Fowler — Data Clumps">

## The code

`<relative/path/from/repo/root.kt:LINE>`

```<lang>
<verbatim snippet, kept short — link don't dump>
```

## What looks fine at first glance

<2–4 bullet points capturing the rationalizations that let this smell survive code review. Steelman the existing code.>

## The smell

<Name it using canon vocabulary. If multiple smells stack, list each with a one-sentence definition.>

## Why it actually hurts

<Concrete failure modes — bugs, confusion, test rot, refactor traps. Cite call-site counts, real examples. No abstract worry; only specific consequences.>

## Canon rules violated

<Bullet list, each rule cited as "**Source — Item/Chapter — Rule.** Application.">

## Refactor

### Minimum viable
<Smallest change that removes the smell. Show code.>

### Thorough
<The "right" refactor if you had time. Show code or sketch.>

### Migration plan (only if multi-PR)
<Numbered steps if the thorough fix needs more than one PR.>

## When *not* to fix

<Pragmatic guard rail. When is the smell tolerable? Avoid making the reader feel obligated to fix every instance immediately.>

## Lesson to internalize

> <One blockquote paragraph distilling the takeaway. The reader should be able to apply this without re-reading the entry.>
```

### Step 7 — Update the index

Edit `<analysis_folder>/code-smell-00-index.md`:

1. Add a row to the entries table:
   ```
   | NN | [Topic title](code-smell-NN-slug.md) | Smell name(s) | `file.ext:LINE` |
   ```
2. Keep rows in numeric order.

If `code-smell-00-index.md` doesn't exist yet, create it with a title, a one-line description of the series, and the table header shown above.

### Step 8 — Maintain the cheatsheet

If the entry cites a canon rule **not already in `code-smell-canon-cheatsheet.md`**, add a row for it. Don't duplicate existing rows.

If the cheatsheet doesn't exist in this analysis folder yet, copy from CM's as the seed.

### Step 9 — Confirm to user

Report:
- Path of the new entry (clickable `file:line`)
- NN assigned
- Canon rules cited
- Index updated: yes/no
- Cheatsheet rule added: yes/no/n-a

## Quality bars (non-negotiable)

- **Real file:line refs only.** Never invent line numbers. Re-read the file if uncertain.
- **Caller counts must be measured.** "19 of 19 sites" not "many sites."
- **Cite ≤ 3 canon rules per entry.** More is showing off.
- **Steelman before knocking down.** "What looks fine at first glance" must be honest, not a strawman. The series's pedagogy depends on the reader recognizing the rationalization in their own code.
- **Voice: teaching, not scolding.** The reader is the user's future self. Be direct about what's wrong, generous about why it happened.

## What this skill does not do

- Does not refactor the source code — only documents.
- Does not commit to git. The user reviews and commits when ready.
- Does not file PRs or tickets.
- Does not invent smells. If the user points at code that's fine, say so.

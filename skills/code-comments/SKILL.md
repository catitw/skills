---
name: code-comments
description: >-
  Write high-signal, plain-language code comments for Rust. Let structure explain
  the what; let comments explain the why, the why-not, the invariants, the history,
  and the safety reasoning. Use when writing or reviewing //! crate/module docs,
  /// item docs (rustdoc), // SAFETY: blocks, or inline rationale, and whenever you
  want those comments to help future humans and coding agents make the right edit.
  Covers rustdoc sections (# Panics, # Errors, # Examples), doc tests compiled by
  `cargo test`, templates, and anti-patterns.
---

# Code Comments (Rust)

Write Rust so the structure explains the **what**. Write comments so future humans
and agents understand the **why**, **why-not**, **what must stay true**, and **what
already happened here**.

## Core Philosophy

**Comments are not the enemy.** A comment that records a *why* — a decision, a
constraint, an invariant, a tradeoff, a piece of history, or safety reasoning — is
an asset, not noise. The goal is not fewer comments; it is *higher-signal*
comments. Stripping comments reflexively deletes exactly the context that stops
the next human (or agent) from reintroducing a bug you already fixed.

**A WHAT-comment is a refactor signal, not a target for deletion.** When you feel
you must write a comment to explain *what* the code does, the code is telling you
it is not clear enough yet. The fix is to refactor — rename, extract a function,
reorder, collapse duplication — until the comment is no longer needed, *then*
remove it. Do not delete the comment and leave the unclear code behind — that
removes the warning without fixing the cause. As the comments-smells skill warns,
**a comment is the deodorant of the code**: it masks the smell rather than curing
it. So read such a comment as a signal to refactor, not a chore to keep: per XP's
rule of thumb, "A comment is a sign that the code is not finished."

> "The whole point is not to delete comments, but to obviate them and then delete
> them." — Tim Ottinger

In short: a comment that explains **why a decision was made** stays. A comment
that only restates **what the code does** is a diagnostic that the code should be
rewritten.

**Write in plain, concrete language — no insider jargon.** Describe the real
thing: name the system, the field, the condition, the consequence. Avoid obscure
terms, project-only slang (黑话), and unexplained abbreviations. The test is
simple — a developer who joined yesterday, reading this one comment cold, should
be able to act correctly without finding a teammate to translate it.

**Structure first, comments second.** Before adding a comment, ask whether clearer
code — a better name, an extracted function, a reordered block, or deleting dead
code — could remove the need for it. Comment only the context that cannot live in
the code itself.

**Co-location wins.** Documentation in separate files drifts out of sync. Comments
that sit next to the code they describe stay accurate, because they are updated
together in the same diff. This is exactly why Rust puts documentation *inside*
the source as `//!` and `///` comments: the docs travel with the item.

**The "why" test.** Before writing a comment, ask: *"Does this explain **why** this
code exists or why it works this way?"* If it only restates **what** the code does,
skip it. Restating `user.is_admin()` as `// check if admin` adds nothing.

## The Core Rule (apply in order)

```text
1. Rename, extract, reorder, or delete code until the intent is obvious.
2. Add a comment only when the missing context cannot live in code.
3. Put the shortest useful comment as close as possible to the code.
4. Keep the comment short, local, and durable (it must survive a routine refactor).
```

Good comments reduce wrong edits. Great comments stop humans and agents from
repeating old mistakes.

## The Comment Test

Before keeping a comment, answer all three:

```text
Can clearer code remove the need for this comment?
  Yes -> refactor first.
  No  -> comment the missing context.

Will this comment still be true after a small refactor?
  No  -> move the detail into code, or delete it.
  Yes -> keep it.

Does this comment tell the reader something the code cannot?
  No  -> delete it.
  Yes -> keep it.
```

## Write For Three Audiences

Every high-signal comment should help all of these at once:

1. **Your future self** scanning the file at speed six months from now.
2. **A teammate** reading unfamiliar code without the original decision context.
3. **A coding agent** (Claude, Copilot, etc.) that sees one file at a time and
   proposes edits from local evidence only.

That means: prefer explicit nouns over vague pronouns, name the thing that would
break, state the consequence (not just the preference), cite an issue or incident
id when one exists, and keep comments local and durable.

## Rust's Three Comment Types

Rust has exactly three comment forms. Picking the right one matters because two of
them become real documentation rendered by `rustdoc` (and even compiled as tests).

### `//!` — inner doc comment (crate / module documentation)

Documents the item that **contains** the comment — i.e. the crate or module the
file belongs to. This is the idiomatic way to document a crate from its root
(`src/lib.rs`, `src/main.rs`) or a module from inside its file. It renders as the
module's description in `rustdoc` and is what populates the crate's front page.

```rust
// src/lib.rs
//! # payment-engine
//!
//! Settles authorize/capture flows against multiple acquirers.
//!
//! The core abstraction is [`Router`]: callers hand it an [`Authorization`] and
//! it picks the acquirer and records the ledger entry in one transaction.
```

Use it to state what the module/crate is responsible for, why it exists when the
name does not make it obvious, and how it relates to the rest of the codebase.

### `///` — outer doc comment (item documentation → rustdoc)

Documents the item that **follows** it: a function, method, struct, enum, variant,
trait, module declaration, constant, or `impl` block. This is what becomes the
item's page in `rustdoc`, supports Markdown, and is where you describe the
**contract**, not the implementation.

```rust
/// Adds `a` and `b`, saturating at the numeric bounds instead of wrapping.
///
/// Use this instead of `+` for counters that must never overflow.
pub fn saturating_add(a: u64, b: u64) -> u64 { /* ... */ }
```

Rule of thumb: document the **contract** (what it does, inputs, outputs, side
effects, sharp edges), never a line-by-line translation of the body.

### `//` — ordinary comment (for humans only)

Ignored by `rustdoc`. Use it for internal rationale, decisions, invariants, and
notes that are meant for someone reading the source — not for API consumers.

```rust
// Sort oldest-first: newer items are more likely to be edited again, so
// processing them last avoids redoing work.
queue.sort_by_key(|t| t.created_at);
```

## Rustdoc Sections: `# Panics`, `# Errors`, `# Examples`

Standard Markdown headings inside `///` (and `//!`) become structured sections in
`rustdoc`. Three are near-universal for functions and methods:

### `# Panics`

Document every condition under which the function panics, and why. If a function
**can** panic, say so; if it is guaranteed not to, that is worth saying too.

```rust
/// Integer division.
///
/// # Panics
///
/// Panics if `b == 0` (checked via `assert!`). Callers that handle division by
/// zero themselves should use [`checked_div`](i32::checked_div) instead.
pub fn div(a: i32, b: i32) -> i32 { /* ... */ }
```

### `# Errors`

For functions returning `Result`, document when the result is `Err` and which
error variants callers can expect. Do not promise exhaustiveness you cannot keep.

```rust
/// Loads and parses the TOML config at `path`.
///
/// # Errors
///
/// Returns `Err` if the file is missing, unreadable, or not valid TOML.
pub fn load(path: &Path) -> Result<Config, ConfigError> { /* ... */ }
```

### `# Examples`

A `# Examples` section with a fenced code block is the canonical way to show
usage — and it doubles as a test (see the next section).

```rust
/// # Examples
///
/// ```
/// use payment_engine::div;
/// assert_eq!(div(10, 2), 5);
/// ```
```

## Doc Tests Are Compiled By `cargo test`

Code blocks inside `///` and `//!` comments are extracted by `rustdoc` and
**compiled and run as tests** when you run `cargo test`. Treat examples like real
code: a broken example fails CI.

- Prefix a line with `# ` to hide setup (e.g. `# use crate::Foo;`) from readers
  while keeping the example compilable.
- Annotate a block to change how it runs:
  - `` ```no_run `` — compile, but do not execute (for I/O or long-running code).
  - `` ```ignore `` — do not even compile (kept for illustration only).
  - `` ```should_panic `` — expect the example to panic.
  - `` ```compile_fail `` — expect it to fail to compile (used in tests of macros).
- A block whose language tag is not Rust (e.g. `` ```text ``) is **not** compiled.

Consequence: keep `# Examples` honest. If the signature changes, the doctest must
change in the same commit or `cargo test` goes red.

## `// SAFETY:` Convention

Every `unsafe` block should carry a `// SAFETY:` comment justifying **why** the
operation is sound here — which invariants you are upholding and why they hold.
This is the established convention; the `clippy::undocumented_unsafe_blocks` lint
flags `unsafe` blocks that lack one.

`unsafe fn` is different: it documents its **safety contract** with a `# Safety`
section in its `///` docs (so callers know what they must guarantee), and each call
site that enters `unsafe` then carries its own `// SAFETY:`. In short: `// SAFETY:`
justifies a *block*; `# Safety` states a function's *contract*.

Name the specific invariant you are relying on, not a generic "this is fine":

```rust
unsafe {
    // SAFETY: `buf` points to `len` valid `u8`s because it was allocated with
    // capacity `len` and filled by `read_exact` immediately above.
    core::slice::from_raw_parts(buf.as_ptr(), len)
}
```

For an `unsafe fn`, the `# Safety` section states what the caller must uphold:

```rust
/// Read `len` bytes directly from a raw pointer.
///
/// # Safety
///
/// `ptr` must point to at least `len` valid, initialized bytes for the entire
/// call (no concurrent mutation, no aliasing `&mut`).
pub unsafe fn read_bytes(ptr: *const u8, len: usize) -> &[u8] { /* .. */ }
```

A `// SAFETY:` that restates "this is safe" without naming the invariant is the
`unsafe` equivalent of a narration comment — delete it and write the real reason.

## What To Comment

Comments earn their keep when they capture one of these. Each is shown as an
ordinary `//` comment, but the same ideas fit inside `///` doc comments where they
belong to the public contract.

- **Intent** — why this code exists.
  `// Normalize partner payloads here so the pipeline can assume our field names.`
- **Constraint** — a rule forced by product, legal, protocol, or platform limits.
  `// Keep card brand names verbatim for PCI audit exports; product copy lives elsewhere.`
- **Invariant** — a property that must stay true across future changes.
  `// INVARIANT: cache keys must include tenant_id; cross-tenant keys leak data, not just miss.`
- **Tradeoff** — why a less-obvious implementation beat the simpler-looking one.
  `// We batch writes every 250ms: immediate writes looked simpler but doubled p95 latency.`
- **History** — what already happened that future editors should know.
  `// Cap retry backoff at 5s; a longer cap expired checkout sessions (incident 2024-11-18).`
- **Warning** — what not to "simplify" and why.
  `// Do not collapse into one upsert: duplicate webhooks arrive out of order on purpose.`
- **Reference** — where the deeper story lives.
  `// Escaping follows RFC 4180 with an Excel-specific quoting carve-out (see RFC in /docs).`

## What Not To Comment

Do not comment things that should live in code.

Bad:

```rust
// Increment retry count
retries += 1;

// Get the user
let user = repo.find(user_id).await?;
```

Better (the names already say it):

```rust
retries += 1;
let user = repo.find(user_id).await?;
```

If a comment only translates a weak name into better English, **fix the name**.
`// user's email` above `let eml = user.email;` is a prompt to rename `eml`, not
a reason to comment.

## Documentation Levels (Rust)

### Crate & module docs — `//!`

Open every crate root and non-trivial module with a short `//!` block: what this
module is responsible for, why it exists if the name does not say, and its key
relationships to the rest of the codebase.

### Item docs — `///`

Document public items (`pub fn`, `pub struct`, `pub enum`, `pub trait`, …) with
`///`, focusing on contract and sharp edges. **Skip** simple getters and obvious
one-liners whose name + type already tell the whole story. Enable
`#![warn(missing_docs)]` to make the compiler require docs on *every* public item —
that also covers those getters, trading a little verbosity for guaranteed coverage.

Use the rustdoc structure for anything with a real boundary:

```text
What it guarantees          -> prose + # Panics
What it mutates or emits    -> side effects
What callers must provide   -> parameters and preconditions
When it is unsafe/expensive -> # Errors, # Panics, performance notes
```

### Inline comments — `//`

Use sparingly, close to the code, and only for reasoning the code cannot show.

### Architectural comments — `//`

For code that embodies an important design decision, explain the tradeoff where
it lives:

```rust
// ARCHITECTURE NOTE: cart state is event-sourced (add/remove/update events)
// rather than stored directly. This gives full history and replay-for-debugging.
// Tradeoff: reading current state replays all events; we cache the projection
// in Redis (5min TTL, invalidated by CartEventHandler).
```

### `TODO` / `FIXME` / `HACK` comments

Make them actionable and traceable, never open-ended:

```rust
// TODO(pete): extract to a shared util once the mobile team needs this.
// Blocked on mobile API parity — see MOBILE-123.

// FIXME: race condition on rapid toggle; cancel in-flight requests (issue #892).
```

## Rust Comment Templates

Replace the bracketed facts with concrete details.

### Item doc with rustdoc sections

```rust
/// <one-line summary of the contract>.
///
/// <1–2 sentences of why/when, only if not obvious from the signature>.
///
/// # Errors
///
/// Returns `Err(<variant>)` when <condition>.
///
/// # Panics
///
/// Panics if <precondition> is violated.
///
/// # Examples
///
/// ```
/// use crate::<path>::<item>;
/// assert_eq!(<item>(<input>), <expected>);
/// ```
pub fn <name>(/* .. */) -> /* .. */ { /* .. */ }
```

### Crate / module header

```rust
//! # <crate or module name>
//!
//! <what this is responsible for>.
//!
//! <why it exists / key relationships, if not obvious>.
```

### `// SAFETY:`

```rust
unsafe {
    // SAFETY: <the specific invariant relied on, and why it holds here>.
    /* unsafe operation */
}
```

### Decision comment

```rust
// Use <approach> because <constraint/tradeoff>.
// <alternative> looked simpler but failed on <case>. See <issue/incident>.
```

### Invariant comment

```rust
// INVARIANT: <property that must remain true>.
// If this changes, <concrete bad outcome>.
```

### Compatibility / incident / temporary comments

```rust
// Keep <odd code> for <legacy/vendor/platform> compatibility.
// Remove only after <specific event/version/date + owner>.

// Added after <incident/bug>; guards against <failure mode> when <trigger>.

// TEMP: <workaround>. Remove after <specific event/version/date>, not "later".
```

### Reference constants, don't duplicate values

```rust
// Bad: duplicates the value, drifts when the constant changes.
/// Returns true if stale (not updated in the last 5 minutes).
pub fn is_stale(&self) -> bool { /* .. */ }

// Good: references the constant by name.
/// Returns true if stale (not updated within [`STALE_THRESHOLD_SECS`]).
pub fn is_stale(&self) -> bool { /* .. */ }
```

Translating a magic number with a unit hint (`1048576 // 1 MiB`) is fine, since
it adds clarity rather than duplication.

## Anti-Patterns & Smells

These include the classic **Comments smell**: a comment that explains *what* code
does instead of *why*. As the philosophy above says, treat a WHAT-comment as a
signal to refactor the code, then delete the now-redundant comment.

### Comment smell → treatment

| The comment looks like it… | Treatment |
|----------------------------|-----------|
| explains a complex expression | extract a well-named binding |
| describes what a block does | extract a function (its name becomes the comment) |
| exists because a name is unclear | rename the function/variable |
| documents a required precondition | encode it as an `assert!` / type / `// SAFETY:` |
| documents expected behavior or edge cases | write a `# Examples` doctest |
| restates the code | delete |
| is commented-out code | delete (version control remembers it) |
| is outdated or misleading | delete |

In Rust, a `# Examples` doctest often *absorbs* a comment that only described
behavior: the example becomes both the explanation and an executable test run by
`cargo test`.

### Keep these (they are not smells)

- **Why-comments** — the decision, constraint, tradeoff, or history behind the code.
- **Complex algorithms** where simpler alternatives were genuinely exhausted.
- **Public API docs** — `///` rustdoc is documentation, not narration.
- **External references** — issue ids, incident dates, RFCs, links to specs.
- **Non-obvious order-of-execution or platform constraints.**
- **`// SAFETY:`** — required on `unsafe`, not optional.
- **TODO/FIXME** — fine when dated and traceable (see templates).

### Smells to remove

- **Narration.** `// loop over items` above a `for` loop. The code already says
  this. Delete it.
- **Name translation.** `// user's email` above `let eml = user.email;`. Rename
  the binding; do not narrate the bad name.
- **Vague intent.** `// handle edge case`. Name the edge case *and* the
  consequence if it is mishandled.
- **Fake temporariness.** `// TEMP: remove later`. It never is. Say *when*, *after
  what*, and *by whom* if relevant.
- **Ghost history.** `// weird bug fix`. Which bug? Under what condition? What
  breaks if it is removed? Cite the issue or incident.
- **Comment drift.** `/// sorted ascending` above code that sorts descending.
  Stale comments are worse than no comments — and a stale `# Panics`/`# Errors`
  section is a contract violation, not a style slip.
- **Essay comments.** Do not bury the point in five lines of setup. Lead with the
  rule or decision, then add one sentence of context only if needed.
- **Wrong comment type.** Using `//` where `///` belongs loses the rustdoc page
  and the doctest; using `///` for a private internal note clutters the docs.
- **Bare `// SAFETY:`.** `// SAFETY: it's fine` next to `unsafe`. Name the actual
  invariant or delete the `unsafe`.
- **Promised panics/errors that don't exist.** A `# Panics` section on a function
  that never panics, or a missing `# Panics` on one that does. Keep the contract
  and the code in sync.
- **Unjustified `unwrap`/`expect`.** If you `unwrap`, the rationale ("input was
  validated upstream" / "non-empty is a module invariant") belongs nearby.

## Writing Style

- **Plain, concrete language — no jargon.** Write so a developer who just joined
  can get up to speed fast: name the real system, field, condition, and
  consequence. Avoid obscure insider terms, project-only slang (黑话), and
  unexplained abbreviations. If a reader would need a teammate to translate a
  comment, rewrite it.
- **Active voice.** "This function validates…" not "validation is performed…".
- **Be specific.** "Retries 3 times with 1s backoff" not "handles retries".
- **Skip the obvious.** If the code says `user.is_admin`, do not explain it.
- **Date things that expire.** Workarounds, edition/version-specific code, and
  temporary solutions should state when they can be removed.
- **Reference constants, don't duplicate values.** Cite a constant by name in
  rustdoc so the doc cannot drift from the value.
- **Lead with the decision or warning.** Then add context, not the reverse.
- **Name concrete systems, fields, incidents, and documents.** Prefer
  `Do not … because …` over soft phrasing. Prefer one strong comment over three
  weak ones.
- **No jokes, filler, or private context** nobody else can recover.

## Review Checklist

Before keeping a comment, confirm all of these:

```text
[] Does the code already say this?
[] Does the comment explain why, a constraint, an invariant, a tradeoff, history, or a warning?
[] Is the comment specific about what breaks or what matters?
[] Will the comment likely survive a routine refactor?
[] Should any extra detail be cut because the local comment is already enough?
[] Did I cite a reference if the decision came from an issue, incident, or RFC?
[] Is it the right comment type for the job (//!, ///, or // — with // SAFETY: where needed)?
[] Will it stop a smart agent from making the wrong cleanup?
```

If the last answer is no, the comment is probably not pulling its weight.

## Editing Workflow

When you change code:

```text
1. Delete comments your change made obsolete.
2. Rewrite comments whose scope changed.
3. Add a short decision comment if the new code looks "weird" for a reason.
4. Leave the file with higher-signal comments than you found it — remove the
   noise, keep the why (more signal, not necessarily fewer lines).
```

The goal is not more comments. The goal is better evidence for future readers —
human and agent — so they make the right edit the first time.

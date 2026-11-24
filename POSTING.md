# Posting guide

Everything below is in this folder. Pick a target and paste.

## 0. Read this first — the 30,000-character limit

MathOverflow rejects a body over 30,000 characters, and **selecting the whole published page
(Ctrl+A) yields about 34,000** — that is what triggers the error. The answers themselves are far
below the limit.

So do not select the whole page. Open the **one-answer-only page** for what you are posting.
Each of those pages contains that single answer and nothing else, so even Ctrl+A there selects
only the answer. The page header shows the exact character count.

| Page | Answer | Characters |
|---|---|---|
| `mo-b.html` | MathOverflow 518109 — full | 3,893 |
| `mo-b-short.html` | MathOverflow 518109 — tightened | 3,674 |
| `mo-a.html` | MathOverflow 518033 | 7,498 |
| `issue.html` | GitHub issue body | 3,689 |

All four are below the limit with a wide margin.

## 1. MathOverflow (preferred)

Two questions are directly on point and both are open:

* **518109** — *After the Lean verification of the RH proof, what residual trust assumptions
  remain against a deliberately adversarial proof author?*
  https://mathoverflow.net/questions/518109/after-the-lean-verification-of-the-riemann-hypothesis-proof-what-residual-trust
  → open `mo-b.html`, press **Copy Markdown**, paste into the answer box, **Post Your Answer**.

  This question is **not protected**: answering needs 1 reputation point only, so a new account
  can post here.

* **518033** — *How to "human verify" enormous AI math output?*
  https://mathoverflow.net/questions/518033/how-to-human-verify-enormous-ai-math-output
  → open `mo-a.html`, same procedure.
  **This question is protected**: answering requires 10 reputation points. A new account cannot
  post there until it earns 10 (an answer upvoted +10, a question upvoted +10, or an answer
  accepted +15; the 100-point association bonus does *not* cross the threshold on a target site).

Before posting: set the MathOverflow display name to **David Zhu**
(profile → user settings), so the attribution matches the rest of the material.

## 2. GitHub issue (for the author)

* Target: https://github.com/alpoge → Issues → New issue
* Title: `A navigation map for the RH formalization - and an independent re-derivation of the zeta case`
* Body: open `issue.html`, press **Copy Markdown**; first line `@alpoge`
* Attach: `ProofSkeleton.md`, `Skeleton.lean`

The author's contact address is not published on `alpo.ge` (checked 2026-11-24); the GitHub
account `alpoge` is the reachable channel.

## 3. Lean Zulip

* Target: https://leanprover.zulipchat.com — `#mathlib` or `#general`
* Body: `drafts/01-zulip.md` in the sibling `PUBLISH/drafts` folder
* Attach `ProofSkeleton.md` and `Skeleton.lean`.
* Note: Chris Birkbeck has already posted a five-step summary of the argument on Zulip, and the
  Lean community is actively compressing the development, so the framing that works here is
  "an executable verification sample", not "a map of the proof".

## 4. Reddit r/math

* Body: `drafts/02-reddit-math.md` in the sibling `PUBLISH/drafts` folder
* Link the GitHub issue if it exists by then; a link to a public thread removes the
  self-promotion objection.
* Post it a day or two after the GitHub issue, not before.

## 5. Not recommended

The mirror repository `leanprover-community/riemann-hypothesis` has Discussions disabled, and
its issue tracker is dominated by substantive engineering work on the artifact itself
(`perf:` build-time reductions, `refactor:` consolidations, `Reuse …`, `Share the …`).
A reading guide is a different genre and lands as noise there. If the author asks for it, a
short pointer with the community's own vocabulary is the right form.

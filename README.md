# A reading map for the Lean RH formalization

Materials accompanying a public MathOverflow answer and a note to the author of the
formalization. All files here are self-contained and need no build step to be read.

## What is in this repository

| File | What it is |
|---|---|
| `ProofSkeleton.md` | The reading map: a one-page layer diagram, each layer's entry theorem with its signature, the load-bearing directories, a suggested reading order, and the caveats. |
| `Skeleton.lean` | A machine-checkable interface certificate. The zeta case is a complete Lean proof; deeper layer interfaces are recorded as data with the file path where each can be checked, and the consistency of the dependency map is decided by `decide`. Needs only Mathlib and Lean 4.33.1. |
| `mo-answer-A.md` | MathOverflow answer for question 518033 (*How to "human verify" enormous AI math output?*). |
| `mo-answer-B.md` | MathOverflow answer for question 518109 (*residual trust assumptions after Lean verification*). Posted as answer 518163. |
| `github-issue.md` | The note addressed to the author. |
| `POSTING.md` | Posting guide for the individual pages. |

## The two claims that are specific to this contribution

1. The zeta case of the top layer (`Claim.strip`) can be re-derived independently of the
   Dirichlet-character machinery: `riemannZeta_one_sub` plus a trichotomy suffice. The
   write-up is 12 lines of Lean, compiles, and its axiom dependencies are exactly
   `propext`, `Classical.choice`, `Quot.sound` — no additional axioms, and no assumption of
   the Riemann hypothesis.
2. The statement that the duality cancellation must occur at the midpoint is *equivalent*
   to the Riemann hypothesis (`Iff RiemannHypothesis`), not a strengthening of it.

The point of the whole set: navigation of the formalization and high-level summaries already
exist elsewhere; what was missing is **an executable verification sample**.

## Scope and caveats

No mathematics of the original submission is reproduced here. Theorem names and signatures
are quoted only, with file paths so every claim can be checked against the mirror. The
layering is a reconstruction made for reading purposes and is not claimed to be canonical.
The author has stated that the argument will be simplified substantially, so this is a map
of the current artifact, not of an endpoint.

Signed: David Zhu.

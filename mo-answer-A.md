Timothy Chow's summary of the argument says that RH is deduced from "no Dirichlet L-function
vanishes for `Re(s) > 1/2`", and that this step "is short and standard". Two of the ingredients
this question asks for are now available: there is a navigable map of the development (the
statement list with proof-share attribution at `andrewodesky.com/rh/`, which covers 1,722
theorems and orders them by their share of the Lean dependency graph), and there is a
five-step summary of the argument (quoted in the question). What I would like to add is a third
thing, which is neither a map nor a summary but an *executable sample*: a piece of the argument
that anyone can check on their own, without reading anything else.

The step Chow calls "short and standard" turns out to be exactly that kind of piece. In the ζ
case it admits a complete formalization against Mathlib alone, in about a dozen lines, with no
hypothesis of the Riemann hypothesis anywhere — and, as a bonus, it identifies precisely what
the hard part is.

Here it is. It compiles, and its axiom dependencies are exactly `propext`, `Classical.choice`,
`Quot.sound` — the same three that the submission itself uses:

```lean
import Mathlib.NumberTheory.LSeries.RiemannZeta
import Mathlib.NumberTheory.LSeries.Nonvanishing

open Complex

/-- The only hypothesis: no complete dual cancellation to the right of the critical line.
    This is the machine content of "Re s > 1/2 → L(χ,s) ≠ 0", for ζ. -/
def NoCancellationRight : Prop :=
  ∀ s : ℂ, 1 / 2 < s.re → s ≠ 1 → riemannZeta s ≠ 0

/-- Duality reflection: a zero reflects to its dual side. Unconditional — this is the
    functional equation `ζ(1-s) = 2(2π)^{-s} Γ(s) cos(πs/2) ζ(s)`. -/
theorem duality_reflection {s : ℂ} (hz : riemannZeta s = 0)
    (hs0 : 0 < s.re) (hs1 : s ≠ 1) : riemannZeta (1 - s) = 0 := by
  have hnneg : ∀ n : ℕ, s ≠ -n := by
    intro n hn
    have hre : (-(n : ℂ)).re = -(n : ℝ) := by
      rw [Complex.neg_re]
      norm_num
    have hn0 : (0 : ℝ) ≤ n := Nat.cast_nonneg n
    rw [hn, hre] at hs0
    linarith
  rw [riemannZeta_one_sub hnneg hs1]
  simp [hz]

/-- Stripping: inside the critical strip, complete dual cancellation can only occur at the
    point where the two sides balance, Re s = 1/2. -/
theorem strip_of_no_cancellation (h : NoCancellationRight) :
  ∀ s : ℂ, riemannZeta s = 0 → 0 < s.re → s.re < 1 → s.re = 1 / 2 := by
  intro s hz hs0 hs1
  have hne1 : s ≠ 1 := by
    intro e
    rw [e, Complex.one_re] at hs1
    exact lt_irrefl _ hs1
  rcases lt_trichotomy s.re (1 / 2 : ℝ) with hlt | heq | hgt
  · exfalso
    have hp := duality_reflection hz hs0 hne1
    have ht : (1 : ℂ) - s ≠ 1 := by
      intro e
      have hs0' : s = 0 := sub_eq_self.mp e
      rw [hs0', Complex.zero_re] at hs0
      exact lt_irrefl _ hs0
    exact h (1 - s) (by rw [Complex.sub_re, Complex.one_re]; linarith) ht hp
  · exact heq
  · exact absurd hz (h s hgt hne1)
```

The proof is a three-way split on `Re s` against `1/2`. To the right contradicts the
hypothesis; to the left, the functional equation reflects the zero to the right, where it again
contradicts the hypothesis; equality is the conclusion. Nothing else is used.

**What the sample is for.** The point of a navigable map is to make the argument *locatable*;
the point of a summary is to make it *comprehensible*. Neither of those is the same as
*checkable*, and checkability is the one thing a formalization is supposed to buy you. The
sample above says: here is a piece of the 17-million-line development that you can discharge
yourself, in an afternoon, with nothing but Mathlib — and here is the machine evidence that it
holds (it compiles, and its axiom dependencies are the three standard ones). If one believes, as
the convex-hull heuristic on the Proofs and Prompts blog suggests, that a large proportion of
the argument is "known ideas" recombined, then the interesting object to examine is the
*recombination*, i.e. how the known pieces are wired together — and the top of the argument is
where that wiring becomes visible and, crucially, where it is short enough to be audited by
hand. The wiring below it is not auditable by hand; the top of it is.

**Why this is worth posting separately from the map.** In the submitted development the
corresponding step is `Claim.strip` in
`src/Development/AutomorphicArithmetic/CharacterBoxes/ClaimStrip.lean`, and it is stated for a
general Dirichlet character, so it carries two extra ingredients that the ζ case does not need:
`Claim.prim_zero` (passing to the primitive character) and `Claim.factor_ne_zero` (Euler
factors cannot vanish to the right of zero), plus the primitive-character form of the
functional equation in `Claim.prim_reflect`. For ζ those are all dead weight — the trivial
character at level 1 is already primitive and has no Euler factor problem, and the functional
equation is the plain `riemannZeta_one_sub`.

The consequence is that the *reduction* from "no zeros to the right of 1/2" to "the Riemann
hypothesis" can be discharged without touching the 17-million-line development at all: it is a
standalone file depending only on Mathlib. That seems like the right shape for an answer to
"how do we human-verify enormous AI math output" — not a new proof, but a demonstration that
part of the argument can be lifted out and checked on its own, in an afternoon, by anyone.

**On the structure underneath.** The layer that this reduction sits on is the zero-free region
for ζ, `src/Formalism/ZeroFreeRegion/` (`FinalZFR.lean`, `LogDerivRegion.lean`,
`SmallHeightLogDeriv.lean`), which is also the part of the development currently being worked on
by the active compression effort: the zero-free-region pillar is listed as reduced by about 95%,
with the final zero-exclusion glue layer still much less compressed. So the structure is roughly

```
zero-free region for ζ  (Re s > 1/2 ⇒ ζ(s) ≠ 0)      ← the only input above
        ↓  functional equation + trichotomy            ← the 12 lines above
zeros lie on Re s = 1/2
```

with the assembly of the general `L`-function case — clopen decomposition and the weight-one
Lefschetz formula, weight one realized geometrically, Galois representations from theta
lifts, local–global strong lifting, and the final assembly — sitting underneath the first line.

**A related observation about the reduction itself.** The proposition "the ζ zeros lie on
`Re s = 1/2`" and the proposition "the dual balance point is `σ = 1/2`" are not merely analogous;
after excluding the trivial zeros they are the same statement. Formally, in Lean:

```lean
theorem fr_step3_eq_RH :
    (∀ s : ℂ, riemannZeta s = 0 → (∀ n : ℕ, s ≠ -2 * (n + 1)) → s ≠ 1 → s.re = (1 / 2 : ℝ))
      ↔ RiemannHypothesis
```

So any argument phrased as "the dual cancellation must balance at the midpoint" is, once the
trivial zeros are excluded, not a route *around* the Riemann hypothesis but a restatement of
it. That is a useful thing to know when reading any claimed short proof of RH: the question to
ask is not whether the midpoint is forced, but what forces it.

— David Zhu

*Files: `ProofSkeleton.md` (the layer map) and `Skeleton.lean` (the machine-checkable interface
certificate; the two theorems above are imported into it and compile) are published at
<https://rh-proof-map.app.workbuddy.host/?sharecode=PV6OPU5DQ4>, together with one-click copy buttons for this answer and for the companion
answer to the other question. The Lean file can be compiled directly against Mathlib and
Lean 4.33.1.*

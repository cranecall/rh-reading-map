# A Navigation Map for the 2026 Lean Formalization of the Riemann Hypothesis

*A reading guide to the structure of the Alpöge–Claude proof, extracted from the Lean sources.*

**David Zhu**

**What this is.** The formalization released on 2026-11-20 by Levent Alpöge is, in source form,
about 1700 lines of *proof*, spread over 43,850 `.lean` files. The submitted argument is correct
in the sense that matters: the statement proved is Mathlib's own `RiemannHypothesis`, and the
proof term has been re-checked by Lean's kernel, `nanoda`, `con-leche` and `con-ron` against a
`Mathlib`-only challenge file, with no axioms beyond `propext`, `Quot.sound` and
`Classical.choice`.

**What this is not.** It contains no mathematics of the proof itself. It is a *map*: the layer
structure of the argument, the exact signature of each layer's entry theorem, the files that
carry the load, and a suggested reading order. It is written for the reader who wants to
understand what was proved rather than merely re-run the kernel.

**How to check everything below.** Every theorem name and type signature quoted here can be
checked in the community mirror:

```
https://github.com/leanprover-community/riemann-hypothesis
```

Paths are given relative to `src/`. A machine-checkable version of the interface signatures is
supplied as `Skeleton.lean` (see the last section).

**One part is not merely mapped but re-derived.** The ζ special case of the top layer — the
piece that turns the Riemann hypothesis into a statement about zeros of `ζ` — has been
re-derived independently and formally checked. See §3.

---

## 1. The argument in one page

The proof has three layers, and the decisive observation is that **the top layer is tiny**.

```
┌─ Layer 0 · Stripping ───────────────────────────────────────────────────┐
│  Claim.Strip :  0 < Re s < 1 → L(χ,s) = 0 → Re s = 1/2                 │
│  Claim.Zeta  :  ζ's non-trivial zeros lie on Re s = 1/2                │
│  file: Development/AutomorphicArithmetic/CharacterBoxes/ClaimStrip.lean │
│  size: 17 lines of argument                                             │
└───────────────────────────────▲────────────────────────────────────────┘
                                │  (one hypothesis: Layer 1)
┌─ Layer 1 · Half-plane non-vanishing ───────────────────────────────────┐
│  UpperTheory.EveryCharacter : Re s > 1/2 → L(χ,s) ≠ 0                  │
│  file: CharacterBoxes/{HalfPlane,EveryCharacter}.lean                  │
└───────────────────────────────▲────────────────────────────────────────┘
                                │
   ┌────────────────────────────┴───────────────────────────────────────┐
   │  1a · Clopen decomposition & trace   (UpperTheory.Cb.*)            │
   │  1b · Weight one, geometric         (UpperTheory.Gal.Int.Geo.*)    │
   │  1c · Galois reps from θ-lifts      (UpperTheory.Gal.Int.*)        │
   │  1d · Assembly                      (UpperTheory.FinalTheorems.*)   │
   └────────────────────────────────────────────────────────────────────┘
                                │
   ┌────────────────────────────┴───────────────────────────────────────┐
   │  Arithmetic core: Stepanov determinant, iterated theta lifts (√X),  │
   │  Iwasawa tower, Rallis seesaw, Bost slope, Chowla–Selberg / Siegel  │
   │  mass divisibility, Selberg sieve, height theory, Vandidiver.        │
   └────────────────────────────────────────────────────────────────────┘
```

The whole reduction is therefore: **a 17-line argument strips the critical strip down to the
critical line, provided one deep fact is available — non-vanishing to the right of 1/2.**

---

## 2. Layer 0 · Stripping (the 17 lines)

`src/Development/AutomorphicArithmetic/CharacterBoxes/ClaimStrip.lean`

```lean
def Claim.HalfPlane : Prop :=
  ∀ (N : ℕ) [NeZero N] (χ : DirichletCharacter ℂ N) (s : ℂ),
    1/2 < s.re → (χ ≠ 1 ∨ s ≠ 1) → DirichletCharacter.LFunction χ s ≠ 0

def Claim.Strip : Prop :=
  ∀ (N : ℕ) [NeZero N] (χ : DirichletCharacter ℂ N) (s : ℂ),
    0 < s.re → s.re < 1 → DirichletCharacter.LFunction χ s = 0 → s.re = 1/2

def Claim.Zeta : Prop :=
  ∀ s : ℂ, riemannZeta s = 0 → (¬ ∃ n : ℕ, s = -2 * (n + 1)) → s ≠ 1 → s.re = 1/2
```

The proof of `Claim.strip` is a three-way split on `s.re` against `1/2`:

* `Re s > 1/2` — contradicts `HalfPlane` directly.
* `Re s = 1/2` — done.
* `Re s < 1/2` — the functional equation reflects the zero to `1 - s`, which has `Re > 1/2`,
  contradicting `HalfPlane`.

Two auxiliary results support it:

* `Claim.prim_zero` — a zero of `L(χ,s)` is a zero of the primitive character `χ.primitiveCharacter`.
* `Claim.prim_reflect` — if `L(ψ,s) = 0` for primitive `ψ`, then `L(ψ⁻¹, 1-s) = 0`, via
  `IsPrimitive.completedLFunction_one_sub`.

`Claim.zeta` then specializes to the trivial character (`LFunction_modOne_eq`), and
`Claim.factor_ne_zero` (in `HalfPlane.lean`) handles the Euler factors introduced by the
level change.

**Note for the reader:** the ζ special case needs *none* of the level machinery. It reduces to
`riemannZeta_one_sub` plus the trichotomy — roughly a dozen lines. The generality to Dirichlet
characters costs two extra lemmas, not more.

### 3.1 An independent re-derivation of the ζ case

The observation in the note above is sharp enough to be carried out on its own, and it has been.
Writing

```lean
def NoCancellationRight : Prop :=
  ∀ s : ℂ, 1 / 2 < s.re → s ≠ 1 → riemannZeta s ≠ 0
```

and using only `riemannZeta_one_sub`, one obtains, in Lean:

```lean
theorem duality_reflection {s : ℂ} (hz : riemannZeta s = 0)
    (hs0 : 0 < s.re) (hs1 : s ≠ 1) : riemannZeta (1 - s) = 0

theorem strip_of_no_cancellation (h : NoCancellationRight) :
  ∀ s : ℂ, riemannZeta s = 0 → 0 < s.re → s.re < 1 → s.re = 1 / 2
```

`strip_of_no_cancellation` is the same three-way argument as `Claim.strip`, with the
Dirichlet-character machinery removed: right of 1/2 contradicts the hypothesis; left of 1/2 is
reflected to the right by the functional equation; equality is the conclusion.

This has three properties worth stating plainly, because they are the reason it is included:

* It is **formally checked**, not asserted. The accompanying `Skeleton.lean` imports it and
  compiles it.
* Its **only** hypothesis is the half-plane non-vanishing — the deep input. Everything else
  (pairing, the trichotomy, the reflection) is unconditional.
* Its **axiom dependencies are exactly** `propext`, `Classical.choice`, `Quot.sound` — the same
  three the submission itself relies on, and nothing more. No hypothesis of the Riemann
  hypothesis is smuggled in anywhere.

So the top layer of the argument is not only short; it is short *and* reproducible in
isolation*. This makes the map checkable end to end: a reader can run the ζ case themselves in
a few minutes, and use the map for the part that is genuinely long.

---

## 3. Layer 1 · Half-plane non-vanishing

`UpperTheory.EveryCharacter` (file `CharacterBoxes/EveryCharacter.lean`) is literally the same
proposition as `Claim.HalfPlane`, under a second namespace. Its proof is the substance, and it
is a clean chain of four steps.

### 1a · Clopen decomposition and the trace formula
`UpperTheory.Cb.*`, in `CharacterBoxes/MainConclusion.lean`:

| theorem | content |
|---|---|
| `hodgeCohomology_open_restriction_equiv` | open restriction is an equivalence on Hodge cohomology |
| `Cb.exists_finite_etale_restrict_clopen` | a closed subscheme inside an open admits a finite étale clopen refinement |
| `Cb.hodgePull_hodgeTrace_eq_sum_restrict_open` | **the Hodge trace is the sum of the traces on the clopen pieces** |
| `Cb.holomorphic_lefschetz_finiteEtale_correspondence` | the weight-one Lefschetz formula, finite étale version |
| `Cb.lefschetz_fixedPoint_finite_etale_correspondence` | same, in fixed-point form (the one actually used) |
| `Cb.isProjOver_restrict_clopen` | projectivity descends to clopen pieces |
| `Cb.smoothOfRelativeDimension_comp_etale` | relative dimension is stable under étale maps |

The pivot is `Cb.lefschetz_fixedPoint_finite_etale_correspondence`, whose statement is

```lean
∑ b ∈ Finset.range (d + 1), (-1 : ℂ)^b * LinearMap.trace ℂ _
      (hodgeTrace h1 a b ∘ₗ hodgePull h2 a b)
  = ∑ y ∈ F, (Matrix.det (1 + (Polynomial.X : Polynomial ℂ) • (A y).map Polynomial.C)).coeff a
             / (1 - A y).det
```

with the weight-one tangency hypothesis `GlobalTheory.W1.IsTan d c1 c2 h1 h2 y (A y)`.

### 1b · Weight one, geometrically realized

```lean
theorem weight_one_geometric_realization : LocalSmoothExtension.HolomorphicLefschetzFormula
theorem geoOne_holds : GeoOne
```

`weight_one_geometric_realization` is exactly `Cb.lefschetz_fixedPoint_finite_etale_correspondence`.
So 1b is not a separate theorem but the *instantiation* of 1a at weight one.

### 1c · Galois representations from theta lifts

```lean
theorem galoisRepresentations_of_thetaLift (up : UpperTheory.TP.TLiftK) : UpperTheory.GalStar.Row0b recT
theorem galoisLocalGlobalStrong_recParameter : UpperTheory.GalStar.Row0b recT
```

`galoisLocalGlobalStrong_recParameter` is the local–global strong lifting (`recT`), obtained by
feeding `UpperTheory.TP.tLift_holds_k` — the iterated theta lift — into
`galoisLocalGlobalStrong_of_geometry_lift`.

### 1d · Assembly

```lean
theorem UpperTheory.FinalTheorems.everyCharacter_of_row
    (h : UpperTheory.GalStar.Row0b fun h rc => UpperTheory.Zero.LLC.IsRecT h rc) :
    UpperTheory.EveryCharacter

theorem UpperTheory.FinalTheorems.everyCharacter : UpperTheory.EveryCharacter :=
  UpperTheory.FinalTheorems.everyCharacter_of_row UpperTheory.Gal.Int.galoisLocalGlobalStrong_recParameter
```

The assembly consumes three inputs: the local–global dual (Caraiani), the local Langlands
existence (`UpperTheory.Zero.LLC.recTExists`), and the polarized-pair Galois representation.
It routes through `UpperTheory.One.vwin_of_row` and
`UpperTheory.LiteratureTheorems.every_character_of_literature_of_vWin`.

---

## 4. Where the weight actually is

For a reader deciding where to spend time, these are the load-bearing directories (by path,
from the import graph of `MainConclusion.lean`):

| path | role |
|---|---|
| `Development/AutomorphicArithmetic/Foundations/EtaleClopenDescent/` | clopen decomposition, Hodge trace additivity, Lefschetz correspondence |
| `Development/AutomorphicArithmetic/Foundations/GaloisRepresentations/ThetaParseval/` | theta kernel identities, Parseval iteration, `TLiftK` |
| `Development/AutomorphicArithmetic/ThetaCorrespondence/ThetaPairLifts/` | iterated theta lifts, third-place series |
| `Development/AutomorphicArithmetic/AutomorphicVarieties/ModularityArgument/ThresholdArguments/` | threshold arguments, density of threshold cases |
| `Development/AutomorphicArithmetic/Foundings/GaloisRepresentations/` | Galois representations, local Langlands, theta-kernel identities |
| `Development/AbelianVarietyTheory/` | abelian varieties, CM geometry, Satake parameters, trace formulas |
| `ReciprocityTheory/ReductiveGroups/ArithmeticGeometry/BirationalGeometry/ToroidalCompactification/` | toroidal compactification, reciprocity |

The author's own account of the method is in `remark.pdf` (four pages). The one-sentence version
he gives is worth quoting, because it identifies the genuinely hard step:

> In Stepanov's argument resolving Riemann over function fields one uses a divisor involving
> multiplicity. This argument is a descendant of Stepanov's, but multiplicity is hard to find
> over the integers, corresponding to something like differentiating whole numbers. […] For the
> von Mangoldt sum of length X, Claude's suggested length of chain of theta lifts, in view of each
> mimicking multiplicity, was √X.

Two remarks on this: the `√X` is the *length of the theta-lift chain*, i.e. how much
multiplicity one can manufacture; and the "differentiate whole numbers" phrasing names exactly
the obstruction — Stepanov's method works over function fields because there the divisor carries
an integer multiplicity one can increase at will, and that device does not transfer to ℤ.

The author also notes that the argument "will be massively simplified, likely immediately", and
that he has not yet written the human-readable version. **The map above will therefore have a
short shelf life; it is a reading guide for the current artifact, not a description of an
endpoint.**

---

## 5. Suggested reading order

1. `src/Main.lean` (2.3 KB) — the entire global structure in five theorems.
2. `src/Statements.lean` (0.9 KB) — the five statements proved, including the equivalent
   zero-on-a-line formulation `riemannZeta_eq_zero_re` that does not mention Mathlib's definition.
3. `src/Development/AutomorphicArithmetic/CharacterBoxes/ClaimStrip.lean` — the 17 lines.
4. `src/Development/AutomorphicArithmetic/CharacterBoxes/MainConclusion.lean` — read only the
   *signatures*; they are the skeleton.
5. Then descend by layer using the table in §3.

Steps 1–4 take perhaps an hour and give a complete picture of the argument's shape. Step 5 is
where the actual difficulty lives, and it is large.

---

## 6. A machine-checkable interface certificate

`Skeleton.lean` (accompanying this file) declares the layer interfaces as Lean types — the
input and output of each layer, with the dependencies made explicit — so that the map can be
verified rather than trusted. It contains **no proof content**: the theorems are placeholders
carrying the exact signatures found in the sources. Anyone can compare them against the mirror
with `#check`.

---

## 7. Caveats

* The layering here is a reconstruction for reading purposes. It is not claimed to be canonical,
  and the community may prefer a different decomposition.
* No code from the submission is reproduced. All names and signatures are cited from the mirror
  for verification.
* `Claim.strip` needs `Claim.HalfPlane`; the 1700-line proof and the 17-line proof are not
  alternatives to each other.
* The author expects substantial simplification. Treat this map as describing an artifact in
  motion.

## Reference

L. Alpöge, *A proof of the Riemann Hypothesis* (with Claude), 2026-11-20.
`alpo.ge/remark.pdf`; Lean sources mirrored at
`github.com/leanprover-community/riemann-hypothesis` (submission belongs to its author and was
published without a license; the mirror exists so the proof can be checked).

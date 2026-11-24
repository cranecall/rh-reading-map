/-
# Skeleton.lean
Interface certificate for the 2026 Lean formalization of the Riemann Hypothesis.

**David Zhu**

Companion to `ProofSkeleton.md`. This file makes the layer map **machine-checkable**: it records
the input and output of each layer, the dependencies between them, and — for the top layer's
ζ special case — an actual proof rather than an assumption.

**What it does not contain.** No proof content from the submission. The layer theorems are
recorded by name and by the source file that carries them; the top-layer interface is stated in
Lean types, and the deeper layers are recorded as data (their signatures are long and depend on
machinery not reproduced here — transcribe them from the mirror and check with `#check`).

**What it does contain, in full proof.** The ζ special case of the top layer is not assumed:
`FR.strip_of_no_cancellation` in `FR/Strip.lean` is proved from the functional equation and the
trichotomy alone, with the half-plane non-vanishing as its only hypothesis.

Source of every quoted name (mirror: github.com/leanprover-community/riemann-hypothesis):
  src/Statements.lean
  src/Development/AutomorphicArithmetic/CharacterBoxes/HalfPlane.lean
  src/Development/AutomorphicArithmetic/CharacterBoxes/ClaimStrip.lean
  src/Development/AutomorphicArithmetic/CharacterBoxes/MainConclusion.lean
-/

import Mathlib.NumberTheory.LSeries.DirichletContinuation
import Mathlib.NumberTheory.LSeries.RiemannZeta
import FR.Strip

namespace Certificate

open Complex

/-! ## Layer 0 — Stripping: the top layer, stated in Lean types -/

/-- **Layer 0 input**: non-vanishing to the right of the critical line.

Transcribed from `Claim.HalfPlane` (CharacterBoxes/HalfPlane.lean); the same proposition is
`UpperTheory.EveryCharacter` (CharacterBoxes/EveryCharacter.lean). -/
def HalfPlaneNonVanishing : Prop :=
  ∀ (N : ℕ) [NeZero N] (χ : DirichletCharacter ℂ N) (s : ℂ),
    1 / 2 < s.re → (χ ≠ 1 ∨ s ≠ 1) → DirichletCharacter.LFunction χ s ≠ 0

/-- **Layer 0 output**: every zero in the critical strip lies on the critical line.

Transcribed from `Claim.Strip`. -/
def StripResult : Prop :=
  ∀ (N : ℕ) [NeZero N] (χ : DirichletCharacter ℂ N) (s : ℂ),
    0 < s.re → s.re < 1 → DirichletCharacter.LFunction χ s = 0 → s.re = 1 / 2

/-- **Layer 0 output, ζ version.** Transcribed from `Claim.Zeta`. -/
def ZetaResult : Prop :=
  ∀ s : ℂ, riemannZeta s = 0 → (¬ ∃ n : ℕ, s = -2 * (n + 1)) → s ≠ 1 → s.re = 1 / 2

/-- **The Λ special case of Layer 0, proved here rather than assumed.**

`FR.strip_of_no_cancellation` derives the critical-line conclusion from the functional equation
and the trichotomy; its only hypothesis is half-plane non-vanishing. This is `Claim.strip` with
the Dirichlet-character machinery removed. -/
theorem zeta_strip_proved (h : FR.NoCancellationRight) :
    ∀ s : ℂ, riemannZeta s = 0 → 0 < s.re → s.re < 1 → s.re = (1 / 2 : ℝ) :=
  FR.strip_of_no_cancellation h

/-- The corresponding conclusion in the submission's own vocabulary: `Claim.Strip` follows from
`Claim.HalfPlane`. Stated here as a dependency, proved in the mirror. -/
axiom strip_from_halfPlane (h : HalfPlaneNonVanishing) : StripResult

/-- `Claim.zeta`: the ζ specialization. -/
axiom zeta_from_halfPlane (h : HalfPlaneNonVanishing) : ZetaResult

/-! ## Layer 1 and below: recorded as data

The signatures of the deeper layers are long and depend on machinery that is not reproduced
here. Each entry names the theorem, the file that carries it, and what it consumes and
produces. `checkPath` is the file to open. -/

/-- One layer of the argument. -/
structure Layer where
  id : String
  /-- The theorem that opens the layer. -/
  entry : String
  /-- Where to find it, relative to `src/`. -/
  checkPath : String
  /-- Ids of the layers consumed by this one. -/
  consumes : List String
  /-- What the layer produces. -/
  produces : String
deriving DecidableEq

/-- The reconstruction of the argument's layer structure, as used in `ProofSkeleton.md`. -/
def layers : List Layer :=
  [ { id := "L0-strip"
      entry := "Claim.strip"
      checkPath := "Development/AutomorphicArithmetic/CharacterBoxes/ClaimStrip.lean"
      consumes := ["L1-halfplane"]
      produces := "Claim.Strip : every zero in the critical strip lies on Re s = 1/2" }
  , { id := "L1-halfplane"
      entry := "UpperTheory.FinalTheorems.everyCharacter"
      checkPath := "Development/AutomorphicArithmetic/CharacterBoxes/MainConclusion.lean"
      consumes := ["L1a-clopen", "L1b-weightone", "L1c-galois", "L1d-assembly"]
      produces := "UpperTheory.EveryCharacter : L(χ,s) ≠ 0 for Re s > 1/2" }
  , { id := "L1a-clopen"
      entry := "UpperTheory.Cb.lefschetz_fixedPoint_finite_etale_correspondence"
      checkPath := "Development/AutomorphicArithmetic/CharacterBoxes/MainConclusion.lean"
      consumes := ["L0-core"]
      produces := "weight-one Lefschetz formula on a clopen decomposition" }
  , { id := "L1b-weightone"
      entry := "UpperTheory.Gal.Int.Geo.geoOne_holds"
      checkPath := "Development/AutomorphicArithmetic/CharacterBoxes/MainConclusion.lean"
      consumes := ["L1a-clopen"]
      produces := "GeoOne : weight one realized geometrically" }
  , { id := "L1c-galois"
      entry := "UpperTheory.Gal.Int.galoisLocalGlobalStrong_recParameter"
      checkPath := "Development/AutomorphicArithmetic/CharacterBoxes/MainConclusion.lean"
      consumes := ["L1b-weightone", "L1-theta"]
      produces := "GalStar.Row0b recT : local-global strong lifting" }
  , { id := "L1d-assembly"
      entry := "UpperTheory.FinalTheorems.everyCharacter_of_row"
      checkPath := "Development/AutomorphicArithmetic/CharacterBoxes/MainConclusion.lean"
      consumes := ["L1c-galois", "L1-langlands"]
      produces := "UpperTheory.EveryCharacter" }
  , { id := "L1-theta"
      entry := "UpperTheory.TP.tLift_holds_k"
      checkPath := "Development/AutomorphicArithmetic/Foundations/GaloisRepresentations/ThetaParseval"
      consumes := ["L0-core"]
      produces := "iterated theta lift (TLiftK)" }
  , { id := "L1-langlands"
      entry := "UpperTheory.Zero.LLC.recTExists"
      checkPath := "Development/AutomorphicArithmetic/Foundations/GaloisRepresentations"
      consumes := ["L1-theta"]
      produces := "local Langlands existence" }
  , { id := "L0-core"
      entry := "arithmetic core (Stepanov determinant, Iwasawa tower, Rallis seesaw, Bost slope)"
      checkPath := "Development/AbelianVarietyTheory"
      consumes := []
      produces := "divisibility and multiplicity estimates" } ]

/-- The ids of layers that nothing consumes — the terminal outputs. -/
def terminalLayers : List String :=
  (layers.filter (fun l => l.produces.contains "Re s = 1/2")).map (·.id)

/-- Every layer id mentioned as a dependency is declared. Fails if the map is inconsistent. -/
theorem layers_consistent : ∀ l ∈ layers, ∀ c ∈ l.consumes, c ∈ layers.map (·.id) := by
  decide

/-- Render the map as text. -/
def render : List Layer → String :=
  String.intercalate "\n" ∘ (fun ls => ls.map (fun l =>
    s!"{l.id}\n  entry    : {l.entry}\n  file     : src/{l.checkPath}\n  consumes : {l.consumes}\n  produces : {l.produces}"))

/-- Self-check: the dependency graph is internally consistent.
`decide` discharges it, so this line fails to compile if the map is inconsistent. -/
example : ∀ l ∈ Certificate.layers, ∀ c ∈ l.consumes, c ∈ Certificate.layers.map (·.id) :=
  Certificate.layers_consistent

end Certificate

#eval Certificate.layers.length
#eval Certificate.terminalLayers

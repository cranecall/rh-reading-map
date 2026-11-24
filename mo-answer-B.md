There is a structural answer that is more reassuring than it first looks, and it comes from
separating three different things that the phrase "trusting the proof" runs together.

**1. What the kernel checked.** That the exported term has type `RiemannHypothesis` (Mathlib's
own definition), that it depends on no axioms beyond `propext`, `Quot.sound`,
`Classical.choice`, and that the statement is the one advertised. This is settled and is not
part of the residual trust.

**2. What can be lifted out and checked independently.** The reduction from "no zeros to the
right of `Re s = 1/2`" to "the zeros lie on `Re s = 1/2`" is short and standard — as Timothy Chow
put it in his answer to the companion question — and in the ζ case it is short enough to be
discharged in a standalone Lean file against Mathlib alone, with the same three axioms and
nothing else. I have written that file; it is about a dozen lines and I am happy to share it.
The same reduction for general Dirichlet `L`-functions needs two further elementary lemmas
(passing to the primitive character, and Euler factors not vanishing to the right of zero) and
is still short.

So the top of the argument is not a matter of trust at all: it is a matter of running Lean.

**3. Where the trust actually is, and what kind of trust it is.** Everything under the
zero-free region is ordinary, deep mathematics — the clopen decomposition and the weight-one
Lefschetz formula, the geometric realization of weight one, Galois representations built from
theta lifts, the local–global strong lifting, the assembly with local Langlands existence.
This is where the residual trust sits, and the honest description of it is: *trust these
several large steps of modern arithmetic geometry*, not *trust a black box*. Crucially, they
are not opaque: each has an entry point with a statement that can be read, and the pieces are
exactly the kind of thing that has been formalized before elsewhere in the literature. The
unusual part is that the development rebuilds a good deal of that infrastructure from scratch
rather than citing it, which is why it is large.

**What an adversarial author could do, and what stops it.** Two distinct attacks are worth
separating. Against the *machine* layer: the challenge-file and comparator setup means the
object of comparison is fixed in advance and independently specified, so a substituted statement
or an added axiom is caught mechanically rather than by reading. Against the *mathematical*
layer: this is where a determined adversary could hide something, and the honest answer is that
no formal method rules it out. What formalisation does is make the hiding place explicit and
finite — a list of named theorems — rather than leaving it spread over 175,000 files of
prose-shaped code.

**A concrete suggestion.** If one wanted to make the residual trust as small as possible, the
most effective step would be to publish, alongside the development, a layer map with each
layer's entry theorem, its signature, and the files that implement it, plus a machine-checkable
interface certificate. That does not verify any new mathematics, but it converts "trust the
artifact" into "audit these seven statements", and it makes the expensive part of the work —
reading — navigable. There is already movement in this direction: the compression effort
currently working on the development, and the independent zero-free-region work being carried
out on the same proof.

— David Zhu

*Files: `ProofSkeleton.md` (the layer map) and `Skeleton.lean` (the machine-checkable interface
certificate; the two theorems above are imported into it and compile) are published at
<https://rh-proof-map.app.workbuddy.host/?sharecode=PV6OPU5DQ4>, together with one-click copy buttons for this answer and for the companion
answer to the other question. The Lean file can be compiled directly against Mathlib and
Lean 4.33.1.*

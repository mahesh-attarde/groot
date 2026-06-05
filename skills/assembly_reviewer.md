# Assembly Comparison Skill

## Purpose

This skill helps compare two x86 assembly files across multiple dimensions, with emphasis on:

- **Correctness**
- **Performance**
- **Calling convention compliance**
- **ABI and platform expectations**
- **Safety and robustness**
- **Readability and maintainability**
- **Compiler/codegen quality indicators**

The goal is not only to identify whether two assembly files are "the same", but whether they are functionally equivalent, whether one is better, and what tradeoffs exist.

---

## Scope

Use this skill when asked to compare two **x86-family assembly files**, including:

- x86 (32-bit)
- x86-64 / AMD64
- Intel syntax
- AT&T syntax

Supported comparison scenarios include:

- hand-written assembly vs hand-written assembly
- compiler-generated assembly vs compiler-generated assembly
- baseline vs optimized version
- old vs new implementation
- different compiler outputs for the same source
- different optimization levels
- different platforms or ABI targets, where relevant

---

## Primary Objectives

When comparing two assembly files, evaluate the following in order:

1. **Functional correctness**
2. **Control-flow equivalence**
3. **Data-flow and state effects**
4. **ABI / calling convention correctness**
5. **Performance characteristics**
6. **Microarchitectural considerations**
7. **Code size**
8. **Maintainability / clarity**
9. **Risk of latent bugs or undefined behavior assumptions**

---

## Comparison Method

### 1. Establish context first

Before comparing instructions, identify:

- target architecture: x86 or x86-64
- syntax style: Intel or AT&T
- platform / ABI:
  - System V AMD64
  - Windows x64
  - cdecl / stdcall / fastcall / thiscall
  - custom calling convention
- whether code is:
  - leaf function
  - non-leaf function
  - interrupt/exception stub
  - syscall wrapper
  - inline assembly fragment
  - compiler-generated function body
- presence of:
  - PIC/PIE conventions
  - stack canaries
  - unwind info patterns
  - prologue/epilogue conventions
  - vector/SIMD usage
  - privileged instructions

If context is missing, state assumptions clearly.

---

### 2. Compare for correctness first

Never start with performance conclusions before validating correctness.

Check:

- same inputs consumed?
- same outputs produced?
- same memory side effects?
- same register side effects?
- same flags behavior, if flags are live across boundaries?
- same exception/fault behavior where relevant?
- same ordering constraints for memory-visible operations?
- same handling of edge cases?

Validate:

- control-flow structure
- condition checks
- loop bounds
- signed vs unsigned comparisons
- width correctness (8/16/32/64-bit)
- extension semantics:
  - sign extension
  - zero extension
- carry/borrow propagation
- overflow-sensitive logic
- shift semantics
- division preconditions
- pointer arithmetic
- stack balance

Important: Two assembly files can look different and still be equivalent. Focus on semantic equivalence, not textual similarity.

---

### 3. Compare ABI / calling convention behavior

Verify:

- argument registers/stack slots are used correctly
- return value registers are correct
- callee-saved registers are preserved
- caller-saved registers are treated appropriately
- stack alignment is respected at call sites
- shadow space (Windows x64) is handled when required
- red zone usage (SysV) is legal and safe
- variadic function requirements are respected
- struct return conventions are followed
- vector register preservation rules are respected where applicable

Flag any mismatch as a correctness issue, not a style issue.

---

### 4. Compare stack discipline

Inspect:

- prologue / epilogue correctness
- frame pointer usage vs omission
- dynamic stack allocation
- stack alignment before calls
- push/pop symmetry
- local variable layout assumptions
- stack slot reuse
- stack probing on Windows if large allocations are present
- possible stack corruption risks
- tail-call eligibility and correctness

Watch carefully for:

- missing stack restoration
- mismatched push/pop counts
- incorrect `ret N`
- clobbering return address-adjacent memory
- uninitialized stack reads

---

### 5. Compare flags and condition-code usage

x86 code often depends subtly on flags.

Check:

- which instructions define flags
- whether later instructions consume the intended flags
- whether an instruction unexpectedly clobbers flags between compare and branch
- use of:
  - `cmp`
  - `test`
  - arithmetic flag setting
  - `lea` to avoid flag changes
  - `inc`/`dec` differences from `add`/`sub`
- signed vs unsigned jump conditions:
  - `jg/jl/jge/jle`
  - `ja/jb/jae/jbe`

Common correctness traps:

- replacing `add/sub` with `inc/dec` when carry behavior matters
- using signed jumps for unsigned data
- using stale flags
- not accounting for `mul/imul/div/idiv` behavior

---

### 6. Compare memory behavior

Evaluate:

- load/store count
- memory access width
- alignment assumptions
- aliasing sensitivity
- use of stack vs registers
- unnecessary spills/reloads
- memory ordering semantics if synchronization is involved
- atomic operations and lock prefixes
- RIP-relative vs absolute addressing
- addressing-mode efficiency

Check for correctness and performance:

- out-of-bounds risks
- wrong operand width
- partial initialization
- torn accesses
- unnecessary memory traffic

---

### 7. Compare performance

After correctness is established, compare likely performance.

Consider:

- instruction count
- critical path length
- dependency chains
- instruction-level parallelism
- branch predictability
- number of branches
- branchless alternatives
- load-to-use latency
- store forwarding hazards
- register pressure
- spills/reloads
- use of expensive instructions
- code size and I-cache footprint
- macro-fusion opportunities
- micro-fusion / addressing complexity
- port pressure
- latency vs throughput tradeoffs
- loop structure efficiency
- unrolling
- vectorization / SIMD opportunities

Important: Avoid overclaiming exact speedups unless benchmark data exists. Prefer wording like:

- "likely faster on modern x86-64"
- "may reduce branch mispredict risk"
- "likely improves throughput but may increase code size"
- "could hurt latency due to a longer dependency chain"

---

### 8. Look for x86-specific performance patterns

Pay attention to:

#### Beneficial patterns
- `xor reg, reg` zeroing
- `test reg, reg` for zero checks
- `lea` for arithmetic that avoids flag clobbering
- register reuse that avoids spills
- fused compare-and-branch patterns
- efficient addressing modes
- tail calls where appropriate

#### Potentially problematic patterns
- partial-register stalls or mixing widths poorly
- high-latency `div/idiv`
- unnecessary serial dependencies
- overuse of `push/pop` in hot paths
- excessive stack traffic
- poorly predicted branches
- misaligned stack before calls
- slow instructions used where simpler ones suffice
- unnecessary `mov` chains
- false dependencies
- use of `loop` instruction in performance-sensitive code
- suboptimal zero/sign extension sequences

For older-vs-newer CPU tradeoffs, mention that behavior can vary by microarchitecture.

---

### 9. Compare code size and layout

Evaluate:

- total instruction bytes
- padding and alignment
- hot-path density
- jump distances / short vs near jumps
- duplicated blocks
- inline constants
- impact on I-cache and uop cache friendliness

Smaller is not always faster. Note size/performance tradeoffs explicitly.

---

### 10. Compare maintainability and auditability

Even low-level code should be judged on clarity.

Assess:

- clarity of control flow
- consistency in register roles
- comments and labels
- obviousness of invariants
- ease of verifying correctness
- susceptibility to future modification bugs
- whether clever tricks obscure intent

Prefer code that is easier to audit when performance is similar.

---

## Additional Dimensions to Consider

Depending on context, also compare:

### Security
- constant-time behavior for secret-dependent logic
- speculative execution concerns where relevant
- bounds-check robustness
- ROP/JOP surface implications
- misuse of privileged or unsafe instructions

### Portability
- ABI dependence
- assembler compatibility
- CPU feature assumptions
- vendor-specific instruction behavior
- 32-bit vs 64-bit assumptions

### Debuggability
- stable frame usage
- symbolic clarity
- unwind friendliness
- compatibility with profilers and debuggers

### Toolchain friendliness
- assembler acceptance
- linker behavior
- relocation model compatibility
- inline assembly constraints if embedded in C/C++

---

## Required Output Structure

When presenting a comparison, use this structure:

### Summary
Provide a short verdict:
- are they functionally equivalent?
- which one is likely faster?
- which one is safer or clearer?
- any blocking correctness issue?

### Assumptions
State any assumptions:
- target ABI
- syntax
- platform
- whether code is hot-path or not
- whether semantic equivalence is inferred rather than proven

### Correctness Comparison
List:
- equivalent behavior
- confirmed mismatches
- suspicious differences
- edge cases

### ABI / Calling Convention Review
List any preservation, alignment, argument, or return-value issues.

### Performance Comparison
Explain expected differences in:
- branch behavior
- memory traffic
- dependency chains
- instruction count
- code size
- likely throughput/latency impact

### Risks
Call out:
- subtle flag issues
- stack risks
- signed/unsigned mistakes
- width-extension bugs
- architecture-dependent assumptions

### Final Verdict
Give a concise final recommendation:
- prefer A
- prefer B
- equivalent but A is clearer
- B is faster but riskier
- not equivalent; fix correctness first

---

## Comparison Heuristics

Use these heuristics:

- Treat correctness bugs as highest priority.
- Treat ABI violations as correctness bugs.
- Treat suspicious flag usage as high-risk even if not conclusively wrong.
- Prefer simpler control flow when performance is similar.
- Prefer fewer memory accesses in hot code.
- Prefer fewer unpredictable branches.
- Be cautious with "clever" sequences unless their benefit is clear.
- Distinguish measured performance from inferred performance.
- If exact equivalence cannot be proven, say so clearly.

---

## Common x86 Pitfalls Checklist

Check for all of the following:

- wrong signed/unsigned jump
- missing sign extension before division
- wrong zero/sign extension width
- stale flags usage
- clobbered callee-saved registers
- broken stack alignment
- bad shadow space handling
- illegal red zone assumptions
- mismatched operand sizes
- partial-register hazards
- off-by-one loop termination
- incorrect carry propagation
- misuse of `lea`
- accidental flag clobbering
- unnecessary spills
- unbalanced stack
- incorrect tail call transformation
- hidden memory aliasing issues
- unsafe assumptions about alignment

---

## Guidance for Tone and Rigor

When comparing assembly:

- be precise
- avoid hand-wavy claims
- separate facts from likely interpretations
- call out assumptions explicitly
- quote specific instructions or blocks when making claims
- do not claim performance certainty without measurement
- do not declare equivalence casually if flags, memory ordering, or ABI details are unclear

Good phrasing examples:

- "These appear functionally equivalent under SysV x86-64 assuming flags are not observed after return."
- "Version B likely performs better by reducing memory traffic and shortening the hot-path branch sequence."
- "Version A is easier to audit, while Version B is more optimized but introduces higher correctness risk."
- "This change is not equivalent because the signed comparison in B changes behavior for values >= 2^31."

---

## If the Comparison Is Incomplete

If symbols, calling context, or surrounding code are missing:

- say what cannot be determined
- identify the exact missing context
- give a provisional comparison
- avoid false certainty

Examples of missing context:
- surrounding caller/callee expectations
- whether flags are live-out
- whether alignment is guaranteed
- whether the code is performance-critical
- target OS / ABI

---

## Final Rule
If there is any tension between performance and correctness, always prioritize correctness.
A faster assembly implementation that is not provably correct is worse than a slower correct one.

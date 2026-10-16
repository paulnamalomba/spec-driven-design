---
name: low-level-systems
description: Use this skill when designing, architecting, or reviewing systems programming, embedded systems, high-performance computing (HPC) kernels, or any architecture involving manual memory management, OS/kernel interfaces, hardware symbiosis, or strict latency/determinism guarantees. Applies mechanical sympathy and systems engineering rigor to specifications, designs, and implementations.
version: 0.2.0
---

# Low-Level Systems Engineering

## When to Apply
Trigger this skill when the system or component involves:
* **Manual Memory Management & Custom Allocators:** Arenas, pools, slab allocators, buddy systems, or zero-allocation paths.
* **Performance-Critical Hot Paths:** HPC numerical kernels, high-frequency trading paths, real-time audio/video processing, or tight inner loops.
* **Direct OS/Kernel Interfaces:** Raw syscalls, `io_uring`, `epoll`/`kqueue`, `mmap`, custom drivers, eBPF, or page table manipulation.
* **Embedded & Resource-Constrained Environments:** Bare-metal (`no_std`), RTOS, strict SRAM/Flash budgets, or MMU-less targets.
* **FFI Boundaries & ABI Stability:** C-ABI bindings, shared libraries (`.so`/`.dll`), cross-language zero-copy IPC, or dynamic plugin architectures.
* **Lock-Free & Wait-Free Concurrency:** Atomics, memory ordering barriers, hazard pointers, RCU (Read-Copy-Update), or single-producer/single-consumer (SPSC) ring buffers.
* **Data-Oriented & Vectorized Execution:** Explicit SIMD (AVX-512, NEON), cache-oblivious algorithms, or Structure-of-Arrays (SoA) transformations.

---

## Core Mindset: Mechanical Sympathy
Low-level systems engineers do not design for abstract virtual machines; they design for the physical silicon, the memory hierarchy, and the operating system scheduler. Abstractions are never zero-cost until proven via assembly and hardware performance counters.

### Questions to Always Ask
1. **Memory Layout & Hierarchy:** What is the exact byte layout, size, and alignment of this struct? How many fields fit into a single 64-byte cache line? Will this access pattern trigger the hardware prefetcher, or will it stall the pipeline waiting on main memory (~200+ cycles)?
2. **Ownership & Lifetimes:** Who owns this allocation? Is the lifetime statically provable, tied to a lexical scope, or bound to a specific arena phase? What is the exact deallocation trigger?
3. **Tail Latency & Jitter:** What is the $p99.99$ and worst-case execution time (WCET), not the average? What happens when the TLB misses, the page isn't faulted in, or the branch predictor guesses wrong?
4. **Execution Context & Blocking:** Can this code path block, yield, fault, or trigger a context switch? Is it executing in an interrupt service routine (ISR), a real-time thread, or an async executor where blocking starves the core?
5. **Failure & Exhaustion Modes:** What happens when `malloc` returns `NULL`, the ring buffer is full, or a syscall returns `EINTR`/`EAGAIN`? Is backpressure explicit?
6. **Determinism & Preemption:** Are all loops, queues, and recursion statically bounded? Can priority inversion occur?
7. **Compiler & Hardware Ordering:** Can the compiler reorder these loads/stores across this boundary? Can the CPU store buffer delay visibility to other cores? Could tearing occur on unaligned or wider-than-word accesses?

### Assumptions to Challenge
* *"Memory is abundant and flat"* — False. Memory is a steep hierarchy of registers, L1/L2/L3 caches, TLB entries, and NUMA nodes. A pointer dereference across NUMA nodes is an order of magnitude slower than an L1 hit.
* *"Allocation is cheap"* — False. General-purpose heap allocators contend on locks, fragment address space, thrash caches, and have non-deterministic latency.
* *"The compiler will optimize/vectorize it"* — Trust nothing; verify everything. Pointer aliasing, subtle loop-carried dependencies, or missing `restrict`/`noalias` keywords routinely defeat auto-vectorization. Read the emitted assembly (`objdump`, Compiler Explorer).
* *"It's fast enough"* — Unmeasured code is slow code. Profile using hardware performance counters (`perf`, VTune, Instruments) to measure IPC (Instructions Per Cycle), L1/LLC cache misses, TLB flushes, and branch mispredictions.
* *"Order follows source code"* — Neither optimizing compilers nor out-of-order superscalar CPUs respect source order without explicit compiler barriers and hardware memory fences.
* *"Types are purely logical"* — Types dictate byte size, struct padding, alignment requirements, register allocation (System V vs. Win64 ABI), and strict aliasing rules.

---

## Engineering Practices

### 1. Memory Ownership & Lifetimes
* **Do:** Enforce a single, unambiguous owner for every allocation. Document ownership transfers in function signatures and API contracts. Use RAII (C++/Rust) or `defer`/`errdefer` (Zig/Go/C cleanup attributes) to guarantee deterministic teardown. Tie object lifetimes to bulk execution phases rather than managing individual object lifecycles.
* **Don't:** Allocate without a pre-defined deallocation site, rely on tracing garbage collection or reference-counting (`shared_ptr`/`Arc`) in hot paths (atomic ref-count increments cause cache-line bouncing), or leave pointer ownership ambiguous across API boundaries.

### 2. Allocation Strategy
* **Do:** Default to stack allocation for small, fixed-size data with lexical lifetimes. Use linear/bump arenas for phase-based or request-scoped lifetimes, and fixed-block pools or slab allocators for uniform objects. Pre-allocate all memory during initialization (`init` phase) and lock pages into physical RAM (`mlock` / hugepages) for latency-critical systems.
* **Don't:** Invoke `malloc`/`free` or `new`/`delete` inside hot loops, use unbounded dynamic containers (`std::vector` without `reserve`) in real-time contexts, or abort on OOM inside reusable systems libraries.

### 3. Cache Sympathy & Data-Oriented Design
* **Do:** Keep hot data contiguous and compact. Separate frequently accessed fields ("hot") from rarely accessed metadata ("cold") into distinct structs. Prefer Structure-of-Arrays (SoA) over Array-of-Structures (AoS) when iterating over specific fields across large datasets to maximize SIMD utilization and cache-line density. Order struct fields by descending alignment size to eliminate implicit padding bytes. Pad and align concurrent atomics or per-thread state to cache-line boundaries (`alignas(64)` or `128` on Apple Silicon/modern prefetchers) to eliminate false sharing.
* **Don't:** Chase pointers through heap-allocated node graphs (`std::list`, `std::map`, pointer-heavy ASTs) in traversal-heavy workloads, mix read-mostly configuration data with high-frequency atomic counters on the same cache line, or ignore TLB pressure on gigabyte-scale working sets.

### 4. Determinism & Real-Time Execution
* **Do:** Statically bound all loops (NASA Power of 10 rule). Replace recursion with explicit, bounded iterative state machines. Document and verify Worst-Case Execution Time (WCET). Use fixed-size ring buffers with explicit overflow policies (drop-oldest, drop-newest, or backpressure). Pin critical threads to isolated CPU cores (`isolcpus`, thread affinity) to prevent scheduler migration and cache invalidation.
* **Don't:** Perform unbounded scans, trigger page faults on critical paths, invoke syscalls that may sleep in real-time threads, or ignore priority inversion in mutex-protected sections (use priority inheritance protocols where locks are unavoidable).

### 5. Unsafe Boundaries & Hardware Sympathy
* **Do:** Quarantine `unsafe` blocks, raw pointer arithmetic, inline assembly, and MMIO (Memory-Mapped I/O) into minimal, heavily audited leaf modules. Expose safe, strongly-typed wrappers to the rest of the codebase. Explicitly document every precondition and invariant (`// SAFETY: ...`). Validate all external lengths, offsets, and alignments before casting raw byte buffers. Use `volatile` (or explicit volatile load/store intrinsics) strictly for MMIO and signal handlers—never for inter-thread synchronization.
* **Don't:** Scatter raw pointer manipulation across business logic, violate strict aliasing rules (use `memcpy` or `bit_cast` for type punning, never raw pointer casts in C/C++), allow signed integer overflow, or trust unvalidated inputs across privilege or FFI boundaries.

### 6. ABI Stability & FFI Hygiene
* **Do:** Explicitly specify representation (`#[repr(C)]`, `extern "C"`) and fixed-width integer types (`uint32_t`, `size_t`) at all public boundaries. Freeze public struct layouts or hide internal representations behind opaque pointers (`struct ctx;`). Pass explicit context pointers rather than relying on global/thread-local state. Version interfaces via size-tagged structs or explicit vtables. Ensure resources allocated on one side of an FFI boundary are freed on the exact same side (or pass explicit allocator vtables).
* **Don't:** Expose language-specific types (C++ STL containers, Rust slices/fat pointers, exceptions) across FFI boundaries, alter field order or enum underlying types in stable APIs, or assume default struct packing (`#pragma pack`) matches across compilers and architectures without static assertions (`static_assert(sizeof(...) == ...)`).

### 7. Exhaustive Error & Fault Handling
* **Do:** Treat failure as a primary control-flow path. Use explicit error return values (`Result<T, E>`, `errno`, status enums) with zero-cost happy paths. Handle transient OS interrupts (`EINTR`, `EAGAIN`, partial reads/writes) in deterministic retry loops. Provide transactional rollback or clean teardown on partial initialization failure (`goto cleanup` in C, `errdefer` in Zig, RAII in C++/Rust).
* **Don't:** Swallow return codes, use stack-unwinding exceptions in systems/kernel code or across FFI boundaries, panic/abort on recoverable resource exhaustion, or leave data structures in half-mutated states upon error.

### 8. Concurrency, Atomics & Memory Ordering
* **Do:** Prefer shared-nothing architectures, thread-per-core pinning, and lock-free SPSC queues over shared mutable state. When using atomics, use the weakest memory ordering that guarantees correctness (`Relaxed` for pure counters, `Acquire`/`Release` pairs for publication/subscription, `SeqCst` only when total global ordering across multiple variables is strictly required). Document the exact happens-before relationship for every atomic operation. Keep critical sections microscopic.
* **Don't:** Sprinkle `SeqCst` everywhere as a substitute for understanding memory models, hold locks across I/O or syscalls, spin-wait without backoff/pause instructions (`_mm_pause()`, `yield`), or suffer from ABA problems in lock-free pointer manipulation.

### 9. I/O & Syscall Minimization
* **Do:** Amortize kernel context-switch overhead (and Spectre/Meltdown mitigation penalties) by batching I/O operations (`writev`/`readv`, `recvmmsg`, `io_uring`). Prefer asynchronous, completion-based or readiness-based event loops over thread-per-connection models. Utilize zero-copy primitives (`mmap`, `sendfile`, `splice`, DMA buffers) to avoid redundant kernel-to-userspace buffer copies.
* **Don't:** Issue byte-by-byte or unbuffered syscalls in loops, copy payloads multiple times across abstraction layers, or perform synchronous disk/network I/O on compute threads.

---

## Precision Vocabulary
Eliminate vague terminology in specifications, comments, and reviews. State exact mechanical constraints:

| Instead of... | Say... |
| :--- | :--- |
| **"fast"** | `O(1) amortized`, `less than 50 cycles`, `L1-cache resident`, `branchless`, `SIMD-vectorized` |
| **"slow"** | `pointer-chasing`, `LLC cache miss bound`, `causes TLB thrashing`, `triggers syscall context switch` |
| **"memory safe"** | `free of Undefined Behavior (UB)`, `statically lifetime-checked`, `bounds-checked`, `no use-after-free` |
| **"thread safe"** | `wait-free`, `lock-free (CAS loop)`, `Acquire/Release synchronized`, `immutable`, `thread-local` |
| **"efficient"** | `zero-copy`, `in-place mutation`, `arena-allocated`, `zero heap allocations on hot path` |
| **"pointer"** | `owning pointer`, `non-null borrowed reference`, `unaligned raw pointer`, `opaque handle`, `restricted pointer (noalias)` |
| **"call"** | `inlined function`, `virtual dispatch (vtable lookup)`, `blocking syscall`, `non-blocking FFI call` |
| **"small/compact"** | `fits in a single 64B cache line`, `register-sized (16 bytes)`, `zero padding bytes`, `bit-packed` |

---

## SDD (Specification-Driven Development) Integration

### 1. During Specification
* **Quantify Resource Envelopes:** Reject vague NFRs like "low memory usage" or "low latency." Demand explicit budgets: maximum resident set size (RSS), stack depth limits (e.g., max 16 KB stack), and latency percentiles ($p50$, $p99$, $p99.99$ in microseconds/nanoseconds).
* **Define Target Architecture:** Specify exact target ISAs (`x86_64-v3`, `aarch64`, `riscv32imac`), endianness, word size, cache line size, page size (4 KB vs. 2 MB hugepages), and OS/kernel minimums.
* **Bound Everything:** Flag any requirement that implies unbounded queues, arbitrary input sizes, or dynamic scaling without hard ceilings and explicit backpressure/load-shedding semantics.
* **Specify Fault Semantics:** Define exact system behavior under OOM, disk full, corrupted frames, hardware peripheral timeout, or sudden power loss.

### 2. During Design
* **Map the Memory Architecture:** Document the exact ownership graph and allocation strategy (Static, Stack, Arena, Slab Pool, Heap) for every subsystem. Prove that hot paths perform zero dynamic allocations.
* **Design Data Layouts First:** Define the core structs, their `sizeof`, `alignof`, and field ordering before writing interfaces. Justify AoS vs. SoA choices based on access patterns.
* **Establish Concurrency & Execution Models:** Map out thread topologies, core affinity, lock hierarchies (to prevent deadlocks), or lock-free state machines. Specify exact buffer capacities and synchronization primitives between threads/ISRs.
* **Freeze ABI & Boundary Contracts:** Define C-compatible headers or interface definitions, ownership transfer rules across boundaries, alignment preconditions, and error-code mappings.

### 3. During Implementation & Code Review
* **Audit Memory & Lifetimes:** Verify every allocation has a deterministic free path on all control-flow branches (including early error returns). Ensure no dangling pointers, uninitialized reads, or stack-frame escapes exist.
* **Inspect Hot Paths:** Verify zero hidden allocations (e.g., implicit string copies, closure captures, dynamic trait/interface boxing), zero unnecessary branches, and contiguous memory traversal in inner loops.
* **Verify Unsafe & Concurrency Correctness:** Confirm all `unsafe` blocks have `// SAFETY:` proofs. Check atomic operations for proper memory ordering and false sharing. Verify integer arithmetic cannot silently overflow/wrap when computing buffer sizes (`calloc`-style overflow checks).
* **Validate Alignment & Packing:** Ensure no unaligned pointer casts exist and that structs crossing hardware/network/FFI boundaries use explicit endianness conversions and static size assertions.
* **Confirm Exhaustive Error Handling:** Check that every syscall, allocator call, and FFI invocation has its return status checked and propagated cleanly without leaking resources.
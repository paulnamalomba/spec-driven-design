# SESKA FEA Suite Profile

Load this profile only when the target is `seskafeasuite` (frontend `SESKAFEMEditor`). Grounding was inspected read-only on 2026-10-16. Re-check cited SESKA files before relying on a fact; the frontend had no code at that date. Full evidence and primary-source citations: [research-ux-enrichment-2026-10-16.md](research-ux-enrichment-2026-10-16.md).

"research §N" means a section of that research file. "architecture" means `docs/architecture/SYSTEM_ARCHITECTURE_AND_DESIGN.md`; "spec" means `docs/spec/SESKAFEA_SPEC_DOCUMENT.md`; G-numbers are gaps tracked there.

## 1. Grounding (what actually exists)

| Area | Finding | Source |
| --- | --- | --- |
| Frontend code | **None.** `frontend/` holds only `AGENTS.md`, README (one line), and instruction stubs. It "currently contains scaffolding, not a verified application or build." | `seskafeasuite/frontend/AGENTS.md`, `frontend/README.md` |
| Specified stack | C++20/23, CMake, **GLFW + NVIDIA NVRHI on Vulkan** (MoltenVK on macOS), GLM, **Dear ImGui docking branch**, **ImPlot**, Im3d *or* a GPU-instanced glyph pipeline, embedded Lua. ImGuizmo is **not** named. | `docs/spec/SESKAFEA_SPEC_DOCUMENT.md` §Tech Stack |
| Targets | `libSESKAFEMCore` (no ImGui/GLFW/Vulkan/Lua in its headers), `SESKAFEMEditor`, `SESKAFEMBatch` (always links Lua). Every client mutates the model only through the core command dispatcher. | spec §Target Topology; root `AGENTS.md` §Architecture guardrails |
| ImGui backend | Dear ImGui ships no NVRHI renderer. A custom ImGui→NVRHI renderer is proposed (gap G14). **Docking inside the primary window first**; detached OS windows (multi-viewport) deferred until DPI/resize/texture-lifetime tests pass. | `docs/architecture/SYSTEM_ARCHITECTURE_AND_DESIGN.md` §Workstation backend integration |
| macOS | NVRHI on MoltenVK is an unproven release gate (G13). | architecture §macOS compatibility gate |
| Engine | SESKA (C++/Fortran, PETSc, MPI; MUMPS on one rank, SuperLU_DIST on several when `directSolver 3`). It reads literal `input.dat`/`mesh.dat` from the CWD. Accepted build: Windows debug **1.0.0.19**. | `backend/README.md`; `docs/architecture/RESEARCH_SESKA_CASES_AND_RUNTIME.md` §1, §4 |
| Managed launcher | `seska-run --case DIR --output NEW_DIR [--ranks N] [--mpi PATH] [--timeout S] [--cancel-file PATH]`, plus `--reconcile`, `--validate`. Exit codes: 0 completed, 1 invalid invocation, 2 failed, 3 timeout, 4 cancelled, 5 unresolved reconciliation. Cancel by creating `cancel.request`. Writes `run.json`. | `backend/README.md` §Headless runs; `backend/src/seskaIntegration/SeskaRun.cpp` lines 151–211 |
| Output admission | Native admission currently covers **linear hexahedra with volume quadrature order 2** and 3D scalar/vector/symmetric-tensor fields only. | `backend/README.md` §Headless runs |
| Element types | `mesh.dat` element type 1 = tetrahedron, 2 = hexahedron. Order 0/1/2 gives TET1/TET4/**TET10** and HEX1/HEX8/**HEX27**. **The element type must be uniform across the mesh** (mixed meshes are rejected with `MPI_Abort`). The spec lists HEX20, but the engine has HEX27, not HEX20. | `backend/seska/src/common/commonFunctions.C` `getFEMMeshData` (~L2321); `src/preProcessing/FEMGeometry/FEMGeometry.C` ~L255–322 |
| Discretisation | SESKA is a particle/meshfree-capable code (`shapefunctionType`, MLS/EFG shape functions; FEM is type 7). Nodes are "particles" internally. | `RESEARCH_SESKA_CASES_AND_RUNTIME.md` §5.1; `src/preProcessing/MLSDiscretising.C` |
| Analysis families (supplied cases) | FE², TPM (porous media), cardiac mechanics, classical elasticity, Cosserat, cyclic loading, dynamics, elastoplasticity, hyperelasticity, damage, micromorphic, composites, phase-field, stress smoothing, variable modulus, viscoelasticity. | `RESEARCH_SESKA_CASES_AND_RUNTIME.md` §2 |
| Loads/BCs | Constraints and loads bind to explicit **surface element IDs** (e.g. faces 41–44 constrain DOFs 1–3; faces 65–68 `Traction-Loading` DOF 3), not a proven named-set grammar. Input IDs are 1-based while log IDs are 0-based. | architecture §Observations from the supplied case |
| Outputs | GiD-format `fem.msh`/`fem.res` (precision 12; `OnNodes`, Gauss-point sets; stress `S_11…S_31`), `load_deformation-node<N>-DOF<D>.grf`, `log<rank>.dat` (opened by both C++ and Fortran), `point.res`. The default nodal FEM stress is MLS-interpolated from Gauss points. | `RESEARCH_SESKA_CASES_AND_RUNTIME.md` §5.1–5.2, §6.2 |
| Convergence log | Per `SIMULATION STEP n`: `iteration step k`, linear-solver lines (`Solver: direct solver (MUMPS)`, `solving equation system has converged after N solver iterations.`), `number of global yielded Gauss points = …`, `convergence norm = …`, `simulation-output ID=n`. Example sequence: 1 → 2.4e-4 → 5.5e-8 → 6.4e-12. | `backend/seska/examples/variable-modulus-examples/cantileverBeam.gid/log0.dat` L1274–5860 |
| Convergence norm | `convergence norm` = `residualNorm / refResidualNorm` (reference = iteration-0 residual). It falls back to the absolute norm when the reference is below `DBL_EPSILON` after iteration 0. Norm type 1 is a plain *sum* (not an absolute sum), 2 is L2, 3 is max-abs. | `src/equationSystem/CommonEQSet.C` L505–535; `src/common/commonFunctions.C` `computeNorm` ~L2066; `src/simulation/Simulation.C` L828–848 |
| KSP handling | `checkPETScConvergence` takes `MPI_MIN` of `KSPConvergedReason` across ranks. It returns failure only for reasons < 1 other than −3. **`KSP_DIVERGED_ITS` (−3) is treated as success** and logged as "hasn't converged". | `src/common/PETScFunctions.C` L795–880 |
| Exit status caveat | Some divergence paths historically set `simulationCompleted` and returned 0. The current native build "reports nonzero status after ordinary divergence shutdown". Cancellation has no in-engine handler, so `seska-run` provides it. Restart is not established. | `RESEARCH_SESKA_CASES_AND_RUNTIME.md` §6; `backend/README.md` |
| Result science | Gauss, centroid and nodal-average values are distinct products. Tensor measure and frame must be verified per law (e.g. Green/2nd-PK law vs `trueStressPlotting`). The deformation display is $\mathbf X_0+\alpha\mathbf u$, presentation only. Interpolated animation frames must not look like solver steps. | architecture §Result model and scientific correctness |
| Usability requirements already written | "Keyboard access to common commands, readable focus and selection states, adjustable UI/font scale, and non-color cues for constraints and run status." No accessibility conformance claimed. | architecture §Engineering rendering and user interpretation |
| Current pre/post | Historically GiD (`backend/seska/seska.gid/` problem type: `.bas/.cnd/.mat/.prb/.tcl`). The target is to remove GiD as a required intermediary (G18). | architecture §Removing the GiD dependency |

### Gaps between the skill's assumptions and SESKA

1. The skill's six-stage pipeline assumes geometry/CAD and meshing. SESKA has no mesher yet (G18). The first milestone is **import** of `mesh.dat`/`input.dat`.
2. The skill assumes named `NSET`/`ELSET`/`SURF` sets. SESKA binds to explicit surface element IDs. Named sets are a workbench concept that must compile down to engine IDs through a reversible map.
3. The skill assumes mixed meshes and generic "Element/Volume" picking. SESKA meshes have a single element type (TET or HEX, order 1 or 2).
4. The skill assumes SNES and `-ksp_monitor` telemetry. SESKA writes its own log lines and uses KSP only for the inner solve. Live telemetry must parse `log<rank>.dat`, and parsing it is not a completion protocol (G11).
5. The skill assumes Gauss-point output is available. SESKA's integration-point plotting can be disabled per case. The default nodal stress is MLS-recovered by the engine, not by the workbench.
6. The skill assumes ImGuizmo. The spec names Im3d or custom glyphs. Either add ImGuizmo explicitly, with its license and IP note, or keep the view cube custom.
7. The skill assumes multi-viewport floating panels are fine. SESKA defers them.
8. The skill's PowerShell/ConPTY terminal is allowed only as a convenience. It never runs managed jobs.

## 2. UX planning checklist

Each item cites its SESKA source. Mark design statements Required, Proposed, Observed or Engine-dependent, as the root `AGENTS.md` requires.

**Scope and contracts**

- [ ] The first milestone is **import → validate → run via `seska-run` → admit results** of a supplied case, not geometry or meshing (architecture §Executive summary; G18).
- [ ] Only show the field catalogue entries that passed their contract gate: displacement, Cauchy stress, von Mises, pressure, log strain. Mark others "awaiting contract" (architecture §Field metadata, G06).
- [ ] Element support UI matches the engine: TET4/TET10/HEX8/HEX27, single type per mesh. HEX20 is shown as unsupported until the engine supports it (`commonFunctions.C getFEMMeshData`). Native admission currently covers HEX8, quadrature order 2 (`backend/README.md`).
- [ ] Units: a project unit system is required before export. Show "unit unknown" otherwise (architecture §Units).
- [ ] BC/load binding: named sets compile to explicit surface-element IDs, with a visible map. Show 1-based input IDs vs 0-based log IDs consistently (architecture §Observations).

**Model tree and validation**

- [ ] Three-indicator nodes (Definition / Freshness / Job) with shape + colour + text (research §5.4, §5.8).
- [ ] `[Validate]` runs workbench preflight: parser stage diagnostics (file / block / record / value / rule), set emptiness, conflicting Dirichlet DOFs, rigid-body-mode check, material admissible ranges from the engine contract, uniform element type, non-finite values (architecture §Parser and writer architecture; §Units on rigid-body checks).
- [ ] `[Run]` is disabled with the listed blockers. Run options: ranks, timeout, MPI path (from `seska-run --help`).

**Job panel**

- [ ] States follow the architecture lifecycle, including `Reconciling`/`Unknown`/`Interrupted`. `seska-run` exit codes map to text: 0 completed, 1 invalid invocation, 2 failed, 3 timeout, 4 cancelled, 5 unresolved reconciliation.
- [ ] Cancel writes `cancel.request`. The UI says "cancel requested" until the tree exit is confirmed. A forced cancel is labelled.
- [ ] Close policy: `stop` with confirmation by default in the editor. `detach` stays hidden until G12 closes.
- [ ] Restart is not offered (engine checkpoint path disabled; G12).

**Convergence monitor**

- [ ] Parse `SIMULATION STEP`, `iteration step`, `convergence norm` (= ‖R_k‖/‖R_0‖, or absolute when the reference ≈ 0), linear solver and package lines, yielded Gauss points, `simulation-output ID` (`Simulation.C`, `CommonEQSet.C`, sample `log0.dat`).
- [ ] Log-scale y-axis with the `convergenceCriterion` and `divergenceCriterion` lines drawn from `input.dat`. Separate panels for Newton iterations per step and linear iterations.
- [ ] Flag "linear solve hit iteration limit (accepted by engine)" when a `hasn't converged` line appears (KSP −3 accepted; `PETScFunctions.C`).
- [ ] Load–deformation graph from `.grf`. Label the ordinate as the *condition value*, not a reaction force (RESEARCH_SESKA_CASES §5.1).

**Results**

- [ ] Steps come only from committed/admitted states. The time scrubber shows physical time and output ID. Interpolated animation frames are labelled.
- [ ] Recovery-mode selector: engine nodal (MLS-recovered), Gauss-point (if enabled for the run), workbench-derived. The legend states the mode.
- [ ] Deformation $\mathbf X_0+\alpha\mathbf u$ with the "×α display only" badge. Probes report physical values and the configuration used.
- [ ] Provenance strip: run ID, model revision, SESKA build (e.g. 1.0.0.19), solver package actually used (MUMPS vs SuperLU_DIST).

**Platform and rendering**

- [ ] Docking inside the main window only. Multi-viewport off until the G14 tests pass. NVRHI renderer per G14.
- [ ] DPI: `style.FontScaleDpi` + `ScaleAllSizes`; Windows DPI manifest. Test at 100/150/200%.
- [ ] Measured budgets (G19) for frame time, ingestion and table panels, using the 99-node case plus a large synthetic mesh.

## 3. Draft screen and panel inventory

| # | Panel / screen | Dock | Purpose | Key content | SESKA grounding | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Workspace launcher | modal at start | Open/create a workspace; reconcile runs | Recent projects, schema/migration notice, run reconciliation summary | architecture §Workspace resolution | Proposed |
| 2 | Case import | dialog | Import `mesh.dat`/`input.dat` pairs and auxiliary files | File pair, hashes, parse diagnostics, element type/order, counts | RESEARCH_SESKA_CASES §4 | Proposed |
| 3 | Model tree | left | Hierarchy: Mesh, Materials, Sets/Surfaces, Constraints, Loads, Steps/Control, Contact, Analyses → Runs → Results | Three-indicator glyphs, diagnostic child nodes | spec §CAE Scene Graph; architecture §Engineering components | Proposed |
| 4 | Sets and surfaces manager | left (below tree) | Named sets ↔ engine surface/element IDs | ID map, counts, emptiness warnings, isolate/colour | architecture §Observations | Proposed |
| 5 | Property inspector | right | Edit the selected entity | Two-column table, units from the project, inline validation, collapsible advanced numerics (PETSc/`directSolver`, tolerances) | input.dat keys (e.g. `convergenceCriterion`, `directSolver`) | Proposed |
| 6 | Material editor | right (tab) | Constitutive law and parameters | Law selector restricted to the engine contract (`constitutiveLawID`), parameter ranges, curve preview (ImPlot) | G09 | Engine-dependent |
| 7 | 3D viewport | centre | Scene, picking, glyphs, fields | Selection-filter HUD, render-mode HUD, view cube, section tool, legend, ×α badge, provenance strip | spec §3D Viewport | Proposed |
| 8 | Mesh quality | bottom (tab) + viewport mode | Metric heatmap and histogram | Metric selector (named source), thresholds, invalid count, save as set | research §5.3 | Proposed |
| 9 | Validate / Diagnostics | bottom (tab) | Pre-solve and run diagnostics | Severity, message, entity links, auto-created error sets, truncation notice | research §5.4 Abaqus Job Monitor | Proposed |
| 10 | Run setup | dialog/right | Configure a `seska-run` launch | Ranks, timeout, MPI path, output dir (must be new), frozen revision summary | `SeskaRun.cpp` options | Proposed |
| 11 | Jobs | bottom (tab) | Lifecycle and control | State, elapsed, ranks, exit code text, cancel/force, open run dir, `--validate` result | architecture §Job lifecycle; README exit codes | Proposed |
| 12 | Convergence monitor | bottom (tab) | Telemetry | Residual ratio (log), criteria lines, iterations/step, linear iterations, solver package, yielded GPs, cut-backs | `log0.dat` structure | Proposed |
| 13 | Solver output | bottom (tab) | Raw stdout/stderr and per-rank logs | Clipped log viewer, rank selector, search, Tier-2 raw lines | RESEARCH_SESKA_CASES §6.2 | Proposed |
| 14 | Results browser | left (Results branch) | Steps × fields | Admitted steps only, field metadata, recovery mode | architecture §Result model | Proposed |
| 15 | Legend and colormap editor | viewport overlay + popover | Colour mapping | Map choice, min/max, bands, out-of-range colours, CVD preview | research §5.2 | Proposed |
| 16 | Probe and path plots | bottom (tab) | Details on demand | Probe table (CSV export), path plot (ImPlot), physical vs display coordinates | spec §Interactive probing (skill) | Proposed |
| 17 | Graphs | bottom (tab) | `.grf` histories | Load–deformation curves with correct axis labels | `Graph.C` | Proposed |
| 18 | Lua console / journal | bottom (tab) | Scripting and replay | Command journal, replay, script run with budget/cancel | spec §Lua API; G15 | Proposed |
| 19 | Terminal | bottom (tab) | Convenience shell | User-selected shell; never drives job state | frontend `AGENTS.md` | Proposed |
| 20 | Preferences | dialog | Navigation preset, theme, DPI/font scale, shortcuts, colormap defaults | Light/dark tokens checked ≥ 3:1 and ≥ 4.5:1 | research §5.8 | Proposed |
| 21 | Command palette | overlay (Ctrl+Shift+P, proposed) | Expert access | Fuzzy command search with shortcuts | Cockburn et al. 2014 | Proposed |

# Research: UX enrichment for `professional-cae-fem-gui-principles` (applied to SESKA)

Date: 2026-10-16. Skill under review: `professional-cae-fem-gui-principles/SKILL.md` v2.0.0 (122 lines).
Target product: `C:\Users\kabwe\Development\seskafeasuite` (read-only inspection).

Status labels used below:

- **Confirmed**: the primary source supports the skill claim as written.
- **Correct**: the skill claim is wrong or misleading and needs a change.
- **Missing**: the source supports guidance the skill does not yet contain.
- **UNVERIFIED**: I could not reach or confirm the primary source. Do not treat as fact.

Version-sensitive facts were checked against: Dear ImGui docking branch `imgui.h` (`IMGUI_VERSION "1.93.1 WIP"`; latest tag v1.93.0, 2026-10-14), ImPlot master (`IMPLOT_VERSION "1.1 WIP"`; latest tag v1.0, 2026-04-05), ImGuizmo master `src/ImGuizmo.h`, PETSc `release` branch headers, Gmsh 4.15.2 reference manual, and the Verdict 2007 reference manual (SAND2007-2853P) plus current Verdict source.

---

## 1. Summary of key corrections

| # | Skill location | Problem | Correction |
| --- | --- | --- | --- |
| C1 | §3 heatmaps: "Scaled Jacobian ($\det(\mathbf{J})$)" | The scaled Jacobian is not $\det\mathbf J$. Verdict defines it as the minimum corner/centre Jacobian determinant normalised by edge lengths: dimensionless, ideal 1, negative when inverted. $\det\mathbf J$ is dimensional and scale-dependent. | Name metrics exactly and give the reference range per element type (§3 below). |
| C2 | §3, §1 | Verdict's `hex_scaled_jacobian` ignores `num_nodes` and evaluates corners only; the HEX27 branch is `#if 0`. For curved TET10/HEX27 it cannot prove validity. | For quadratic elements, use a bound-based validity check (Gmsh `minDetJac`/`minSICN`/`minSIGE`, Johnen et al. 2018) and label corner-only metrics as such. |
| C3 | §7 viewport input gating | `!io.WantCaptureMouse && !ImGuizmo::IsUsing()` is insufficient. When the 3D view is drawn as an `ImGui::Image` inside a docked window, `WantCaptureMouse` is true over it. `IsUsing()` does not cover the view cube: ImGuizmo exposes `IsUsingViewManipulate()`, `IsViewManipulateHovered()`, `IsUsingAny()`, `IsOver()`. | Gate on the viewport item's hover/active state (render-to-texture) or on `WantCaptureMouse` (passthrough central node), plus `!IsOver() && !IsUsingAny() && !IsViewManipulateHovered()`. |
| C4 | §1 "Disable `[Run Solver]` … hover tooltip listing blockers" | In Dear ImGui a disabled item reports no hover unless `ImGuiHoveredFlags_AllowWhenDisabled` is passed. `SetItemTooltip()` uses `ImGuiHoveredFlags_ForTooltip` only, so the blocker tooltip never appears. | Use `BeginDisabled(blocked)` + `IsItemHovered(ImGuiHoveredFlags_ForTooltip \| ImGuiHoveredFlags_AllowWhenDisabled)`. Also list the blockers in the Diagnostics panel, because tooltips are not keyboard-reachable. |
| C5 | §1 readiness glyph colours | `#3FB950` (green) and `#D29922` (amber) have a contrast ratio of 1.01:1 with each other. Red against green is 1.32:1. They share luminance, so greyscale and red–green CVD viewers cannot tell them apart. Colour as the only cue fails WCAG 2.2 SC 1.4.1. | Each state needs a distinct shape (✓, ⟳/↻, ○, ✕, ⚡) plus a text state in the tooltip and inspector. ANSYS Mechanical uses shape-distinct symbols. |
| C6 | §1 tree semantics "(ANSYS / COMSOL Pattern)" | ANSYS has more states than the four in the skill: Underdefined, Error, Ok, Needs to be Updated, Suppressed, Hidden, Meshed, and solve states (yellow bolt not solved, green bolt solving, green check solved, red bolt failed). COMSOL marks errors with a red cross and an Error subnode, and warnings with an orange triangle and a Warning subnode. | Separate *input readiness* from *result freshness* and *job state*. Add Running, Suppressed/Excluded and Warning states. |
| C7 | §1 "Smart Gatekeeping (Abaqus / PrePoMax Pattern)" | Abaqus/CAE does not gate modules or Submit. The docs say any module can be selected at any time, and the Job Manager offers a **Data Check** run. | Present gatekeeping as a SESKA design choice. Base the power-user path on Abaqus's Data Check and Job Monitor precedent. |
| C8 | §5 Tier-1 "Singular Matrix / Zero Pivot at Row k → rigid-body mode near Node #X in U_y" | PETSc's KSP manual says an LU factorisation can fail with a zero pivot "when, in fact, the matrix is non-singular". A pivot row is in the factorisation's (permuted) ordering, not a node/DOF ID. The reason also comes from `KSP_DIVERGED_PC_FAILED` plus `PCFailedReason` (`PC_FACTOR_NUMERIC_ZEROPIVOT`, `PC_FACTOR_STRUCT_ZEROPIVOT`) or from MUMPS `INFOG`. | Present rigid-body mode as a *hypothesis*, verified by a pre-solve constraint/connectivity check. Name a node/DOF only through a verified DOF map. |
| C9 | §5 Tier-2 "`KSPConvergedReason`, `SNESConvergedReason`" | SESKA does not use SNES. It runs its own Newton loop and logs `convergence norm = ‖R_k‖/‖R_0‖`. SESKA also treats `KSP_DIVERGED_ITS` (−3) as *success* (`checkPETScConvergence` returns true). | The diagnostics must show what the engine actually decided. When `−3` was accepted, say so. Do not invent SNES reasons. |
| C10 | §6 "Nodal Averaged (Gouraud/Smooth)" | Gouraud is a shading interpolation, not result averaging. Abaqus averaging is controlled by an averaging threshold, region boundaries (section-based by default), and invariants computed *before* averaging by default. | Rename the toggle and expose the averaging policy (region, threshold, order of invariant and average). |
| C11 | §6 Turbo as a peer of Viridis | Turbo's author says it is "intended for day-to-day tasks where perceptual uniformity is not critical". Crameri et al. (2020) state Turbo "still fails the uniformity requirement". Moreland calls Smooth Cool-Warm "superseded by Fast", and ParaView's default is now **Fast** (Samsel, Scott, Moreland 2024). | Default sequential map: viridis (or cividis). Default diverging map: Fast or Cool-Warm, and only when the field has a meaningful centre. Offer Turbo with a non-uniformity caveat. The SESKA spec requires Turbo, Viridis and Cool-Warm, so keep all three. |
| C12 | §4 "Crinkle Slice toggle" on the clipping plane | ParaView has two separate options. **Crinkle clip** belongs to the Clip filter (not available when clipping by Scalar). **Crinkle slice** belongs to the Slice filter. | Name both and specify which one the section tool implements. |
| C13 | §4 `ImGuizmo::ViewManipulate` "+X…−Z, Iso" | `ViewManipulate` is a clickable view cube with 26 targets (27 boxes minus the centre) and 40-frame interpolation. It has no "Iso" button: corners give the isometric views. It changes only the view matrix, not orthographic/perspective. The header warns that the cube view is patented by Autodesk (US7782319B2). | Document the real behaviour and the IP note. The SESKA spec does not name ImGuizmo: it lists "Im3d or a dedicated GPU-instanced glyph pipeline" plus generic transform gizmos. |
| C14 | §7 `ImGuiListClipper` "O(visible rows)", "10^6+ DOFs", "< 0.2 ms" | The clipper requires **evenly spaced** items with random access. Rows are entities, not DOFs. The 0.2 ms figure has no source. | Clip only uniform-height rows. Flatten expandable trees into a visible-row index first. Keep pinned rows visible with `IncludeItemByIndex()`. Treat the 0.2 ms figure as a measured budget (G19), not a guarantee. |
| C15 | §7 two-column table with `SizingStretchProp` and "0.38f width" | `SizingStretchProp` sets stretch weights *proportional to content widths*, so it does not fix a 38/62 split. | Use `TableSetupColumn("Label", ImGuiTableColumnFlags_WidthStretch, 0.38f)` and `TableSetupColumn("Value", …WidthStretch, 0.62f)`, or a fixed DPI-scaled label width. |
| C16 | §7 example units `"%.3f MPa"` | SESKA has no established unit system (architecture: "No automatic assumption of SI units is justified"). | Format strings take their unit from the model's declared unit system. When it is undeclared, show "unit unknown", never a guessed unit. |
| C17 | §2 DPI "24x24 DPI-scaled" | Since Dear ImGui 1.92, fonts scale through `style.FontScaleDpi`, and `io.ConfigDpiScaleFonts` (docking, EXPERIMENTAL) scales fonts but "*NOT* sizes/padding". Sizes need `style.ScaleAllSizes()`. | Specify both mechanisms, and require a Windows DPI-awareness manifest. |
| C18 | §2 Integrated terminal | SESKA rules: "a returned prompt is not evidence of job completion". Managed solver launches use argument lists, never shell strings. | The terminal is a convenience. It never drives job state, which comes only from the `seska-run` supervisor. |

## 2. Top additions (missing from the skill)

1. **Job lifecycle as first-class UI state.** Created → Validating → Ready → Running → (CancelRequested | Stopping | Detached | Reconciling) → Finalizing → Completed | Failed | Cancelled | Interrupted | Unknown. See SESKA architecture §Job lifecycle. A green exit code is never "Completed" until outputs are validated.
2. **Provenance in every result view.** Show the run ID, frozen model revision, solver build identity (e.g. SESKA 1.0.0.19), and the "model edited since this run" stale banner.
3. **Field metadata in the legend.** Show quantity, unit, association (node, element, Gauss point, recovered), frame, tensor measure, step/physical time, recovery mode, and missing-data colour. Never show missing values as zero.
4. **Separate convergence axes.** Keep accepted increment, Newton iteration, inner linear iterations, and physical time/load factor separate. Never draw one unlabeled "iteration" axis.
5. **Keyboard and command access.** Use `ImGui::Shortcut()`/`SetNextItemShortcut()`, a searchable command palette that shows shortcuts (supporting novice-to-expert transitions; Cockburn et al. 2014), and visible focus (WCAG 2.4.7).
6. **Undo/redo through the core command dispatcher,** with a replayable Lua journal, following the Abaqus `.rpy`/`.jnl`/`.rec` and FreeCAD transactions precedents.
7. **Response-time classes.** Picking and highlight feedback ≤ 0.1 s. Panel and field switches ≤ 1 s. Anything over 10 s gets a percent-done or absolute-progress indicator and stays cancellable (Nielsen 1993; Card, Robertson & Mackinlay 1991).
8. **Overview first, zoom and filter, then details-on-demand** (Shneiderman 1996) as the results-exploration order: legend and whole-model view, then threshold/isolate, then probe.
9. **Pre-solve checks the solver cannot do cheaply.** Unconstrained rigid-body modes (connectivity components × constrained DOFs), overlapping or conflicting Dirichlet sets, empty sets, unit consistency (cf. COMSOL's orange squiggle for unit issues).
10. **Abaqus-style auto-created error sets.** Turn diagnostic-referenced entities into a temporary named set ("ErrElem…") so the user can isolate, colour, and export them.

## 3. Unverified items

- **UNVERIFIED** ISO 9241-110:2020 principle names (paywalled). Likely names: suitability for the user's tasks, self-descriptiveness, conformity with user expectations, learnability, controllability, use-error robustness, user engagement. ISO 9241-112:2017 (presentation of information) contents were also not reached.
- **UNVERIFIED** Abaqus/CAE default averaging threshold (often quoted as 75%). The pages I fetched do not state a default.
- **UNVERIFIED** HyperMesh selection-filter behaviour ("HyperMesh / Gmsh Pattern"). The vendor docs were not accessed. Gmsh's own selection-filter UI was not verified either.
- **UNVERIFIED** COMSOL "edited/needs rebuild" node indicator. Only the error, warning and information icons were confirmed.
- **UNVERIFIED** FreeCAD FEM workbench wiki (bot-blocked). Facts below come from FreeCAD source on GitHub instead.
- **UNVERIFIED** PrePoMax result-averaging and gatekeeping behaviour. Only the three-tab tree (Geometry / FE Model / Results) and the "features without sets" note were confirmed from the manual.
- **UNVERIFIED** Card/Moran/Newell (1983) perceptual-processor cycle (~100 ms, 50–200 ms range). Stated from the book, not re-fetched.
- **UNVERIFIED** as a source: the skill's "75–85% viewport", "24–48 px glyph clamp", "12 or 16 iso-bands" and "< 0.2 ms" figures. They are design heuristics with no primary source. Keep them as configurable defaults, not rules.
- **Tetrahedral scaled-Jacobian acceptable range.** The text extracted from the 2007 PDF reads Acceptable `[1/2, 1]`(rendering garbled), Normal `[-1, 1]`, unit equilateral = 1. Some sources quote `[0.5, 0.707]`, which a VTK issue (vtk#19644, not fetchable, HTTP 403) reportedly flags as a manual error because it excludes the ideal value 1. Confirm against the PDF page before you publish a threshold.

---

## 4. Step 1: SESKA grounding (what actually exists)

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

---

## 5. Step 2: per-topic findings

### 5.1 Dear ImGui, ImPlot, ImGuizmo APIs

**Sources:** `imgui.h` (docking, 1.93.1 WIP), `docs/FAQ.md`, `docs/BACKENDS.md` (ocornut/imgui); `implot.h` (epezent/implot master, 1.1 WIP); `src/ImGuizmo.h`, `src/ImGuizmo.cpp` (CedricGuillemet/ImGuizmo master).

| Claim | Status | Evidence |
| --- | --- | --- |
| `DockSpaceOverViewport` + `ImGuiDockNodeFlags_PassthruCentralNode` | **Confirmed** | Signature `ImGuiID DockSpaceOverViewport(ImGuiID dockspace_id = 0, const ImGuiViewport* viewport = NULL, ImGuiDockNodeFlags flags = 0, const ImGuiWindowClass* window_class = NULL)`. Header example: `ImGui::DockSpaceOverViewport(0, nullptr, ImGuiDockNodeFlags_PassthruCentralNode)`. The passthru flag lets inputs pass through an *empty* central node. |
| Default 4-zone layout | **Missing** | Programmatic layouts use DockBuilder, which `imgui.h` calls "WIP and internal" (`imgui_internal.h`). Pin the ImGui version and persist the user layout via `.ini`, with a "Reset layout" command. |
| `ImGuiTableFlags_SizingStretchProp` | **Confirmed, but Correct (C15)** | `= 3 << 13`: "Columns default to _WidthStretch with default weights proportional to each columns contents widths." |
| `ImGuiListClipper` | **Confirmed, but Correct (C14)** | "If you have lots evenly spaced items and you have random access to the list…". `Begin(items_count, items_height=-1)`. `IncludeItemByIndex()` must be called *before* the first `Step()`. Use `Begin(INT_MAX)` plus `SeekCursorForItem()` when the count is unknown. |
| `io.WantCaptureMouse` gating | **Correct (C3)** | FAQ: "When `io.WantCaptureMouse` is set, you need to discard/hide the mouse inputs from your underlying application… always pass your mouse/keyboard inputs to Dear ImGui." Also: `WantCaptureMouseUnlessPopupClose` handles click-to-close-popup. |
| `ImGuizmo::IsUsing`, `ViewManipulate` | **Confirmed names; Correct semantics (C3, C13)** | `IsOver()`, `IsUsing()` ("return true if mouse IsOver or if the gizmo is in moving state"), `IsUsingViewManipulate()`, `IsViewManipulateHovered()`, `IsUsingAny()`, `Enable()`, `SetRect()`, `SetOrthographic()`, `SetDrawlist()`, `BeginFrame()`. `ViewManipulate(float* view, float length, ImVec2 position, ImVec2 size, ImU32 backgroundColor)`, plus an overload taking projection/operation/mode/matrix "if you did not call Manipulate before". State is bound to the current ID, so `PushID` separates multiple cubes. Header warning: "this cubeview is patented by Autodesk : US7782319B2". |
| Disabled button with tooltip | **Correct (C4)** | `ImGuiHoveredFlags_AllowWhenDisabled`: "IsItemHovered() only: Return true even if the item is disabled". `ImGuiHoveredFlags_ForTooltip` = "Shortcut for standard flags when using IsItemHovered() + SetTooltip() sequence." |
| DPI | **Correct (C17)** | FAQ: `style.FontScaleDpi = 2.0f;` `io.ConfigDpiScaleFonts = true; // (Docking branch only) … scale fonts but _NOT_ scale sizes/padding`; `io.ConfigDpiScaleViewports`. `style.ScaleAllSizes(float)` scales "spacing/padding/thickness… Do not scale fonts." On Windows the app must declare DPI awareness (manifest or `ImGui_ImplWin32_EnableDpiAwareness()`). |
| Multi-viewport | **Missing** | `ImGuiConfigFlags_ViewportsEnable` requires both `ImGuiBackendFlags_PlatformHasViewports` and `RendererHasViewports`. A custom NVRHI renderer must implement the renderer viewport hooks before this can be enabled (SESKA defers it). |
| Keyboard shortcuts | **Missing** | `bool Shortcut(ImGuiKeyChord, ImGuiInputFlags = 0)`, `void SetNextItemShortcut(...)`. Default route is `ImGuiInputFlags_RouteFocused`; `ImGuiInputFlags_RouteGlobal` exists. `ImGuiConfigFlags_NavEnableKeyboard` enables full keyboard navigation. |
| Large selections / box select in lists | **Missing** | `BeginMultiSelect(ImGuiMultiSelectFlags, selection_size, items_count)`, `ImGuiMultiSelectFlags_BoxSelect1d/2d`. Works with the clipper for node/element tables. |
| Trees | **Missing** | `ImGuiTreeNodeFlags_DrawLinesFull` / `DrawLinesToNodes` (style `TreeLinesFlags`) improve hierarchy legibility for the model tree. |
| ImPlot histogram and selection | **Correct (wording)** | ImPlot has `PlotHistogram(label, values, count, bins=ImPlotBin_Sturges, bar_scale, ImPlotRange range, const ImPlotSpec&)`, `DragLineX`, `DragRect`, `IsPlotHovered()`, `GetPlotMousePos()`, `IsPlotSelected()`. It has **no "click a bin" API**. Implement range isolation with two `DragLineX` thresholds or a `DragRect`, and compute membership in your own data. |
| ImPlot log residual axis | **Confirmed** | `SetupAxisScale(ImAxis, ImPlotScale_Log10)`. |
| ImPlot colormaps | **Missing** | Built-ins include `ImPlotColormap_Viridis`, `_Plasma`, `_RdBu`, `_Jet`, … but **no Turbo, Cool-Warm or Fast**. Register them with `AddColormap(name, cols, size, qual=false)`, and use the *same* LUT table for GPU textures and `ColormapScale` legends. |
| ImPlot API churn | **Missing** | Master (1.1 WIP) passes flags via `ImPlotSpec`. Code written for 0.16 signatures will not compile. Pin the version. |

**Paste-ready enrichment (ImGui reference):**

> Gate viewport input on: `viewportHovered && !ImGuizmo::IsOver() && !ImGuizmo::IsUsingAny() && !ImGuizmo::IsViewManipulateHovered()`. Take `viewportHovered` from `ImGui::IsItemHovered()` on the viewport `Image` when the scene is drawn into a texture, or from `!io.WantCaptureMouse` when it is drawn behind a `PassthruCentralNode` dockspace. Always forward raw input to ImGui. Show reasons on disabled actions with `IsItemHovered(ImGuiHoveredFlags_ForTooltip | ImGuiHoveredFlags_AllowWhenDisabled)`. Clip only uniform-height rows; flatten trees to a visible-row index first. Pin Dear ImGui (docking), ImPlot and ImGuizmo to exact commits, because DockBuilder is internal and ImPlot's `ImPlotSpec` API changed after v1.0.

### 5.2 Colormaps and colour accessibility

| Source | What it says | Effect on the skill |
| --- | --- | --- |
| van der Walt & Smith, *mpl colormaps* (bids.github.io/colormap; SciPy 2015) | Viridis is designed in CAM02-UCS to be "perfectly perceptually-uniform", including in greyscale, and "relatively friendly to common forms of colorblindness". | **Confirmed** default sequential. |
| Matplotlib, *Choosing Colormaps* (matplotlib.org …/colors/colormaps.html) | Use sequential maps for ordered data. Use diverging maps "when the information being plotted has a critical middle value… or when the data deviates around zero". Jet: "L*values vary widely… poor choice". "coolwarm… doesn't span a wide range of L* values." Turbo "was created to display depth and disparity data". Avoid red + green together. | **Confirmed** diverging-centred-at-zero. Add: a diverging map only for signed fields with a meaningful centre. |
| Moreland 2009, *Diverging Color Maps for Scientific Visualization*, ISVC, LNCS 5876:92–103, doi:10.1007/978-3-642-10520-3_9; kennethmoreland.com/color-maps | Cool-Warm endpoints RGB (0.230, 0.299, 0.754) → (0.706, 0.016, 0.150), midpoint (0.865, 0.865, 0.865). | **Confirmed** definition. |
| Moreland, kennethmoreland.com/color-advice | "Fast… designed to be the default colormap in the ParaView". Smooth Cool Warm "has been superseded by Fast". Viridis "does not have as much discrimination"; its dark low end "may need shortening for 3D". Inferno is for 2D. | **Missing**: on 3D shaded surfaces, dark map ends lose detail. Consider Fast or a shortened viridis for 3D. |
| Samsel, Scott & Moreland 2024, *A New Default Colormap for ParaView*, IEEE CG&A, doi:10.1109/MCG.2024.3383137; ParaView 6.0.1 release notes | Fast is ParaView's default. 6.0.1 fixed its colour space (Lab). | **Missing** precedent. |
| Mikhailov 2019, Google Research blog *Turbo* | "Intended for day-to-day tasks where perceptual uniformity is not critical". Viridis is "generally recommended". Turbo is poor in greyscale, and its ends are ambiguous under achromatopsia. | **Correct (C11)**: label Turbo as non-uniform. |
| Borland & Taylor 2007, IEEE CG&A 27(2):14–17, doi:10.1109/MCG.2007.323435 | The rainbow colour map is harmful. | **Confirmed** "Never default to Rainbow/Jet". |
| Ware, Stone & Szafir 2023, *Rainbow Colormaps Are Not All Bad*, IEEE CG&A, doi:10.1109/MCG.2023.3246111 | Rainbow maps have some under-appreciated properties (value identification against a key). | **Missing** nuance: if a banded rainbow is offered for value lookup, it must carry labelled band edges. |
| Crameri, Shephard & Heron 2020, Nat. Commun. 11:5444, doi:10.1038/s41467-020-19160-7 | Requirements: perceptual uniformity, perceptual order, CVD readability, B/W readability, always a colour bar. CVD prevalence ≈ 8% of men, 0.5% of women. Rainbow distortion can exceed 7% of data variation. Turbo still fails uniformity. | **Confirmed/Missing**: add CVD/greyscale preview modes. |
| Nuñez, Anderton & Renslow 2018, PLOS ONE, doi:10.1371/journal.pone.0199239 | Cividis is optimised to look nearly identical under red–green deficiency. | **Missing**: offer cividis. |

**Discrete bands:** the skill's iso-band toggle is reasonable. Abaqus and other tools default to banded contours, but I did not fetch a primary source for "engineers rely on discrete bands", so treat that sentence as a rationale, not a citation. Band edges must be labelled with values in the legend.

**Out-of-range colours:** `#404040` for below-threshold has a contrast ratio of 1.83:1 against `#0D1117` and fails WCAG 1.4.11's 3:1 for graphical objects. Magenta `#FF00FF` gives 6.0:1. Use a lighter neutral (e.g. `#9E9E9E`) or a hatch/stipple pattern, and say in the legend what the colour means.

**Paste-ready:**

> Colormaps: viridis (sequential default), cividis (CVD-safe sequential), Fast or Cool-Warm (diverging, only for signed fields with a meaningful centre, symmetric limits by default), Turbo (optional, labelled "not perceptually uniform"). Never default to Jet. Use one LUT definition for both the GPU texture and the ImPlot legend. The legend must show: quantity, unit, association/recovery mode, step and physical time, min/max with format, band edges, and the colours used for missing, below-range and above-range values. Provide greyscale and deuteranopia/protanopia previews of the viewport.

### 5.3 Mesh quality metrics

**Verdict Library Reference Manual** (Stimpson, Ernst, Knupp, Pébay, Thompson; Sandia, April 2007; SAND2007-2853P, distributed in github.com/sandialabs/verdict). §1.4 defines *Acceptable* ("well-behaved elements"), *Normal* (all but degenerate) and *Full* ranges.

| Metric | Definition (Verdict) | Acceptable | Normal | Ideal |
| --- | --- | --- | --- | --- |
| Hex scaled Jacobian (§7.11) | Minimum Jacobian determinant at each corner and the centre, divided by the corresponding edge lengths | [0.5, 1] | [−1, 1] | 1 (unit cube) |
| Hex skew (§7.16) | Max \|cos\| between normalised principal axes | [0, 0.5] | [0, 1] | 0 |
| Tet aspect ratio (§6.6) | $L_{max}/(2\sqrt6\,r)$ | [1, 3] | [1, ∞) | 1 |
| Tet radius ratio (§6.12) | $R/(3r)$ | (see manual) | | 1 |
| Tet scaled Jacobian (§6.14) | $\sqrt2\,J/\lambda_{max}$ (edge-product normalised) | **see Unverified note** (extracted text reads [1/2, 1]; normal [−1, 1]) | [−1, 1] | 1 (equilateral) |
| Hex max aspect Frobenius (§7.7) | Condition-number style | [1, 3] (extraction suggests) | | 1 |

Implementation facts from current Verdict source: `hex_scaled_jacobian(int /*num_nodes*/, …)` ignores the node count. Its 27-node branch is compiled out (`#if 0`), so it is corner-only. `hex_jacobian` and `hex_volume` do support 20/27-node hexes (sub-tet or Gauss evaluation). Tet functions special-case `num_nodes == 10` for some metrics.

**Gmsh 4.15.2 reference manual**, FAQ "What is the signification of SICN, Gamma and SIGE": these measures are "defined for all 2D and 3D element types, except Gamma which is not defined for hexes and pyramids". "Negative values of SICN and SIGE indicate tangled elements". The quality part lies in [0, 1], where 1 is best. ICN relates to stiffness-matrix conditioning (iterative-solver speed). IGE relates to gradient error, and for hexes it "is the well-known scaled Jacobian". Gamma = inscribed/circumscribed radius for simplices. `Mesh.QualityType` 0 = SICN, 1 = SIGE, 2 = gamma, 3 = Disto (minJ/maxJ). `Plugin(AnalyseMeshQuality)` computes min J, IGE and ICN for *curvilinear* elements, can hide elements by threshold, and Tools → Statistics plots histograms. The API `getElementQualities` offers `minDetJac`, `maxDetJac`, `minSJ`, `minSICN`, `minSIGE`, `gamma`, etc. The method comes from Johnen, Geuzaine, Toulorge & Remacle, *Efficient computation of the minimum of shape quality measures on curvilinear finite elements*, Computer-Aided Design (2018), doi:10.1016/j.cad.2018.03.001.

**Assessment:** the heatmap and histogram concept is **Confirmed** (Gmsh does exactly this). The metric naming is **Correct (C1, C2)**. "Skewness" is **Correct**: Verdict hex skew is an axis-parallelism measure, and other tools use equiangle or equivolume skew. Always show which definition is in use. Minimum dihedral angle is a valid tet metric. Verdict also has `tet_minimum_angle` / `tet_equiangle_skew`; check the exact definitions before labelling.

**Paste-ready (mesh-quality reference):**

> Name every metric with its source definition, e.g. "Scaled Jacobian (Verdict, corner-based)" or "SICN (Gmsh)". Ship per-element-type default thresholds from the Verdict *Acceptable* range (hex scaled Jacobian ≥ 0.5; hex skew ≤ 0.5; tet aspect ratio ≤ 3) and let the user edit them. Any metric < 0 means *invalid/inverted*. Colour it with the error colour plus a hatch, independent of the colormap. For quadratic TET10/HEX27, corner-based metrics do not prove validity. Use a bound-based minimum Jacobian (Gmsh `minDetJac`/`minSICN`, Johnen et al. 2018) or sample at the quadrature points, and label the check's scope. The histogram is a filter: two draggable thresholds isolate a value range and ghost the rest. The isolated set can be saved as a named element set.

### 5.4 CAE workflow and UX precedents

| Product | Verified behaviour | Effect on the skill |
| --- | --- | --- |
| **Abaqus/CAE**: *What is a module?* (abaqus-docs.mit.edu 2017 …/simagsa-c-abswhatisamodule.htm) | Modules follow a suggested workflow (Part, Property, Assembly, Step, …, Mesh, Job, Visualization), but "you can select any module at any time, regardless of the state of your model". | **Correct (C7)**: the pipeline guides, it does not lock. |
| Abaqus Job Manager and *Checking the model* (…/simagsa-t-abscheckinput.htm) | The Job Manager can run a **data check**, submit, continue after a data check, and kill. The data check "checks that the model is consistent and that all the required model options have been set". | **Missing**: provide a "Validate (data check)" action distinct from Run. |
| Abaqus *Monitoring the progress of an analysis job* (…/simacae-c-anaconcmonitor.htm) | The Job Monitor has Log, Errors and Warnings tabs. If a message points to a region, a node or element set is created automatically and its name shows with the message. The monitor caps the display at 10 errors and 50 warnings by default. | **Confirmed/Missing**: spatial error links. Add auto-sets and say when a list is truncated. |
| Abaqus result averaging (…/simacae-t-resaverage.htm; …/simacae-c-resconceptaverage.htm) | Averaging threshold: "A value of 0 suppresses all averaging; a value of 100 averages all results". By default scalars are computed before averaging, and the threshold applies only then. Averaging stays within result regions (default: section assignments). It applies to element-based output only; displacement is not averaged. | **Correct (C10)**. |
| Abaqus *Scaling deformations* (…/simacae-t-customdeffactorframe.htm) | "The default scaling is a uniform factor of 1.00 for large-displacement analyses." For small-deformation analyses, the deformation is scaled "such that the maximum deformation is 10% of the largest model dimension." | **Confirmed**, and the 10% rule is added. |
| Abaqus files (*Understanding the files generated by creating and analyzing a model*, …/simacae-c-dbsconcfilesgenerated.htm) | `.rpy` records almost every operation in a session. `.jnl` holds only the commands that change the saved database, enough to recreate it. `.rec` holds the commands since the last save, for recovery. | **Missing**: journal/replay model for SESKA (Lua). |
| **ANSYS Mechanical**: *Tree Outline conventions* (ansyshelp.ansys.com v261 …/ds_Outline_Conventions.html) | States: Underdefined (e.g. "a load requires a nonzero magnitude"), Error, Mapped Face/Match Control Failure, Ok, Needs to be Updated, Hidden, Meshed, Suppress. Solve: yellow bolt = not yet solved, green bolt = solving, green check = solved, red bolt = failed (a pause overlay means it can resume from restart points), plus down arrows for background results. Orange highlighting marks a potential problem, with a matching Messages entry. | **Correct (C5, C6)**. |
| **COMSOL**: *Errors, Warnings, and Information* (doc.comsol.com 6.4 …/comsol_ref_modeling.19.020.html) | Error: red cross on the node icon plus an Error subnode, and the build stops. Warning: orange triangle plus a Warning subnode, and work continues. Information nodes exist. Unit issues get an orange squiggle; invalid expressions get a red squiggle. | **Missing**: per-field unit and expression validation underline. Diagnostics as child nodes. |
| **ParaView**: *Filtering Data* (docs.paraview.org …/UsersGuide/filteringData.html) | The Apply button commits filter changes. Clip: "Check Crinkle Clip if you don't want this filter to truly clip cells on the boundary". It is not available when clipping by Scalar, and "Inside Out" inverts the clip. Slice: crinkle slicing passes complete intersected cells. | **Correct (C12)**. **Missing**: an explicit Apply for expensive recomputations (field recovery, iso-surfaces). |
| **PrePoMax** manual v2.4.0 (prepomax.fs.um.si) | Three tree tabs (Geometry, FE Model, Results) set the workflow. Node/element sets and surfaces are supported, but "it's usually preferred to add features without creating sets or surfaces first". | **Correct**: pick-to-feature is the common path. Sets are created implicitly and named, and SESKA compiles them to engine IDs. |
| **FreeCAD** (source: `src/App/Document.h`, `src/Mod/Fem/femtools/checksanalysis.py`) | Document transactions `openTransaction/commitTransaction/abortTransaction`, `setMaxUndoStackSize(20)` default. The FEM pre-solve check accumulates human-readable messages (e.g. "A single mesh object must be defined in the analysis."). | **Missing**: transactional undo, plus a pre-solve message list as the gate content. |
| **Gmsh GUI** | Tools → Statistics histograms; clipping planes A,B,C,D adjustable by dragging in the input fields (manual FAQ). | **Confirmed** histogram precedent. |

**Paste-ready (tree states):**

> Model-tree nodes carry three independent indicators, each with a distinct glyph shape, colour and text: (1) **Definition**: Ok ✓, Underdefined ○ (lists missing inputs), Error ✕, Warning ▲, Suppressed ⊘. (2) **Freshness**: Up-to-date, or Needs update ↻ (an upstream revision changed). (3) **Job** (on Analysis/Run nodes): Not run ⚡(outline), Running ⚡(animated), Completed ✓, Failed ✕, Cancelled ■, Interrupted/Unknown ?. Diagnostics appear as child nodes (COMSOL pattern) and in the Diagnostics panel. Colour is never the only cue (WCAG 2.2 SC 1.4.1).

### 5.5 Solver diagnostics (PETSc)

**Sources:** PETSc `include/petscksp.h` (`KSPConvergedReason` and per-value docs), `include/petscsnes.h` (`SNESConvergedReason`), `include/petscpctypes.h` (`PCFailedReason`), petsc.org/release/manual/ksp (*Convergence Tests*, *Convergence Monitoring*, direct solvers), petsc.org/release/manualpages/Mat/MATSOLVERMUMPS, petsc.org/release/manual/snes/#convergence-tests.

- `KSPConvergedReason` values: diverged −2 NULL, −3 ITS, −4 DTOL, −5 BREAKDOWN, −6 BREAKDOWN_BICG, −7 NONSYMMETRIC, −8 INDEFINITE_PC, −9 NANORINF, −10 INDEFINITE_MAT, −11 PC_FAILED, −12 USER, −13 INNER_SOLVE_FAILED. Header doc text:
  - `KSP_DIVERGED_PC_FAILED`: "not possible to build or use the requested preconditioner. This is usually due to a zero pivot in a factorization. It can also result from a failure in a subpreconditioner…"
  - `KSP_DIVERGED_BREAKDOWN`: "…Could be due to a singular matrix or preconditioner."
  - `KSP_DIVERGED_INDEFINITE_PC`: the preconditioner appears indefinite while the method (CG) requires SPD.
- `PCFailedReason`: `PC_NOERROR 0, PC_FACTOR_STRUCT_ZEROPIVOT 1, PC_FACTOR_NUMERIC_ZEROPIVOT 2, PC_FACTOR_OUTMEMORY 3, PC_FACTOR_OTHER 4, PC_INCONSISTENT_RHS 5, PC_SUBPC_ERROR 6`.
- The KSP manual says: "occasionally an LU factorization will fail with a zero pivot when, in fact, the matrix is non-singular". The option `-pc_factor_nonzeros_along_diagonal` "will often help". It also says `KSPGetConvergedReason()` explains why convergence or divergence was detected. `-ksp_monitor` prints residual norms; custom monitors go through `KSPMonitorSet`; monitors are "slow and should be used only for testing or convergence studies, not for timing".
- MUMPS through PETSc: on `KSP_DIVERGED_PC_FAILED`, get details with `KSPGetPC` → `PCFactorGetMatrix` → `MatMumpsGetInfo`/`MatMumpsGetInfog`, or run with `-ksp_error_if_not_converged`. ICNTL(24) enables null-pivot detection (`-mat_mumps_icntl_24`).
- `SNESConvergedReason` (not used by SESKA): `SNES_DIVERGED_FNORM_NAN` is deprecated since 3.25 in favour of `SNES_DIVERGED_FUNCTION_NANORINF`. Other values include `…_LINE_SEARCH`, `…_MAX_IT`, `…_DTOL`, `…_LOCAL_MIN`, `…_FUNCTION_DOMAIN`, `…_JACOBIAN_DOMAIN`.

**Corrected translation table (paste-ready, generic PETSc):**

| Raw evidence | Physical hypothesis to show (Tier 1) | Confidence rule |
| --- | --- | --- |
| `KSP_DIVERGED_PC_FAILED` + `PC_FACTOR_NUMERIC_ZEROPIVOT`, or MUMPS null pivots | "Stiffness matrix singular or nearly singular. Likely causes: unconstrained rigid-body motion, a disconnected part, a zero-stiffness material, or a duplicate/unmerged node." Link to the pre-solve rigid-body and connectivity check results. | Name a node/DOF only when the pivot row maps through a verified equation→DOF map in the solver's ordering. Otherwise say "location unknown". |
| `KSP_DIVERGED_ITS` | "Linear solver hit its iteration limit." Show whether the engine *accepted* the solution anyway (SESKA does). | Always show the accepted/rejected decision. |
| `KSP_DIVERGED_DTOL` / `NANORINF` | "Linear solve diverged / produced non-finite values." Check material parameters, units and tangent consistency. | — |
| `KSP_DIVERGED_INDEFINITE_PC`/`_MAT` with CG | "Operator not positive-definite for this solver: possible instability (buckling, softening) or wrong solver choice." | — |
| Newton norm growth above `divergenceCriterion`, or iteration limit reached | "Equilibrium iterations did not converge in step N." Show the increment size, the cut-back history and the residual curve. | Separate the tangent hypothesis from the load-increment hypothesis. Do not assert either. |
| Jacobian ≤ 0 reported by the engine | "Element inverted (excessive distortion) during increment." Link to the element. | Only when the engine reports an element ID. |

### 5.6 Results visualisation correctness

- **Averaging is region-limited by default** in Abaqus (section assignments). The threshold applies only when invariants are computed before averaging. Node-based outputs are not averaged (§5.4).
- **Unaveraged jumps as an error indicator:** the discontinuity between element-wise stresses and a smoothed field is the basis of the Zienkiewicz–Zhu estimator. Zienkiewicz & Zhu 1987, IJNME 24:337–357, doi:10.1002/nme.1620240206; superconvergent patch recovery, IJNME 33 (1992), doi:10.1002/nme.1620330703. This **confirms** the skill's "discontinuities indicate refinement need" and gives it a citation. Present it as an *indicator*, not proof.
- **SESKA specifics:** the engine's default nodal stress is already MLS-recovered from Gauss points. "Unaveraged" in SESKA may therefore mean Gauss-point output (only if enabled per case), not element-nodal extrapolation. Order of operations matters: an invariant of an average differs from the average of an invariant. Treat them as named recovery modes (architecture §Interpolation, averaging).
- **Deformation scale:** Abaqus uses 1.0 for large displacement and auto (max deformation = 10% of the largest model dimension) for small deformation. The skill is **Confirmed**, with the 10% rule added. Show "×α (display only)" in the viewport whenever α ≠ 1. Probes return physical $\mathbf u$.
- **Bands:** see §5.2. Label band edges, because the bands quantise the data.

### 5.7 HCI foundations for expert desktop tools

- **Nielsen, *10 Usability Heuristics*** (NN/g, 24 Apr 1994, reviewed 30 Jan 2024): Visibility of system status; Match between system and real world; User control and freedom; Consistency and standards; Error prevention; Recognition rather than recall; Flexibility and efficiency of use; Aesthetic and minimalist design; Help users recognize, diagnose, and recover from errors; Help and documentation. Skill mapping: readiness glyphs (1), physical-language diagnostics (2, 9), undo and cancel (3), gatekeeping and inline validation (5), command palette and shortcuts (6, 7), progressive disclosure (8).
- **Shneiderman 1996**, *The Eyes Have It*, IEEE Symp. Visual Languages, pp. 336–343, doi:10.1109/VL.1996.545307: "Overview first, zoom and filter, then details-on-demand". The seven tasks: overview, zoom, filter, details-on-demand, relate, **history**, **extract**. Skill gaps: *history* (view and probe history) and *extract* (CSV, images, report).
- **Cockburn, Gutwin, Scarr & Malacria 2014**, *Supporting Novice to Expert Transitions in User Interfaces*, ACM Computing Surveys 47(2), doi:10.1145/2659796. Reviews interface designs that move users from menu use to expert methods such as shortcuts. Recommendation: show shortcuts beside every menu and palette entry, and make commands searchable by name.
- **ISO 9241-110:2020**: interaction principles (**UNVERIFIED** names, see §3). **ISO 9241-112:2017**: presentation of information (**UNVERIFIED** contents).
- **Undo/history:** Abaqus `.rpy`/`.jnl`/`.rec` and FreeCAD transactions (§5.4). SESKA's command dispatcher is the natural transaction boundary. Every user command becomes one Lua-replayable journal entry, which also serves the spec's agent automation requirement.
- **CAE-specific peer-reviewed usability research:** not located in this pass (**UNVERIFIED** gap). Do not cite any.

### 5.8 Accessibility (dark theme)

**WCAG 2.2** (W3C Recommendation, 12 Dec 2024):

| Success criterion | Level | Requirement |
| --- | --- | --- |
| 1.4.1 Use of Color | A | Colour is not the only visual means of conveying information |
| 1.4.3 Contrast (Minimum) | AA | 4.5:1 for text; 3:1 for large text |
| 1.4.11 Non-text Contrast | AA | 3:1 for UI components and graphical objects |
| 2.4.7 Focus Visible | AA | A visible keyboard focus indicator |
| 2.4.11 Focus Not Obscured (Minimum) | AA | The focused component is not entirely hidden |
| 2.5.8 Target Size (Minimum) | AA | Targets at least 24 × 24 CSS px, with listed exceptions |

WCAG targets web content. Using it for a native ImGui tool is a design benchmark, not a conformance claim (the SESKA architecture already says no conformance is established).

Computed contrast ratios (WCAG relative-luminance formula) of the skill colours:

| Colour | vs `#0D1117` | vs ImGui dark `#0F0F0F` | vs `#242424` (frame) | vs white |
| --- | --- | --- | --- | --- |
| `#3FB950` green | 7.45 | 7.55 | 6.11 | 2.54 |
| `#D29922` amber | 7.50 | 7.59 | 6.15 | 2.52 |
| `#8B949E` grey | 6.15 | 6.23 | 5.05 | 3.08 |
| `#F85149` red | 5.65 | 5.72 | 4.63 | 3.35 |
| `#404040` below-range | 1.83 | 1.85 | 1.50 | 10.37 |

Green vs amber is 1.01:1 and red vs green is 1.32:1. Every status colour passes against dark backgrounds but **fails 3:1 against a light theme**. Conclusion: shape coding is mandatory (C5), a light theme needs its own tokens, and `#404040` must change.

**Paste-ready:** "Every status uses shape + colour + text. Text ≥ 4.5:1 and glyphs/borders ≥ 3:1 against their actual background, checked for both themes. Clickable icons ≥ 24 × 24 px at 100% scale, scaled by DPI. Visible focus ring for keyboard navigation (`NavEnableKeyboard`). Provide CVD and greyscale previews for viewport colormaps."

### 5.9 Performance, latency and async monitoring

- **Nielsen 1993**, *Response Times: The 3 Important Limits* (NN/g): 0.1 s "feel that the system is reacting instantaneously"; 1.0 s "flow of thought to stay uninterrupted"; 10 s "keeping the user's attention". "Percent-done progress indicators should be used for operations taking more than about 10 seconds". For 2–10 s, a busy cursor plus a fast counter. When the total is unknown, show absolute progress.
- **Card, Robertson & Mackinlay 1991**, *The Information Visualizer*, CHI '91 pp. 181–186, doi:10.1145/108844.108874: the same 0.1 / 1 / 10 s time constants for animation, response and unit task (title and DOI verified; constants as commonly cited).
- **Frame budget:** 60 Hz gives 16.7 ms per frame for everything, UI plus scene. The skill's "<0.2 ms" for clipped tables is unsourced. Set a measured budget per panel under SESKA gap G19.
- **Async monitoring (SESKA rules):** coalesce progress events to the newest value. Never drop completion, error or cancellation events. Use bounded queues. File-change notifications are only hints. Logs are not a completion protocol: two runtimes write `log<rank>.dat`, and logs can hold several runs. Job state comes from the `seska-run` supervisor (`run.json`, exit codes 0–5). This **refines** the skill's "lock-free SPSC queues or file tailing": SPSC is fine for telemetry, but completion goes through the supervisor.

---

## 6. Proposed SKILL.md edits (concise; detail goes to references)

Keep the entry point short. Add a **References** section and move the substantive detail into new files under `references/`. These are suggested files (not created by this research): `imgui-api-notes.md`, `colormaps-and-legends.md`, `mesh-quality-metrics.md`, `solver-diagnostics-petsc.md`, `accessibility-and-hci.md`, `seska-profile.md`. Validate with the skill validator after editing.

**E1. §1, replace the four readiness bullets with:**

```markdown
* **Stateful Model Tree (shape + colour + text; never colour alone):** Each node shows *Definition* (Ok ✓ / Underdefined ○ / Warning ▲ / Error ✕ / Suppressed ⊘), *Freshness* (Needs update ↻ when an upstream revision changed) and, on run nodes, *Job state* (Not run / Running / Completed / Failed / Cancelled / Interrupted / Unknown). Diagnostics appear as child nodes and in the Diagnostics panel. Semantics follow ANSYS Mechanical tree conventions and COMSOL error/warning nodes; see `references/accessibility-and-hci.md`.
```

**E2. §1 Smart Gatekeeping, replace the heading and first bullet with:**

```markdown
* **Validation gate with power-user path (Abaqus Data Check precedent):**
  * Provide `[Validate]` (a data check that writes nothing to the run) separate from `[Run]`. Disable `[Run]` while blocking errors exist; show blockers via `IsItemHovered(ImGuiHoveredFlags_ForTooltip | ImGuiHoveredFlags_AllowWhenDisabled)` and list them in Diagnostics (keyboard-reachable). Modules stay freely selectable; the pipeline guides, it does not lock.
```

**E3. §1 Set-Based Associativity, append:**

```markdown
  Picking may create features directly (PrePoMax pattern); the workbench creates the named set implicitly and compiles it to engine IDs through a reversible, recorded map.
```

**E4. §3 heatmaps, replace the first bullet with:**

```markdown
  * 1-click quality modes with the metric named by source, e.g. **Scaled Jacobian (Verdict, corner-based)**, **SICN/SIGE (Gmsh)**, **Aspect ratio**, **Skew (state definition)**, **Min dihedral angle**. Values < 0 mean inverted: always error colour + hatch. Default thresholds come from the Verdict "Acceptable" ranges; for quadratic elements use a bound-based min-Jacobian check. See `references/mesh-quality-metrics.md`.
```

**E5. §3 histogram, replace "Clicking or dragging across a histogram bin" with:**

```markdown
  Two draggable thresholds (`ImPlot::DragLineX`) or a `DragRect` select a value range; …
```

**E6. §4, replace "Crinkle Slice toggle …" with:**

```markdown
  **Crinkle** toggle (ParaView names: *Crinkle clip* on Clip, *Crinkle slice* on Slice) that keeps whole intersected cells instead of cutting them.
```

**E7. §4, replace the ViewManipulate clause with:**

```markdown
  a view cube (`ImGuizmo::ViewManipulate`: 26 click targets, corners give isometric views; note Autodesk ViewCube patent warning in its header) plus explicit `Ortho/Persp` and `Fit` commands.
```

**E8. §5 Tier 1, replace the three example translations with:**

```markdown
    * Translations are **hypotheses with evidence**, never assertions. Map `KSP_DIVERGED_PC_FAILED` + `PC_FACTOR_*_ZEROPIVOT` (or MUMPS INFOG) to "matrix singular or nearly singular: check rigid-body constraints, disconnected parts, zero-stiffness materials" and link to the pre-solve constraint check; name a node/DOF only through a verified equation→DOF map (PETSc notes zero pivots can occur for non-singular matrices). Show when the engine *accepted* a non-converged linear solve. See `references/solver-diagnostics-petsc.md`.
```

**E9. §5 Tier 2, replace with:**

```markdown
  * **Tier 2 (raw, collapsible):** the exact engine lines, PETSc reason names *as reported by that engine* (do not synthesise SNES reasons for engines that run their own Newton loop), supervisor exit code and run ID.
```

**E10. §5 monitor, append:**

```markdown
  * Keep separate axes for accepted increment, Newton iteration, inner linear iterations and physical time/load factor; label each norm (absolute vs relative, reference denominator, threshold). Progress events may be coalesced; completion/error/cancel events must never be dropped; job state comes from the supervisor, not from log text.
```

**E11. §6 colormaps, replace the first bullet with:**

```markdown
  * **Never default to Rainbow/Jet.** Defaults: **viridis** (sequential), **cividis** (CVD-safe), **Fast / Cool-to-Warm** (diverging; only for signed fields with a meaningful centre). **Turbo** is optional and labelled "not perceptually uniform". One LUT definition feeds both the GPU texture and the ImPlot legend (`ImPlot::AddColormap`). See `references/colormaps-and-legends.md`.
```

**E12. §6 averaging, replace with:**

```markdown
* **Recovery & Averaging Modes (not shading):** explicit modes for Gauss-point, element-nodal (extrapolated), and nodal-averaged values; averaging limited to result regions (material/section) by default, with a visible averaging threshold and invariant-before/after-averaging order (Abaqus precedent). Unaveraged jumps are a *refinement indicator* (Zienkiewicz–Zhu), not proof of error.
```

**E13. §6 legend, insert after the first sentence:**

```markdown
  The legend always shows quantity, unit, association/recovery mode, step and physical time, and the colours for missing / below / above range (below-range colour ≥ 3:1 against the background).
```

**E14. §6 deformation, replace the parenthetical with:**

```markdown
  (`1.0×` for large-displacement analyses; auto-scale so max deformation ≈ 10% of the largest model dimension for small-deformation analyses — Abaqus defaults; viewport shows "×α display only"; probes return physical displacement).
```

**E15. §7, replace the input gating bullet with:**

```markdown
* **Viewport Input Gating:** picking/camera run only when `viewportHovered && !ImGuizmo::IsOver() && !ImGuizmo::IsUsingAny() && !ImGuizmo::IsViewManipulateHovered()`, where `viewportHovered` comes from `IsItemHovered()` on the viewport image (render-to-texture) or `!io.WantCaptureMouse` (passthru central node). Always forward input to ImGui.
```

**E16. §7, replace the table bullet's flag with:**

```markdown
  `BeginTable("Inspector", 2)` + `TableSetupColumn(…, ImGuiTableColumnFlags_WidthStretch, 0.38f/0.62f)`; units come from the model's declared unit system ("unit unknown" if undeclared).
```

**E17. §7 clipper, replace "(< 0.2 ms …)" with:**

```markdown
  (uniform row height required; flatten trees to a visible-row index; budgets measured, not assumed).
```

**E18. Insert a new §8 before EOF:**

```markdown
## 8. Interaction, Accessibility & Provenance
* Shortcuts via `ImGui::Shortcut()`/`SetNextItemShortcut()`, a searchable command palette showing shortcuts, keyboard navigation with visible focus.
* Undo/redo = core command transactions, journaled as replayable script (Abaqus .jnl / FreeCAD transactions precedent).
* Latency classes: feedback ≤ 0.1 s; view/field switch ≤ 1 s; > 10 s gets progress + cancel.
* Shape + colour + text for every status; text ≥ 4.5:1, glyphs ≥ 3:1; targets ≥ 24 px (scaled).
* Every result view shows run ID, model revision and solver build; a stale banner appears when the model changed after the run.
* Project profiles: `references/seska-profile.md`.
```

**E19. Front-matter `description`:** optionally append "Includes a SESKA FEA suite profile". Bump `version` to 2.1.0 when the edits land.

---

## 7. Step 3: SESKA application

### 7.1 UX planning checklist (SESKA frontend)

Each item cites its SESKA source. Mark design statements Required, Proposed, Observed or Engine-dependent, as the root `AGENTS.md` requires.

**Scope and contracts**

- [ ] The first milestone is **import → validate → run via `seska-run` → admit results** of a supplied case, not geometry or meshing (architecture §Executive summary; G18).
- [ ] Only show the field catalogue entries that passed their contract gate: displacement, Cauchy stress, von Mises, pressure, log strain. Mark others "awaiting contract" (architecture §Field metadata, G06).
- [ ] Element support UI matches the engine: TET4/TET10/HEX8/HEX27, single type per mesh. HEX20 is shown as unsupported until the engine supports it (`commonFunctions.C getFEMMeshData`). Native admission currently covers HEX8, quadrature order 2 (`backend/README.md`).
- [ ] Units: a project unit system is required before export. Show "unit unknown" otherwise (architecture §Units).
- [ ] BC/load binding: named sets compile to explicit surface-element IDs, with a visible map. Show 1-based input IDs vs 0-based log IDs consistently (architecture §Observations).

**Model tree and validation**

- [ ] Three-indicator nodes (Definition / Freshness / Job) with shape + colour + text (§5.4, §5.8).
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

### 7.2 Draft screen and panel inventory

| # | Panel / screen | Dock | Purpose | Key content | SESKA grounding | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Workspace launcher | modal at start | Open/create a workspace; reconcile runs | Recent projects, schema/migration notice, run reconciliation summary | architecture §Workspace resolution | Proposed |
| 2 | Case import | dialog | Import `mesh.dat`/`input.dat` pairs and auxiliary files | File pair, hashes, parse diagnostics, element type/order, counts | RESEARCH_SESKA_CASES §4 | Proposed |
| 3 | Model tree | left | Hierarchy: Mesh, Materials, Sets/Surfaces, Constraints, Loads, Steps/Control, Contact, Analyses → Runs → Results | Three-indicator glyphs, diagnostic child nodes | spec §CAE Scene Graph; architecture §Engineering components | Proposed |
| 4 | Sets and surfaces manager | left (below tree) | Named sets ↔ engine surface/element IDs | ID map, counts, emptiness warnings, isolate/colour | architecture §Observations | Proposed |
| 5 | Property inspector | right | Edit the selected entity | Two-column table, units from the project, inline validation, collapsible advanced numerics (PETSc/`directSolver`, tolerances) | input.dat keys (e.g. `convergenceCriterion`, `directSolver`) | Proposed |
| 6 | Material editor | right (tab) | Constitutive law and parameters | Law selector restricted to the engine contract (`constitutiveLawID`), parameter ranges, curve preview (ImPlot) | G09 | Engine-dependent |
| 7 | 3D viewport | centre | Scene, picking, glyphs, fields | Selection-filter HUD, render-mode HUD, view cube, section tool, legend, ×α badge, provenance strip | spec §3D Viewport | Proposed |
| 8 | Mesh quality | bottom (tab) + viewport mode | Metric heatmap and histogram | Metric selector (named source), thresholds, invalid count, save as set | §5.3 | Proposed |
| 9 | Validate / Diagnostics | bottom (tab) | Pre-solve and run diagnostics | Severity, message, entity links, auto-created error sets, truncation notice | §5.4 Abaqus Job Monitor | Proposed |
| 10 | Run setup | dialog/right | Configure a `seska-run` launch | Ranks, timeout, MPI path, output dir (must be new), frozen revision summary | `SeskaRun.cpp` options | Proposed |
| 11 | Jobs | bottom (tab) | Lifecycle and control | State, elapsed, ranks, exit code text, cancel/force, open run dir, `--validate` result | architecture §Job lifecycle; README exit codes | Proposed |
| 12 | Convergence monitor | bottom (tab) | Telemetry | Residual ratio (log), criteria lines, iterations/step, linear iterations, solver package, yielded GPs, cut-backs | `log0.dat` structure | Proposed |
| 13 | Solver output | bottom (tab) | Raw stdout/stderr and per-rank logs | Clipped log viewer, rank selector, search, Tier-2 raw lines | RESEARCH_SESKA_CASES §6.2 | Proposed |
| 14 | Results browser | left (Results branch) | Steps × fields | Admitted steps only, field metadata, recovery mode | architecture §Result model | Proposed |
| 15 | Legend and colormap editor | viewport overlay + popover | Colour mapping | Map choice, min/max, bands, out-of-range colours, CVD preview | §5.2 | Proposed |
| 16 | Probe and path plots | bottom (tab) | Details on demand | Probe table (CSV export), path plot (ImPlot), physical vs display coordinates | spec §Interactive probing (skill) | Proposed |
| 17 | Graphs | bottom (tab) | `.grf` histories | Load–deformation curves with correct axis labels | `Graph.C` | Proposed |
| 18 | Lua console / journal | bottom (tab) | Scripting and replay | Command journal, replay, script run with budget/cancel | spec §Lua API; G15 | Proposed |
| 19 | Terminal | bottom (tab) | Convenience shell | User-selected shell; never drives job state | frontend `AGENTS.md` | Proposed |
| 20 | Preferences | dialog | Navigation preset, theme, DPI/font scale, shortcuts, colormap defaults | Light/dark tokens checked ≥ 3:1 and ≥ 4.5:1 | §5.8 | Proposed |
| 21 | Command palette | overlay (Ctrl+Shift+P, proposed) | Expert access | Fuzzy command search with shortcuts | Cockburn et al. 2014 | Proposed |

---

## 8. Source list

**Repository (local, read-only)**

- `seskafeasuite/AGENTS.md`; `seskafeasuite/frontend/AGENTS.md`; `seskafeasuite/frontend/README.md`
- `seskafeasuite/docs/spec/SESKAFEA_SPEC_DOCUMENT.md`
- `seskafeasuite/docs/architecture/SYSTEM_ARCHITECTURE_AND_DESIGN.md`; `ARCHITECTURE_GAPS.md`; `RESEARCH_SESKA_CASES_AND_RUNTIME.md`
- `seskafeasuite/backend/README.md`; `backend/src/seskaIntegration/SeskaRun.cpp`; `ResultValidation.h`
- `seskafeasuite/backend/seska/src/common/PETScFunctions.C`; `commonFunctions.C`; `src/simulation/Simulation.C`; `src/equationSystem/CommonEQSet.C`; `src/preProcessing/FEMGeometry/FEMGeometry.C`
- `seskafeasuite/backend/seska/examples/variable-modulus-examples/cantileverBeam.gid/log0.dat`; `backend/seska/seska.gid/`

**Dear ImGui / ImPlot / ImGuizmo**

- <https://github.com/ocornut/imgui/blob/docking/imgui.h> (1.93.1 WIP); <https://github.com/ocornut/imgui/blob/docking/docs/FAQ.md> (§How should I handle DPI; §WantCaptureMouse); <https://github.com/ocornut/imgui/blob/docking/docs/BACKENDS.md>
- <https://github.com/epezent/implot/blob/master/implot.h> (1.1 WIP; release v1.0)
- <https://github.com/CedricGuillemet/ImGuizmo/blob/master/src/ImGuizmo.h> and `src/ImGuizmo.cpp`

**Colour**

- van der Walt & Smith, mpl colormaps: <https://bids.github.io/colormap/>
- Matplotlib, Choosing Colormaps: <https://matplotlib.org/stable/users/explain/colors/colormaps.html>
- Moreland 2009, doi:10.1007/978-3-642-10520-3_9; <https://www.kennethmoreland.com/color-maps/>; <https://www.kennethmoreland.com/color-advice/>
- Samsel, Scott & Moreland 2024, IEEE CG&A, doi:10.1109/MCG.2024.3383137; ParaView 6.0.1 notes <https://www.kitware.com/paraview-6-0-1-release-notes/>
- Mikhailov 2019, <https://research.google/blog/turbo-an-improved-rainbow-colormap-for-visualization/>
- Borland & Taylor 2007, IEEE CG&A 27(2):14–17, doi:10.1109/MCG.2007.323435
- Ware, Stone & Szafir 2023, IEEE CG&A, doi:10.1109/MCG.2023.3246111
- Crameri, Shephard & Heron 2020, Nat. Commun. 11:5444, doi:10.1038/s41467-020-19160-7 (PMC7595127)
- Nuñez, Anderton & Renslow 2018, PLOS ONE, doi:10.1371/journal.pone.0199239

**Mesh quality**

- Stimpson et al. 2007, *The Verdict Library Reference Manual*, SAND2007-2853P: <https://github.com/sandialabs/verdict> (`SAND2007-2853p.pdf`, `verdict.h`, `V_HexMetric.cpp`, `V_TetMetric.cpp`)
- Gmsh 4.15.2 reference manual: <https://gmsh.info/doc/texinfo/gmsh.html> (Mesh.QualityType; Plugin(AnalyseMeshQuality); FAQ on SICN/Gamma/SIGE; `getElementQualities`)
- Johnen, Geuzaine, Toulorge & Remacle 2018, CAD, doi:10.1016/j.cad.2018.03.001

**CAE precedents**

- Abaqus/CAE (2017 docs mirror): <https://abaqus-docs.mit.edu/2017/English/SIMACAEGSARefMap/simagsa-c-abswhatisamodule.htm>; …/SIMACAEGSARefMap/simagsa-t-abscheckinput.htm; …/SIMACAECAERefMap/simacae-c-anaconcmonitor.htm; …/simacae-t-resaverage.htm; …/simacae-c-resconceptaverage.htm; …/simacae-t-customdeffactorframe.htm; …/simacae-c-dbsconcfilesgenerated.htm; 2025: <https://docs.software.vt.edu/abaqusv2025/English/SIMACAECAERefMap/simacae-t-resaverage.htm>
- ANSYS Mechanical tree conventions: <https://ansyshelp.ansys.com/public/Views/Secured/corp/v261/en/wb_sim/ds_Outline_Conventions.html>
- COMSOL 6.4 Errors, Warnings, and Information: <https://doc.comsol.com/6.4/doc/com.comsol.help.comsol/comsol_ref_modeling.19.020.html>
- ParaView Filtering Data: <https://docs.paraview.org/en/latest/UsersGuide/filteringData.html>
- PrePoMax manual v2.4.0: <https://prepomax.fs.um.si/wp-content/uploads/2025/10/PrePoMax-v2.4.0-manual.pdf>
- FreeCAD source: <https://github.com/FreeCAD/FreeCAD/blob/main/src/App/Document.h>; <https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Fem/femtools/checksanalysis.py>

**PETSc**

- <https://gitlab.com/petsc/petsc/-/blob/release/include/petscksp.h>; `petscsnes.h`; `petscpctypes.h`
- <https://petsc.org/release/manual/ksp/> (Convergence Tests; Convergence Monitoring; direct solvers/zero pivots)
- <https://petsc.org/release/manual/snes/#convergence-tests>
- <https://petsc.org/release/manualpages/Mat/MATSOLVERMUMPS/>

**Results science**

- Zienkiewicz & Zhu 1987, IJNME 24:337–357, doi:10.1002/nme.1620240206; Zienkiewicz & Zhu 1992, IJNME 33:1365–1382 (Part 2), doi:10.1002/nme.1620330703

**HCI, accessibility and performance**

- Nielsen, 10 Usability Heuristics: <https://www.nngroup.com/articles/ten-usability-heuristics/>
- Nielsen, Response Times: <https://www.nngroup.com/articles/response-times-3-important-limits/>
- Shneiderman 1996, doi:10.1109/VL.1996.545307
- Cockburn, Gutwin, Scarr & Malacria 2014, ACM Comput. Surv. 47(2), doi:10.1145/2659796
- Card, Robertson & Mackinlay 1991, CHI '91, doi:10.1145/108844.108874
- WCAG 2.2 (W3C Rec. 12 Dec 2024): <https://www.w3.org/TR/WCAG22/>; <https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html>
- ISO 9241-110:2020: <https://www.iso.org/standard/75258.html> (contents UNVERIFIED)

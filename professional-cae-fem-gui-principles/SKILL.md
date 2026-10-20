---
name: professional-cae-fem-gui-principles
description: Use this skill when designing, architecting, or reviewing Dear ImGui desktop applications for Finite Element Method (FEM/FEA) pre- and post-processing, CAD/CAE workbenches, computational mechanics tools, or scientific visualization suites (C++/Vulkan/OpenGL/DirectX). Combines immediate-mode mechanical sympathy with industry-standard CAE workflows (Abaqus, ANSYS, ParaView, Gmsh, PrePoMax). Includes a SESKA FEA suite profile for planning and drafting the seskafeasuite frontend UX.
metadata:
  version: "2.1.0"
---

# ImGui FEM & Computational Mechanics Workbench UX

## When to Apply

Trigger this skill when designing, implementing, or reviewing:

* 3D Finite Element Method (FEM/FEA) pre-processors, solver monitors, and post-processors in Dear ImGui.
* Scientific visualization viewports, mesh quality inspectors, constitutive material editors, and boundary condition tools.
* High-density engineering property panels, node/element tables, and real-time MPI/PETSc convergence plots (`ImPlot`).
* Custom 3D viewport overlays, coordinate triads, clipping planes, and transformation gizmos (`ImGuizmo` or a custom glyph pipeline).

## References

Load only what the task needs:

* **SESKA FEA suite (`seskafeasuite`):** read [references/seska-profile.md](references/seska-profile.md) first. It holds the verified engine facts, the UX planning checklist, and the draft 21-panel inventory. Its facts override generic guidance below.
* **Evidence and primary sources:** [references/research-ux-enrichment-2026-10-16.md](references/research-ux-enrichment-2026-10-16.md). Section pointers below use the form "research §N". Items marked UNVERIFIED there are not facts.
* Numeric figures without a cited source (viewport share, glyph pixel clamp, band counts, frame budgets) are configurable defaults to measure, not rules.

## Core Philosophy

Finite Element software bridges abstract continuum mechanics and partial differential equations with concrete 3D spatial geometry. The UI must enforce **error-preventing sequential logic** without sacrificing **power-user flexibility** or **60+ FPS viewport responsiveness**. Every pixel outside the 3D viewport must earn its place through dense, scannable, aligned technical data.

---

## 1. Process-Driven CAE Workflow (The Non-Destructive Pipeline)

FEM simulations follow a strict physical dependency graph. The interface must guide users through this pipeline while handling upstream modifications gracefully.

* **Canonical 6-Stage Pipeline:**
  `1. Geometry/Mesh Import` → `2. Material & Section Assignment` → `3. Assembly & Sets` → `4. Steps & Boundary Conditions/Loads` → `5. Solver & MPI Configuration` → `6. Post-Processing`.
  Products without a mesher start at import of an existing mesh and input deck.
* **Stateful Model Tree (shape + colour + text; never colour alone):** Each node shows *Definition* (Ok ✓ / Underdefined ○ / Warning ▲ / Error ✕ / Suppressed ⊘), *Freshness* (Needs update ↻ when an upstream revision changed) and, on run nodes, *Job state* (Not run / Running / Completed / Failed / Cancelled / Interrupted / Unknown). Diagnostics appear as child nodes and in the Diagnostics panel. Semantics follow ANSYS Mechanical tree conventions and COMSOL error/warning nodes; see research §5.4 and §5.8.
* **Validation gate with power-user path (Abaqus Data Check precedent):**
  * Provide `[Validate]` (a data check that writes nothing to the run) separate from `[Run]`. Disable `[Run]` while blocking errors exist; show blockers via `IsItemHovered(ImGuiHoveredFlags_ForTooltip | ImGuiHoveredFlags_AllowWhenDisabled)` and list them in Diagnostics (keyboard-reachable). Modules stay freely selectable; the pipeline guides, it does not lock.
  * Always provide a secondary `[Preview / Export Solver Deck]` inspector so advanced computational engineers can inspect or manually edit the raw input files (`mesh.dat`, solver control parameters) before execution.
* **Set-Based Associativity:** Bind boundary conditions, loads, and material assignments to named **Node Sets (`NSET`)** and **Element/Surface Sets (`ELSET`/`SURF`)** rather than raw ephemeral indices whenever possible.
  Picking may create features directly (PrePoMax pattern); the workbench creates the named set implicitly and compiles it to engine IDs through a reversible, recorded map.

---

## 2. Spatial Architecture & Contextual Cognitive Load Reduction

Prevent "button fatigue" by surfacing only tools relevant to the active workflow phase while preserving maximum 3D viewport real estate.

* **Viewport Supremacy:** The central `DockSpaceOverViewport` (`ImGuiDockNodeFlags_PassthruCentralNode`) should occupy most of the window (default target 75–85%, configurable). Never obscure the 3D mesh with blocking modal dialogs unless confirming irreversible data deletion.
* **Canonical 4-Zone Workbench Layout:**
  1. **Top Contextual Ribbon / Module Bar:** A compact module selector (`Pre-Process` | `Mesh` | `Solve` | `Post-Process`) that dynamically swaps the 1-row icon action toolbar to match the active stage. Icons default to `24x24` logical pixels. Scale fonts with `style.FontScaleDpi` (Dear ImGui 1.92+) and sizes/padding with `style.ScaleAllSizes()`; ship a Windows DPI-awareness manifest.
  2. **Left Dock (Model Tree & Selection Sets):** Hierarchical model tree on top; Named Node/Element/Surface Sets manager below.
  3. **Right Dock (Context-Sensitive Property Inspector):** Two-column property table inspecting the active selection (see §7).
  4. **Bottom Dock (Telemetry, Convergence, Diagnostics & System Terminal):** Tabbed workspace containing:
     * **Live Solver Output:** Structured read-only stream of the active solver run.
     * **Newton-Raphson Residual Convergence (`ImPlot`):** Real-time residual and time-step plots.
     * **Element Quality Histograms (`ImPlot`):** Interactive mesh quality distribution.
     * **Clickable Diagnostic Warnings:** Validation and solver error summary with 3D entity links.
     * **Integrated System Terminal:** Multi-tabbed, OS-native interactive shell (`pwsh.exe` / PowerShell 7 and `powershell.exe` 5.1 on Windows via ConPTY; `bash` on Linux and `zsh` on macOS). It is a convenience only: it never launches managed jobs or drives job state, which comes only from the job supervisor.
* **Automatic Topological Selection Filters (HyperMesh / Gmsh Pattern; precedent UNVERIFIED):**
  * Render a persistent floating HUD pill-bar at the top-center of the 3D viewport: `[Vertex/Node] [Edge] [Surface/Face] [Element/Volume] | [Box Select] [Visible Only]`.
  * Automatically switch the active picking filter when a tool is invoked (e.g., activating `Pressure Load` auto-locks picking to `Surface/Face`; activating `Nodal Displacement` auto-locks to `Vertex/Node`), while allowing manual override.
* **Progressive Disclosure for Constitutive & Solver Settings:**
  * Expose primary physical parameters (e.g., Constitutive Model selector, Young's Modulus $E$, Poisson's ratio $\nu$, Density $\rho$) immediately.
  * Group advanced continuum and numerical parameters (e.g., Prony viscoelastic relaxation spectra, plasticity hardening tables, PETSc KSP/PC flags, line-search damping, MPI rank count) inside clean collapsible `ImGui::CollapsingHeader` sub-cards with sensible defaults pre-populated.

---

## 3. Immediate Visual Verification & Pre-Solve Diagnostics

Catch physical, geometric, and unit errors *before* launching an expensive multi-rank MPI solve.

* **Screen-Space-Normalized 3D Symbolic Glyphs (Abaqus / ANSYS Pattern):**
  * Render boundary conditions and loads using distinct, color-coded instanced 3D glyphs: cones/wedges for translational/rotational constraints ($u_x, u_y, u_z$), single-headed arrows for concentrated/distributed forces, and double-headed arrows for moments.
  * Clamp glyph scaling in the vertex shader to screen-space pixel bounds (default `24px–48px`, configurable) so symbols remain crisp and legible whether zoomed into a single finite element or viewing the entire structure.
* **Interactive Mesh Quality Heatmaps & Histograms (Gmsh / Verdict):**
  * 1-click quality modes with the metric named by source, e.g. **Scaled Jacobian (Verdict, corner-based)**, **SICN/SIGE (Gmsh)**, **Aspect ratio**, **Skew (state definition)**, **Min dihedral angle**. Values < 0 mean inverted: always error colour + hatch. Default thresholds come from the Verdict "Acceptable" ranges; for quadratic elements use a bound-based min-Jacobian check. See research §5.3.
  * Pair the 3D view with an `ImPlot` histogram in the bottom dock. Two draggable thresholds (`ImPlot::DragLineX`) or a `DragRect` select a value range (e.g., scaled Jacobian < 0.1); the selection must isolate those elements in full opacity while ghosting the rest of the mesh at 10% alpha, and can be saved as a named set.
* **Real-Time Physical & Thermodynamic Input Validation:**
  * Validate inputs keystroke-by-keystroke. Highlight invalid input frames with a `#F85149` red border, an error glyph, and immediate inline explanation—never wait for a dialog box.
  * Enforce continuum mechanics bounds: e.g., $E > 0$, $-1.0 < \nu < 0.5$ (warn on $\nu \to 0.5$ regarding volumetric locking unless mixed/hybrid elements are selected), positive-definite relaxation moduli, and strictly positive time-step increments $\Delta t > 0$.
  * Run pre-solve checks the solver cannot do cheaply: unconstrained rigid-body modes (connectivity components × constrained DOFs), conflicting Dirichlet sets, empty sets, and unit consistency.

---

## 4. Direct 3D Manipulation, Clipping & CAD Navigation

* **Configurable Camera Navigation Presets:** Support switchable mouse-orbit conventions in Preferences (**SolidWorks**, **Abaqus/CATIA**, **Blender/ParaView**) with a persistent orientation control anchored in the top-right corner of the viewport (`100x100px`): a view cube (`ImGuizmo::ViewManipulate`: 26 click targets, corners give isometric views; note Autodesk ViewCube patent warning in its header) plus explicit `Ortho/Persp` and `Fit` commands.
* **Exploded, Ghosted & Cross-Section Views (ParaView Pattern):**
  * Provide a viewport HUD toggle bar for render modes: `Wireframe`, `Surface with Edges` (default for FEA), `Smooth Shaded`, `Feature Edges Only`, and `X-Ray / Ghosted (20% Alpha)`.
  * Include an interactive **Section Clipping Plane** (plane handle + `[Flip Normal]` + **Crinkle** toggle (ParaView names: *Crinkle clip* on Clip, *Crinkle slice* on Slice) that keeps whole intersected cells instead of cutting them).

---

## 5. Actionable Error Handling & Live Solver Telemetry

Translate abstract numerical failures into actionable physical and topological diagnostics while preserving raw solver transparency.

* **Interactive Spatial Error Hyperlinks:**
  * Parse solver logs (`seska-run`, PETSc stderr/stdout) for entity identifiers (`Node #ID`, `Element #ID`, `DOF`, `Rank #ID`), respecting the engine's index base (e.g. 1-based input vs 0-based log IDs).
  * Render these in the Diagnostics panel as clickable links. Clicking `Element 4092 (Negative Jacobian)` must smoothly animate the 3D camera target to the centroid of `Element 4092`, highlight its wireframe in pulsing red, and ghost the surrounding mesh.
  * Collect diagnostic-referenced entities into an auto-created temporary error set (Abaqus Job Monitor precedent) for isolate, colour, and export.
* **Two-Tier Numerical-to-Physical Translation:**
  * **Tier 1 (Physical Diagnosis Banner):**
    * Translations are **hypotheses with evidence**, never assertions. Map `KSP_DIVERGED_PC_FAILED` + `PC_FACTOR_*_ZEROPIVOT` (or MUMPS INFOG) to "matrix singular or nearly singular: check rigid-body constraints, disconnected parts, zero-stiffness materials" and link to the pre-solve constraint check; name a node/DOF only through a verified equation→DOF map (PETSc notes zero pivots can occur for non-singular matrices). Show when the engine *accepted* a non-converged linear solve. See research §5.5.
  * **Tier 2 (raw, collapsible):** the exact engine lines, PETSc reason names *as reported by that engine* (do not synthesise SNES reasons for engines that run their own Newton loop), supervisor exit code and run ID.
* **Real-Time MPI Solver Monitor (`ImPlot`):**
  * Stream solver progress asynchronously via lock-free SPSC queues or file tailing without blocking the UI thread.
  * Plot live **Newton-Raphson Force/Displacement Residual Norms ($\log_{10} \Vert{}\mathbf{R}\Vert{}_2$)** per iteration alongside **Time Step $\Delta t$ evolution** and active MPI rank utilization.
  * Keep separate axes for accepted increment, Newton iteration, inner linear iterations and physical time/load factor; label each norm (absolute vs relative, reference denominator, threshold). Progress events may be coalesced; completion/error/cancel events must never be dropped; job state comes from the supervisor, not from log text.

---

## 6. High-Fidelity Post-Processing & Scientific Visualization (ParaView / Abaqus Standards)

* **Perceptually Uniform & Iso-Banded Colormaps:**
  * **Never default to Rainbow/Jet.** Defaults: **viridis** (sequential), **cividis** (CVD-safe), **Fast / Cool-to-Warm** (diverging; only for signed fields with a meaningful centre). **Turbo** is optional and labelled "not perceptually uniform". One LUT definition feeds both the GPU texture and the ImPlot legend (`ImPlot::AddColormap`). See research §5.2.
  * Provide a **Discrete Iso-Band Toggle (default 12 or 16 quantized steps, configurable)** vs. **Continuous Gradient**, as engineers rely on discrete contour bands to read stress concentrations accurately.
* **Recovery & Averaging Modes (not shading):** explicit modes for Gauss-point, element-nodal (extrapolated), and nodal-averaged values; averaging limited to result regions (material/section) by default, with a visible averaging threshold and invariant-before/after-averaging order (Abaqus precedent). Unaveraged jumps are a *refinement indicator* (Zienkiewicz–Zhu), not proof of error.
* **Interactive Viewport Probing & Path Plots:**
  * Follow overview first, zoom and filter, then details-on-demand (Shneiderman): whole-model view and legend, then threshold/isolate, then probe.
  * Hovering over the mesh in Probe Mode displays a compact floating tooltip with `Node/Elem ID`, undeformed/deformed coordinates $(X, Y, Z)$, and the exact scalar/tensor value at that point.
  * Clicking pins persistent callout labels to the 3D view or appends values to a tabular probe list exportable to CSV.
* **Dynamic Legend & Threshold Control:**
  * Render an interactive color bar legend overlay inside the viewport with editable `Min`/`Max` clamping inputs, scientific notation formatting (`%.3e`), and customizable out-of-bounds colors (e.g., `#FF00FF` Magenta for values exceeding yield stress, `#404040` Grey for values below threshold). The legend always shows quantity, unit, association/recovery mode, step and physical time, and the colours for missing / below / above range (below-range colour ≥ 3:1 against the background). Never draw missing values as zero.
  * Include a **Deformation Scale Factor** control (`1.0×` for large-displacement analyses; auto-scale so max deformation ≈ 10% of the largest model dimension for small-deformation analyses — Abaqus defaults; viewport shows "×α display only"; probes return physical displacement) and harmonic/time-step animation playback controls (`|<`, `<`, `Play/Pause`, `>`, `>|`, loop mode). Label interpolated animation frames so they never pass for solver steps.

---

## 7. Dear ImGui Implementation & Mechanical Sympathy Rules

* **Two-Column Property Tables:** Align all inspector panels using `BeginTable("Inspector", 2)` + `TableSetupColumn(…, ImGuiTableColumnFlags_WidthStretch, 0.38f/0.62f)`; units come from the model's declared unit system ("unit unknown" if undeclared). Use left-aligned labels and full-width widgets (`ImGui::SetNextItemWidth(-FLT_MIN)`), with the unit inside every numeric widget format string.
* **Zero-Allocation Immediate-Mode Loop:** Never allocate heap memory (`std::string`, `std::vector`) per frame inside UI rendering code. Use stack buffers (`char buf[128]; snprintf(...)`) and `ImGui::PushID(int_id)` inside loops.
* **Mandatory List Clipping (`ImGuiListClipper`):** Wrap all node/element spreadsheets, set inspection lists, and solver log viewers in `ImGuiListClipper` so tables with $10^6+$ rows render in $O(\text{visible rows})$ time (uniform row height required; flatten trees to a visible-row index; budgets measured, not assumed). Keep pinned rows visible with `IncludeItemByIndex()`.
* **Viewport Input Gating:** picking/camera run only when `viewportHovered && !ImGuizmo::IsOver() && !ImGuizmo::IsUsingAny() && !ImGuizmo::IsViewManipulateHovered()`, where `viewportHovered` comes from `IsItemHovered()` on the viewport image (render-to-texture) or `!io.WantCaptureMouse` (passthru central node). Always forward input to ImGui.

---

## 8. Interaction, Accessibility & Provenance

* Shortcuts via `ImGui::Shortcut()`/`SetNextItemShortcut()`, a searchable command palette showing shortcuts, keyboard navigation with visible focus.
* Undo/redo = core command transactions, journaled as replayable script (Abaqus .jnl / FreeCAD transactions precedent).
* Latency classes: feedback ≤ 0.1 s; view/field switch ≤ 1 s; > 10 s gets progress + cancel.
* Shape + colour + text for every status; text ≥ 4.5:1, glyphs ≥ 3:1; targets ≥ 24 px (scaled).
* Every result view shows run ID, model revision and solver build; a stale banner appears when the model changed after the run.
* Project profiles: `references/seska-profile.md`.

---
name: boq-print-standardise
description: Standardise a Bill of Quantities workbook so every sheet shares one column layout, header, Arial 10 formatting, borders, typed "Page No. X/Y" footers and A4 print setup, and the collection/summary totals chain has no double counts.
---

## When to use

Use on a multi-sheet Bill of Quantities (BOQ) that has to print to PDF predictably. Trigger phrases: "standardise the BOQ", "fix BOQ formatting", "make the bills print properly", "fix the page numbers / footers", "BOQ house style".

## Inputs

- `workbook`: the open BOQ (all sheets unless the user names a subset).
- `bill numbering`: which sheets form which bill (e.g. 1 Preliminaries, 2 Hostel Building [several trade sheets + its Summary], 3 Storm Water, 4 Foul Drainage, 5 Double VIP, 6 Borehole, then Main Summary). Ask for this. Never guess it.

## Goal

Every sheet prints on A4 portrait with the same title row, header row, column layout, fonts, borders, page breaks and sequential typed page footers. Every page total flows exactly once: page → collection → bill summary → main summary. No #REF!/#VALUE! errors. No merged cells. No content outside the print area.

## House style (apply identically to every sheet)

| Item | Spec |
| --- | --- |
| Columns | A Item · B Description · C Qty · D Unit · E Rate (MK) · F Amount (MK). On a bill summary sheet: C = Page Ref (centred across C:E), F = Amount |
| Widths (pt) | A 32 · B 290 · C 48 · D 40 · E 70 · F 85 (total 565 pt) |
| Row 1 | Title, bold, left: `BILL NO. n: <BILL NAME> – <SECTION>` (Main Summary: `MAIN SUMMARY – <PROJECT>`), bottom border |
| Row 2 | `ITEM | DESCRIPTION | QTY | UNIT | RATE (MK) | AMOUNT (MK)`, bold, centred, fill #D9D9D9, thin borders all round |
| Font | Arial 10 on the whole sheet |
| Alignment | A, C, D centred; B left, wrap text; E, F right |
| Number formats | C `#,##0.00`; E:F `#,##0.00;(#,##0.00);"-"`; percentages `0.0%` |
| Body borders | Per page: thin left/right edge plus inside vertical lines from the first row of the page to its total row |
| Page total row | Label in B ("To Collection" or "To Summary"), bold B:F; F has a thin top border and a double bottom border |
| Footer row | Directly under each page total: B = section label (italic, e.g. "Hostel Building – Roof"), F = `Page No. b/n` (italic, right), thin top border |
| Colours (summary rows) | Inputs (qty, % rates) blue #0000FF; cross-sheet links green #008000; formulas black |
| Page setup | A4 portrait; margins L/R 36 pt, T/B 43 pt, header/footer 20 pt; centre horizontally; scale 92%; print titles `$1:$2`; print area `A1:F<last footer row>`; clear any print header/footer text; freeze rows 1–2 |

## Steps

### 1. Survey and snapshot

With `execute_office_js`, for each sheet record: which column holds Item/Desc/Qty/Unit/Rate/Amount, merged areas, header rows repeated down the sheet, page-end total rows ("To Collection", "To Summary", "Carried to…", "Total"), typed "Page No." rows, collection blocks, and existing page breaks. Save a **baseline snapshot** with `blobs.setJSON("snap", …)`: per sheet, the sorted list of all numeric formula results (rounded to 2 dp).
**Done when:** you have a per-sheet map of layout, totals and footers, and the snapshot is saved.

### 2. Audit the totals chain (flag first)

Trace each amount from page → collection → bill summary → main summary. Look for:

- a collection that includes pages from another section (e.g. Wall Finishes collection pulling in Doors & Windows and Ironmongery, which the summary also lists);
- a collection that includes another collection (e.g. a Cold & Hot Water collection that re-adds the Sanitary and Soil collections);
- a summary line pointing at the wrong section's total (e.g. Floor Finishes → a ceiling page);
- links to empty cells;
- a bill counted both inside another bill and in the main summary;
- a Qty column on the Main Summary that isn't multiplied in;
- percentages hardcoded in formulas.

Show the user a short list of these problems, then ask the bill-numbering question and present the plan in chat.
**Confirm first:** wait for the user to confirm the plan and the bill numbers, and to say which problems to fix.

### 3. Unmerge everything, then restructure columns

Unmerge `A1:<last col><last row>` on every sheet **before** moving anything. Then move, insert or delete **whole columns** so each sheet matches the house layout. Common cases: swap Unit/Qty, delete spacer columns left by merges, move description text from a merged A:B into B, shift a sheet that starts in column B. Whole-column operations keep formulas and links correct.
**Done when:** every sheet has the A–F layout, and the sorted formula results for every sheet match the snapshot exactly, with zero errors.
**Rule:** merged cells hide labels you move into them. Always unmerge first, and check `getMergedAreasOrNullObject()` returns nothing at the end.

### 4. Rebuild the page structure

Work **bottom-up** within each sheet so row numbers above stay valid:

- After every page-end total row, reuse the existing footer row or insert one, using the footer spec above.
- Delete repeated in-sheet header rows (print titles repeat rows 1–2). A header row whose B cell is a real section name becomes a bold section title instead.
- Move text labels from column A into B and strip trailing "K" markers. Clear "K" from E on total rows.
- Normalise total labels to "To Collection" or "To Summary". Label any unlabelled page total.

Number footers sequentially per bill (`Page No. 2/1…2/n` across all sheets of bill 2, in sheet order). In every collection block, set B to `=F<footer row>` of the page it collects, beside the amount link. On bill summary sheets, set column C to `='<Sheet>'!F<footer row>` of that section's last page. Page refs must never be typed text.
**Done when:** the footers read 1/1…, 2/1…2/n, … in order with no gaps; there are no typed "Page No." labels outside footer rows; totals match the snapshot.
**Produces:** a list of footer rows per sheet. Save it with `blobs.setJSON("footers", {...})`.

### 5. Write the titles and headers

Write row 1 (title) and row 2 (header) on every sheet using the house-style text. Delete leftover sub-header rows (e.g. a "(MK)" units row).
**Done when:** A1:F2 on every sheet reads exactly to spec.

### 6. Apply the formatting

For each sheet: Arial 10 on the whole sheet, reset A:F borders and fills, then apply widths, alignment, number formats, header style, per-page vertical borders, total-row borders, footer style and wrap on B. Autofit rows, then freeze rows 1–2.
**Done when:** a `get_cell_ranges` read-back of a header, a page total and a footer on a few sheets shows the specified fonts, borders and formats.

### 7. Page setup and fit check

Apply the page setup above. Remove the existing page breaks, then add a manual horizontal page break after every footer row except the last. Set print area `A1:F<last footer>`.
Fit check: (row 1+2 heights) + (rows from page start to footer) must be ≤ (841.9 − 86) / 0.92 ≈ **822 pt** for every page. Column widths must total ≤ 565 pt. If a page is over, split it: insert a "To Collection" total + footer at a sensible item boundary, and add or extend a collection page that sums the new page totals.
**Done when:** every page is ≤ 822 pt, the break count = footers − 1 on each sheet, and the used range ends at the last footer (clear stray cells beyond it).

### 8. Fix the totals the user approved

Typical fixes:

- Rebuild each collection so it lists only its own section's pages (re-point the B/F pairs, clear the extras).
- Point each summary line at its own collection.
- Main Summary: E = link to the bill total (green), F = `=C*E`, and percentages (contingency, VAT, levies) as blue inputs in E with F = base × E.
- Re-point any bill that would otherwise be counted twice (e.g. Main Summary Foul Drainage → its "To Summary", not a combined External Works total).

**Done when:** each collection reads back as only its own pages, and the summary and grand totals are re-read and reported (old → new).
**Rule:** never change a total without the user's go-ahead in step 2.

### 9. Final verification

Scan every sheet's used range for `#REF!`, `#VALUE!`, `#NAME?`, `#DIV/0!` and `#N/A`. Confirm no merged cells, footers sequential, print areas and break counts correct, every page ≤ 822 pt, and nothing outside the print area. Compare against the snapshot. The only differences should be the approved total fixes.
**Done when:** all checks pass. Report which totals changed and anything left unfixed (e.g. VAT base questions), and suggest a quick Print Preview check.

## Office.js gotchas

- Loading `horizontalPageBreaks` items and calling `getCellAfterBreak()` can throw ItemNotFound. Use `getCount()` to verify, and `removePageBreaks()` + `horizontalPageBreaks.add("A<row>")` to set breaks.
- `eval`/`AsyncFunction` aren't available in the sandbox. Write the code inline in each `execute_office_js` call. Use `blobs` to carry snapshot and footer maps between calls.
- Insert and delete rows bottom-up. After any structural change, re-read row numbers instead of reusing old ones.
- Displayed numbers follow the user's locale (e.g. `39 444 000,00`). That is expected, not an error.

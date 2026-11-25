---
name: "curate-full-doc"
description: "Adapt the Eco-Construction bid document template (.docx) to a new Malawi district council tender: government bidding document + priced BOQ in, renamed bid .docx out."
---

# Malawi bid document from template

Turns the user's bid document template (originally "Lot 16 / MJDC-MTIRAMANJA Updated Bid Document.docx", or the latest finished bid they hand you) into a bid for a new tender, using:

1. **Template** – the user's .docx (ECO-CONSTRUCTION LIMITED bid: Bid Submission Form, declarations, Section 0 qualification, Technical Approach Sections 1–22, signatures).
2. **Government bidding document** – .doc/.docx (NCB / ITB / IFB / RFQ). The source of truth for subject, reference, dates, validity, copies, start date and duration.
3. **BOQ** – .xlsx. The source of the contract price and the scope.

Output: one edited .docx, renamed, plus a short report to the user. Work in the edit-existing-docx way (unzip → edit `word/document.xml` → zip). Load the `docx` skill first if the harness has it.

## Hard rules

- **Keep every signature intact.** Never edit or delete a paragraph that contains `w:drawing` / `w:pict`. Signatory names, positions and company details stay. After the build, the count of `r:embed="rIdX"` per image id must equal the template's.
- **Copy the subject and reference number exactly as the government document writes them**, typos included (e.g. `DIRSTRICTWIDE`, `Incenarator`). Say in the report that you kept them verbatim.
- **The lot number comes from the government document's file name** ("LOT 14" etc.) and from the reference suffix (`/PHASE2/14`). If the user's message names a different lot or project than the uploaded files, follow the files and flag it.
- **Bid validity = the BDS's ITB 19.1 value.** It is usually 120 days but not always (Lot 10 was 130). Update both the Bid Submission Form para (e) and the Section 0.1.2 "Bid Validity" row.
- Do not ask questions when the request is clear; the user wants it done. Ask only if the BOQ has no rates at all (then there is no price to insert).

## Step 1 – Read the government document

Convert `.doc` → `.docx` with LibreOffice (`soffice --headless --convert-to docx`), then `pandoc -t plain` and grep. Collect:

| Item | Where |
|---|---|
| Subject of procurement, reference number, date of issue | Cover table |
| Lots | BDS ITB 1.1 (usually N/A; use the file name's LOT N) |
| Clarification / submission address, email | BDS ITB 10.1, 23.2 |
| Additional documents required | BDS ITB 13(i) |
| Bid validity | BDS ITB 19.1 |
| Bid security / securing declaration | BDS ITB 20.2 / 20.3 |
| Number of copies | BDS ITB 22.1 |
| Submission deadline and time | BDS ITB 23.1 |
| Site, Start Date, Intended Completion | SCC GCC 1.1 (so far: Start 5 Dec 2026, completion "after 3 months on project Handover" = 90 days) |
| Defects liability | SCC GCC 37.1 (so far 365 days) |
| Key personnel and equipment | Section 3, "7. Personnel and Equipment" |

## Step 2 – Read and verify the BOQ

- Dump sheets with openpyxl. **Use `read_only=True` and `max_col=12`**: some BOQs have >16,000 columns and a normal load gets OOM-killed.
- Files named "BLANK" or "unpriced" have often been priced already (a `Rates` sheet linked into every bill). Check the summary amounts before assuming there is no price.
- **Recalculate before trusting cached values**: `soffice --headless --convert-to xlsx:"Calc MS Excel 2007 XML" --outdir rc boq.xlsx`, then read the recalculated summary with `data_only=True`.
- Take the price from the main / general summary's final line ("TOTAL CARRIED TO BID SUBMISSION FORM", "GRAND TOTAL" …). Advance payment = 20% of it. Round both to 2 dp and write both out in words ("… Kwacha and NN Tambala Only").
- Check the summary formulas: flag if VAT is charged on the pre-contingency subtotal (state what the total would be if VAT included contingency).
- List the bills (scope) and note quantities (e.g. "Single VIP latrine × 4"). **Compare with the bid title**: anything named in the title with no bill in the BOQ (e.g. a staff house, washing troughs) is flagged to the user and noted in the proposal (clarification item + programme assumption that the price covers the BOQ only).
- Note key materials per bill for the technical proposal: roof type (IBR Chromadek, Dektile, etc.), solar systems, solar water heaters, borehole and pump type, tank stands, septic tanks / manholes, demolitions, A/C, fire fighting, beds and mattresses, etc.

## Step 3 – Edit the template

Unzip, delete symlinks, run the docx skill's `merge_runs.py` so phrases are findable, then edit with lxml (helpers below). Change, in this order:

### 3a. Global text substitutions (run level)
Old project name → new subject; old reference → new reference; old council name (upper and title case) → new council; old person in "Attention"/"To" lines → new addressee; dates (date of issue; submission date = ITB 23.1 deadline; signing date on every form = the day before the deadline unless the user says otherwise).

### 3b. "Addressed to" blocks (six in the template, plus one one-line "To:" on the litigation-history form)
Keep the template's `To: The IPDC Chairperson,` line and put the person on the `Attention:` line. Then the council, P/Bag, town, and add `Email:` and `Tel:` lines by cloning the town paragraph. Default addressee for Ntcheu District Council tenders, as the user gave it:

```
Shameem Meggie Jussab, Chief Procurement Officer
Ntcheu District Council
P/Bag 97
Blantyre
Email: shameemjussab1@gmail.com
Tel: +265(0) 995 176 111 / +265(0) 884 610 665
```

For another council, use the address the user gives; otherwise use the BDS ITB 23.2 address. Flag it if the user's postal town differs from the government document's.

### 3c. Bid Submission Form
- (b) contract price in figures and words (bold run).
- (c) `Three (3) Months or Ninety (90) Days` (bold) + `from the Date of Site Handover, with the Start Date of <SCC date> as stated in the Special Conditions of Contract (GCC 1.1).`
- (d) 20% advance in figures and words.
- (e) `Our Bid shall remain valid for a period of <N days> (bold) from the date fixed for submission of Bids (<deadline>), in accordance with ITB 19.1 of the Bid Data Sheet, …`

### 3d. Section 0.1.2 Project Particulars
Project name; employer; reference; `Number of Lots` → `Lot N (Procurement Ref. No. ending /PHASE2/NN)`; `Funding` → `Malawi Government – Constituency Development Fund (CDF), <constituency from the reference>`; `Bid Validity` → `<N> Days from the Bid submission deadline (ITB 19.1)`. In 0.7 and 0.10, replace "building rehabilitation" wording with "building construction".

### 3e. Technical proposal (Sections 1–21): rewrite for the new project
- **1** Executive summary: 3 paragraphs: (1) scope bill by bill from the BOQ + 90 days; (2) delivery strategy: parallel work fronts, hold points, rainy season (Dec–Mar) and festive holidays; (3) site context and its safeguards (operating school → child protection; hospital / health centre → patients, infection prevention, ambulance access; etc.).
- **1.1 / 1.2** tables: project + lot, programme basis (90 days from Site Handover; SCC Start Date), primary source (bidding doc + issue date + BOQ name), location (site, ward, constituency, district), contract duration (+ indicative completion date + DLP), construction basis (list every bill).
- **2.1** header "How it will be applied on the <short project name>"; "Safe-by-design" and "Protect …" rows suited to the site. **2.2**: "uncovered during rehabilitation" → "encountered during construction".
- **3** intro + work-package table (one row per bill / element); **3.1** joint site handover with the right local counterpart (head teacher, health centre in-charge, hospital management); **3.2** clarifications (layout vs BOQ, scope gaps, existing structures or services, certificates/lab tests, sample/data-sheet vetting, workplace registration).
- **4.1–4.10** phase headings with day ranges and paragraphs that match the programme; **4.11** hold points (keep HP-01–04, add services/drainage tests, borehole/solar commissioning, existing-substructure acceptance or tie-ins as relevant, handover).
- **5** materials table (keep timber/steel, blocks, concrete, ant-poison rows; add roofing, fittings, finishes, special equipment, borehole/tank rows); **5.2** procurement lead times by day ranges (order imported/solar items in Week 1; stock up before the festive shutdown).
- **6** QAP: insert extra rows (services and drainage tests, borehole, solar, etc.) by cloning a row that has **no `vMerge`**, placed before the "Project closing" rows.
- **7** intro paragraph; **7.1** baseline activity table (rebuild all rows, set column widths 600/2700/980/980/1160/2940); **7.1.1 Gantt chart** (new, see below); **7.2** weekly targets (8 rows: Wk 1, Wk 2, Wks 3–4 … Wk 13); **7.4** assumptions (SCC start date, QAP, rainy season, site context, public holidays 25–26 Dec / 1 Jan / 15 Jan / 3 Mar, and scope gaps or long-lead items).
- **8.1** row 1, **9.2** row 1 (meeting participants), **11.1** stage names, **14** intro + 14.1 safeguarding paragraph, **15** stakeholders, **17** "rehabilitation works" → "construction works", **19** close-out targets (Days 82–88 snagging; 365-day DLP), **20.1** A1 (mention Tables 7.1, 7.1.1 & 7.2) and A3, **21** "within 7 days from the Date of Award" → "by the Start Date stated in the SCC (<date>)".

### 3f. Programme design (90 days, 13 weeks)
15–17 activities A…Q with start/finish days, e.g. mobilisation 1–7; clearance/setting out 2–12; substructure(s) staggered; superstructure; roofs closed by Week 9–10 (rainy season); ancillary structures (latrines, incinerator, pits) and borehole/tank stand as independent fronts from ~Day 12–15; services ~50–82; finishes ~56–84; external works ~55–86; snagging 82–88; handover 87–90. Duration = finish − start + 1. Day 1 = SCC Start Date; Day 90 = Start + 89 days (5 Dec 2026 → 4 Mar 2027).

Gantt table (insert after the 7.1 table): heading paragraph cloned from "7.1 Baseline…" with `w:pageBreakBefore`, a note paragraph, then a fixed-layout table: ID 420 + Activity 2224 + 13 × 516 dxa. Three repeat-header rows (W1–W13; day ranges `1–7 … 85–90`; week-commencing dates), fill `1A365D`, white 7 pt text. One row per activity with cells shaded `2F6EBA` where the activity overlaps that week (`not (f < 7i+1 or s > 7i+7)`). Three milestone rows (fill `F2F2F2`, red `C0392B` ◆): M1 Week 1 start, M2 roofs weathertight, M3 Week 13 handover.

## Step 4 – Name, verify, deliver

- File name: `Lot <N> <COUNCIL ABBR>-<SITE IN CAPS> <Short project> Bid Document.docx`, e.g. `Lot 4 NTDC-GOMANI CHIKUSE CDSS Girls Hostel Bid Document.docx`, `Lot 14 NTDC-NTCHEU DISTRICT HOSPITAL Paying Ward Bid Document.docx`.
- Zip, then run the docx skill's `validate.py --original template.docx`.
- `pandoc -t plain` the result and grep for leftovers from the template and from earlier lots (old project, old reference, old council, old person, old price, `Private Bag 9`, `19TH OCTOBER`, `compound`, `strip-out`, `Date of Award`, other lots' site names, wrong validity). Only the company-experience tables may still mention old projects.
- Check the signature image count matches the template.
- Render to PDF and look at the cover, the Bid Submission Form pages and the Gantt page.
- Deliver the file (outputs folder / SendUserFile, or the user's connected folder).

## Step 5 – Report to the user (short)

**What changed**: project + reference (verbatim note if typos); dates; price + 20% advance (say it was recalculated; mention if the file was named BLANK/unpriced but priced); validity (call out loudly if not 120); addressee; technical proposal scope in one bullet list; Gantt dates + the roof milestone; signatures unchanged.

**Please check before submitting**: lot/project mismatch in the message; VAT base; scope in the title missing from the BOQ (most important when present); key personnel gaps vs Section 3 (so far every Ntcheu tender asked for an Electrician with Grade 1 trade test + MERA certification and a Social Development Officer with a Degree in Social Work, which the template lacks; also the Site Agent's years); equipment (10 t and 5 t lorries); number of copies; the extra ITB 13(i) attachments (500 Million CIRA Building Category certificate, MRA tax clearance for the current year, notarised Power of Attorney, Unit Rates Analysis Form, Beneficial Ownership form, ESHS declaration, construction schedule).

## Follow-ups the user asks for

- **Price change** ("I increased the total to X"): recalculate the new BOQ to confirm X, then replace only the two price paragraphs (figures + words; advance = 20%) in the already-built document and redeliver under the same file name. Change nothing else.
- **Pricing summary for the boss**: a document listing each lot (lot, project, reference, bid price, 20% advance, validity, copies) with a total row computed in Python, and any expenses (paper, printer repair …) in a separate table with its own total. Flag scope gaps under the table.

## Helper library (write to a scripts folder; run from the work folder)

```python
import copy, re
from lxml import etree
W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
XS = '{http://www.w3.org/XML/1998/namespace}space'
SRC = 'un/word/document.xml'
tree = etree.parse(SRC); root = tree.getroot(); body = root.find(W + 'body')

def txt(el): return ''.join(t.text or '' for t in el.iter(W + 't'))
def has_drawing(p): return p.find('.//' + W + 'drawing') is not None or p.find('.//' + W + 'pict') is not None

def find_para(start, nth=0, contains=False):
    hits = [p for p in body.iter(W + 'p') if ((start in txt(p)) if contains else txt(p).startswith(start))]
    if not hits: raise SystemExit('NOT FOUND: ' + start)
    return hits[nth]

def table_after(heading):           # last match skips the Contents list
    e = find_para(heading, nth=-1).getnext()
    while e is not None and e.tag != W + 'tbl': e = e.getnext()
    return e

def _run(p, text, rpr):
    r = etree.SubElement(p, W + 'r')
    if rpr is not None: r.append(copy.deepcopy(rpr))
    t = etree.SubElement(r, W + 't'); t.text = text; t.set(XS, 'preserve')

def set_par(p, text, bold_prefix=None):
    assert not has_drawing(p), 'never edit a signature paragraph'
    trs = [r for r in p if r.tag == W + 'r' and r.find(W + 't') is not None]
    rpr = (trs[-1] if trs else p.find(W + 'r')).find(W + 'rPr')
    for el in list(p):
        if el.tag in (W + 'r', W + 'hyperlink', W + 'proofErr', W + 'bookmarkStart', W + 'bookmarkEnd'): p.remove(el)
    if bold_prefix:
        b = copy.deepcopy(rpr) if rpr is not None else etree.Element(W + 'rPr')
        if b.find(W + 'b') is None: b.insert(1 if b.find(W + 'rFonts') is not None else 0, etree.Element(W + 'b'))
        _run(p, bold_prefix, b)
    _run(p, text, rpr)

def set_runs(p, parts):              # parts = [(text, bold), ...]
    assert not has_drawing(p)
    runs = [r for r in p if r.tag == W + 'r' and r.find(W + 't') is not None]
    plain = next((r.find(W + 'rPr') for r in runs if r.find(W + 'rPr') is None or r.find(W + 'rPr').find(W + 'b') is None), None)
    for el in list(p):
        if el.tag in (W + 'r', W + 'proofErr'): p.remove(el)
    for t, bold in parts:
        rp = copy.deepcopy(plain) if plain is not None else etree.Element(W + 'rPr')
        if bold:
            f = rp.find(W + 'rFonts'); i = list(rp).index(f) + 1 if f is not None else 0
            rp.insert(i, etree.Element(W + 'bCs')); rp.insert(i, etree.Element(W + 'b'))
        _run(p, t, rp)

def clone_after(p, text):
    n = copy.deepcopy(p); p.addnext(n); set_par(n, text); return n

def set_cell(tc, lines):
    lines = [lines] if isinstance(lines, str) else lines
    ps = tc.findall(W + 'p')
    for x in ps[1:]: tc.remove(x)
    set_par(ps[0], lines[0]); last = ps[0]
    for ln in lines[1:]: last = clone_after(last, ln)

def fill_table(tbl, data, template_row=1):   # keeps header row 0
    rows = tbl.findall(W + 'tr'); tmpl, anchor = rows[template_row], rows[0]
    for r in rows[1:]: tbl.remove(r)
    for rec in data:
        nr = copy.deepcopy(tmpl)
        for tc, v in zip(nr.findall(W + 'tc'), rec): set_cell(tc, v)
        anchor.addnext(nr); anchor = nr

def set_row(tbl, ri, rec):           # None = leave cell as is
    for tc, v in zip(tbl.findall(W + 'tr')[ri].findall(W + 'tc'), rec):
        if v is not None: set_cell(tc, v)

# Phase rewrite pattern for Section 4:
# h = find_para('4.1 Phase 1', nth=-1); set_par(h, new_heading); walk siblings until the next
# paragraph matching r'^4\.\d+ ', set_par the existing ones, clone_after for extras, remove leftovers.

# Finish:
# tree.write(SRC, xml_declaration=True, encoding='UTF-8', standalone=True)
```

Gantt cell builder (inside the same script): a `cell(text, width, fill=None, bold=False, color=None, size=14, align='left')` that writes `w:tcW` (dxa), single 4-pt `7F7F7F` borders, optional `w:shd` clear fill, 30/50 dxa margins, `vAlign center`, and one Arial run; `row(cells, header=False)` adds `w:cantSplit` (+ `w:tblHeader` for the 3 header rows). Table properties: `tblW` = 9352 dxa, `tblLayout fixed`, `tblGrid` matching the cell widths.
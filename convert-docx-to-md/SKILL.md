---
name: convert-docx-to-md
description: Automates the extraction and conversion of .docx binary files into structured Markdown (.md), preserving heading hierarchy, media assets, and formatting.
---

# Skill: Automated DOCX to Markdown Conversion & Asset Extraction

## Purpose

Automate the deep extraction and conversion of `.docx` binary files into structured Markdown (`.md`). This skill mandates the preservation of hierarchical heading structures (up to 5 levels), the physical extraction and relative embedding of media assets (images), and the dynamic generation of a snake_case output filename derived from the document's internal title metadata or primary header.

---

## Prerequisites & Tooling Scope

1. **No Data Loss:** All text, lists, bold/italic formatting, and image anchors must be preserved. Do not abstract or summarize the content.
2. **Media Handling:** The agent must have file-system write access to create an accompanying `assets/` or `images/` directory adjacent to the output Markdown file.
3. **Execution Environment:** Assume access to Python libraries (`python-docx`, `pypandoc`, `mammoth`) or native shell utilities (`pandoc`, `unzip`).

---

## Execution Protocol

### Step 1: Title Extraction & Filename Generation

1. Parse the `.docx` file to identify the document title.
   * **Primary Target:** Interrogate the `.docx` core properties (Dublin Core metadata) for the `Title` attribute.
   * **Fallback Target:** If the metadata is null, parse the document body and extract the first text node formatted with the `Title` or `Heading 1` style.
2. Sanitize and transform the extracted string into a snake_case format.
   * Convert all characters to lowercase.
   * Replace spaces, hyphens, and slashes with underscores (`_`).
   * Strip all non-alphanumeric characters.
   * Append the `.md` extension.
   * *Example:* "QueAudit System Architecture v2.1" becomes `queaudit_system_architecture_v2_1.md`.

### Step 2: Media Asset Extraction

A `.docx` file is an OOXML zipped archive. The agent must extract embedded media before text conversion.

1. Target the internal archive path: `word/media/`.
2. Extract all binary image files (e.g., `.png`, `.jpeg`, `.svg`) into a local directory named `{snake_case_title}_assets/`.
3. Map the internal relationships (`word/_rels/document.xml.rels`) to associate the extracted physical file names with their `rId` (Relationship ID) tags used in the document body.

### Step 3: Structural Markdown Conversion

Parse the XML body (`word/document.xml`) or utilize an abstraction library (`pandoc` or `mammoth`) to translate elements into Markdown syntax.

#### Heading Resolution (Levels 1-5)

The agent must explicitly evaluate the style definition of each paragraph node and map it to standard ATX Markdown headers:

* `Heading 1` -> `# {Text}`
* `Heading 2` -> `## {Text}`
* `Heading 3` -> `### {Text}`
* `Heading 4` -> `#### {Text}`
* `Heading 5` -> `##### {Text}`

#### Inline Formatting & Block Components

* **Emphasis:** Map `w:b` to `**text**` and `w:i` to `*text*`.
* **Lists:** Map `w:numPr` (numbered lists) to `1.` format and `w:ilvl` (bulleted lists) to `-` or `*` format, preserving indentation for nested lists.
* **Tables:** Convert Word tables into standard Markdown pipe (`|`) tables. Ensure table headers are delineated with `|---|` separators.

### Step 4: Asset Re-embedding

1. Locate the position of each image anchor (`w:drawing` or `w:pict`) in the document flow.
2. Retrieve the `rId` for the image and match it to the extracted file map from Step 2.
3. Inject the standard Markdown image syntax at the exact sequential location of the original image:

```markdown
![{Alt_Text_If_Available}](./{snake_case_title}_assets/{image_filename.ext})
```

### Step 5: File Output & Validation

1. Compile the parsed Markdown string.
2. Write the compiled string to the generated filename from Step 1 (e.g., queaudit_system_architecture_v2_1.md).
3. Validate that all heading hierarchies are syntactically valid (e.g., a space exists between the # characters and the heading text) and that all local image paths resolve correctly to the _assets/ directory.

# Fix Empty Font File Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the 0-byte font file `assets/fonts/Vazirmatn-Regular.ttf` with a placeholder string to prevent loading errors and document it in `pubspec.yaml`.

**Architecture:** This is a simple data-level fix. We replace the empty file with non-empty content and add a descriptive comment to the project configuration.

**Tech Stack:** Flutter (assets), Git

---

### Task 1: Replace Font File with Placeholder

**Files:**
- Modify: `assets/fonts/Vazirmatn-Regular.ttf`

- [ ] **Step 1: Write placeholder content to the font file**

Run: `echo "PLACEHOLDER" > "assets/fonts/Vazirmatn-Regular.ttf"`

- [ ] **Step 2: Verify the file is no longer empty**

Run: `ls -l "assets/fonts/Vazirmatn-Regular.ttf"`
Expected: File size should be > 0.

- [ ] **Step 3: Commit**

```bash
git add assets/fonts/Vazirmatn-Regular.ttf
git commit -m "chore: replace empty font file with placeholder"
```

---

### Task 2: Document Placeholder in pubspec.yaml

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add a comment to pubspec.yaml**

In the `fonts` section, add a comment indicating that the Vazirmatn font is currently a placeholder.

```yaml
  fonts:
    - family: Vazirmatn
      fonts:
        # NOTE: This font file is currently a 0-byte placeholder to prevent loading errors.
        # Replace with a real TTF file to use this font family.
        - asset: assets/fonts/Vazirmatn-Regular.ttf
```

- [ ] **Step 2: Run flutter analyze to ensure pubspec is still valid**

Run: `flutter analyze`
Expected: No errors related to `pubspec.yaml`.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml
git commit -m "docs: document font placeholder in pubspec.yaml"
```

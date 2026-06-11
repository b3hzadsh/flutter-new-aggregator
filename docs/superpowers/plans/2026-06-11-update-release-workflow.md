# Update GitHub Release Metadata Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the GitHub Release workflow to reflect the "News Aggregator" app identity instead of the "Tehran Metro Router" placeholder.

**Architecture:** Update the `Create GitHub Release` job in `.github/workflows/release.yaml`.

**Tech Stack:** GitHub Actions, YAML.

---

### Task 1: Update release.yaml metadata

**Files:**
- Modify: `.github/workflows/release.yaml`

- [ ] **Step 1: Update name and body in release.yaml**

Modify the `Create GitHub Release` step to use "News Aggregator" and relevant English description.

- [ ] **Step 2: Verify the change**

Read the file to ensure the replacement was successful and accurate.

- [ ] **Step 3: Commit the change**

```bash
git add .github/workflows/release.yaml
git commit -m "ci: update release workflow metadata for news aggregator"
```

# Project Workflow & Guidelines

This document outlines the strict workflow, version control, and testing standards for the Pallet Pro development process.

## 1. Version Control (Git)

### Commit Message Rules (Brown's 7 Rules)
We adhere strictly to the following rules for all commit messages:
1.  **Separate subject from body with a blank line.**
2.  **Limit the subject line to 50 characters.**
3.  **Capitalize the subject line.** (e.g., "Add inventory screen" not "add inventory screen")
4.  **Do not end the subject line with a period.**
5.  **Use the imperative mood in the subject line.** (e.g., "Fix bug" not "Fixed bug" or "Fixes bug")
6.  **Wrap the body at 72 characters.**
7.  **Use the body to explain _what_ and _why_ vs. _how_.**

### Checkpoints & Phasing
- **Phase Branches/Tags**: Work should be organized by Phases (e.g., `Phase 5`, `Sprint 1`). 
- **Checkpoints**: Significant progress points should be marked. 
  - *Standard*: Create a new branch or tag for each major phase start (e.g., `git checkout -b phase-5-inventory`).
  - *Confirmation*: **Always** confirm with the user before committing.

## 2. Testing Protocol

### "Physical" (Manual) Testing
Before any commit, a set of manual tests must be performed (or verified as passable). The agent will suggest a specific test plan for the current changes.

**Test Plan Template:**
1.  **Unit Tests**: Verify `flutter test` passes for modified logic.
2.  **Build Verification**: Verify `flutter analyze` passes.
3.  **Manual User Flow**: (Agent to define specific steps based on changes)
    - *Example*: "Tap 'Add Pallet', enter 'Test', tap 'Save'. Verify card appears."

## 3. Development Loop
1.  **Plan**: Agent proposes changes + Implementation Plan.
2.  **Implement**: Agent writes code.
3.  **Verify (Automated)**: Run `flutter analyze` and `flutter test`.
4.  **Verify (Manual)**: Agent proposes "Physical Test" steps. User/Agent confirms results.
5.  **Commit Proposal**: Agent drafts commit message (Brown's Rules).
6.  **Approval**: User approves commit.
7.  **Commit**: Agent executes git commit.

---
**Note:** This workflow ensures high quality, traceability, and stability at every step.

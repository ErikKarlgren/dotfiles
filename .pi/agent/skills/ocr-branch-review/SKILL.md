---
name: ocr-branch-review
description: Use when asked to review the current branch, review branch changes, or review a PR by first consulting the ocr delegate commands for the diff and review rules.
---

# OCR branch review

When the user asks for a review of the current branch or its changes, follow this workflow first.

## 1) Verify the `ocr` CLI exists

Use a shell command to check whether `ocr` is available in `PATH`.

If `ocr` is not present:
- Tell the user that `ocr` is not installed or not available in `PATH`.
- Ask whether they want you to continue **without** `ocr`.
- Warn them that reviewing without `ocr` will incur a **much higher token cost**.
- Do not continue with the review until the user answers.

## 2) Determine the base branch

Compute `<FROM>` as the parent branch of the current branch.

Preferred behavior:
- Use the current branch's upstream/tracking branch when it is configured, for example via `@{upstream}`.
- If no upstream/tracking branch is configured, ask the user instead of guessing.
- Treat the upstream/tracking branch as the review base unless the user says otherwise.

Use the same `<FROM>` value for both commands below.

## 3) Preview what needs review

Run:

```bash
ocr delegate preview --from <FROM> --to HEAD
```

Extract all changed or relevant paths from that output.

If the preview output does not provide any paths, say so to the user before continuing.

## 4) Request the review rules document

Run:

```bash
ocr delegate rule --from <FROM> --to HEAD <paths...>
```

Where:
- `<FROM>` is exactly the same value used in the preview step.
- `<paths...>` is the full set of paths obtained from the preview step.

## 5) Perform the review

Use the document returned by the `ocr delegate rule` command to guide the review.
Then inspect the relevant code and produce the review.

During the review:
- focus on correctness, regressions, edge cases, and missing tests unless the user asks for a different focus
- mention important findings first
- include file paths clearly
- say when no significant issues are found

## Notes

- Do not skip the `ocr delegate preview` step when the task is to review the current branch.
- Do not change `<FROM>` between the preview step and the rule step.
- If the user explicitly asks to review without `ocr`, proceed with an ordinary review.

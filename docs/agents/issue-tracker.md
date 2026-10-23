# Issue tracker: GitHub

Issues and specs live in GitHub Issues for `QF0xB/qnix-modules`.
Use the `gh` CLI from this repository. Outside this clone, pass
`--repo QF0xB/qnix-modules`.

## Operations

- Create: `gh issue create --title "..." --body-file <file>`.
- Read with discussion: `gh issue view <number> --comments`.
- Read structured details: `gh issue view <number> --json number,title,body,labels,comments`.
- List: `gh issue list --state open --json number,title,body,labels,comments`.
  Apply label and state filters as needed.
- Comment: `gh issue comment <number> --body-file <file>`.
- Add or remove labels: `gh issue edit <number> --add-label "..." --remove-label "..."`.
- Close: `gh issue close <number> --comment "..."`.

When a skill says “publish to the issue tracker,” create a GitHub issue.
When it says “fetch the relevant ticket,” read the issue and its comments.

## Pull requests as a triage surface

**PRs as a request surface: no.**

## Wayfinding operations

- Store the map in one issue labelled `wayfinder:map`.
- Link child tickets as GitHub sub-issues. If unavailable, use a task list
  in the map and a `Part of #<map>` line in each child.
- Use `wayfinder:research`, `wayfinder:prototype`, `wayfinder:grilling`,
  or `wayfinder:task` labels for child ticket types.
- Record blockers with native GitHub issue dependencies. Use the blocker's
  numeric database ID, not its issue number or node ID.
- If native dependencies are unavailable, use a `Blocked by: #<number>` line.
- Select the first open, unassigned child in map order with no open blockers.
- Claim with `gh issue edit <number> --add-assignee @me`.
- Resolve by commenting with the answer, closing the ticket, and adding
  a summary and link to the map's Decisions-so-far section.

# Domain docs

## Layout

This repository uses a single-context layout:

- `GLOSSARY.md` at the repository root defines domain vocabulary.
- `docs/adr/` holds numbered architecture decision records.

## Before exploring

Read `GLOSSARY.md` and ADRs relevant to the area being explored.

If these documents do not exist, proceed silently. Do not flag their
absence or suggest creating placeholders. Use `/domain-modeling` to create
them when terms or decisions are resolved.

## Vocabulary

Use glossary terms in issue titles, proposals, hypotheses, and test names.
If a needed concept is missing, reconsider the term or note the gap for
`/domain-modeling`.

## Decision conflicts

Explicitly identify any proposal that contradicts an existing ADR.
Name the ADR and explain why the decision should be reconsidered.

# aislop

[aislop](https://github.com/scanaislop/aislop) catches the patterns coding agents leave behind: dead imports, duplicate logic, unsafe `any` casts, narrative comments, swallowed errors, hidden fallbacks, oversized functions, and risky security constructs.

## On every edit

A PostToolUse hook runs `aislop hook claude` after every Edit, Write, or MultiEdit and scans the touched files. Clean scans stay silent. Findings arrive as `additionalContext` JSON (schema `aislop.hook.v2`) with `findings`, `nextSteps`, and `suggestedActions`. Act on them in the same turn.

## Severity ladder

- `error`: fix this turn.
- `warning` with `fixable: true`: fix this turn.
- `warning` with `fixable: false`: fix if mechanical, otherwise mention it in the reply.

## Principles

- `.aislop/config.yml` and `.aislop/rules.yml` are authoritative. Do not edit them without user consent.
- Do not disable rules to pass the scan. Fix the underlying issue.
- If a finding is a false positive, leave it and explain why in the reply.

# aislop

[aislop](https://github.com/scanaislop/aislop) catches the patterns coding agents leave behind: dead imports, duplicate logic, unsafe `any` casts, narrative comments, swallowed errors, hidden fallbacks, oversized functions, and risky security constructs.

Before finishing a code change in a Git repository, run `aislop scan --changes -d` and act on the findings for the files you touched:

- `error`: fix before finishing.
- `warning` that is fixable: fix before finishing. `aislop fix` applies the mechanical fixes.
- Other warnings: fix if mechanical, otherwise mention them in the reply.

`.aislop/config.yml` and `.aislop/rules.yml` are authoritative. Do not edit them without user consent. Do not disable rules to pass the scan. If a finding is a false positive, leave it and explain why in the reply.

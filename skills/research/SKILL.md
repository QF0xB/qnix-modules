---
name: research
description: Use for a requested research investigation or evidence-backed comparison. Gather primary sources and cite findings. Ordinary API lookups use the relevant documentation tool directly.
---

# Research

Define the question and use primary sources: official documentation, source
code, specifications, and first-party APIs. Distinguish observed facts,
inferences, and unanswered questions. Prefer sources matching the installed
version when evaluating configuration or compatibility.

For independent research tracks, delegate only when the user or applicable
instructions authorize it. Use the agent types and tool schema actually
available. With Task's `general` type, put the research role in the prompt;
do not assume a named researcher agent or a background-execution option exists.
Otherwise research directly. Preserve independent review where required.

Inspect configuration using allowlisted fields. Omit credential stores,
authentication files, environment secrets, and nested plugin option values.

Answer in chat unless the user requests a saved report or the repository's
workflow requires one. Saved notes follow the existing repository convention.
Cite sources and mark unverified claims. Never infer savings from tool marketing.

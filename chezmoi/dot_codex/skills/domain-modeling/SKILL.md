---
name: domain-modeling
description: Clarify codebase terms, domain concepts, or an ADR. Use for domain model discussions and CONTEXT.md or ADR edits.
---

# Domain Modeling

Clarify terms and relationships in the project's domain model. Compare the
user's language with existing code and glossary entries; surface material
contradictions with concrete examples.

Use the project's existing documentation location. If `CONTEXT-MAP.md` exists,
follow it to the relevant context. Write settled vocabulary in `CONTEXT.md`
using [the glossary format](CONTEXT-FORMAT.md) when a durable glossary is useful.
Keep implementation decisions out of the glossary.

Record a decision in an ADR only when it represents a meaningful trade-off that
future maintainers would otherwise struggle to understand. Use [the ADR
format](ADR-FORMAT.md) when adding one. Do not create empty docs or a new
folder structure for a conversation that has not settled a term or decision.

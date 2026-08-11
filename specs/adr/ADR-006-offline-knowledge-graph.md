# ADR-006: Offline Knowledge Graph Foundation

## Status

Accepted

## Context

DevCompass needs a portable, inspectable knowledge layer before it can provide search or personalized recommendations. The Workstation MVP intentionally has no mandatory runtime beyond Bash.

## Decision

Store the initial graph as version-controlled TSV files under `packages/knowledge/graph/`:

- `nodes.tsv`: `id`, `type`, `label`, `description`
- `edges.tsv`: `source_id`, `relation`, `target_id`

The graph supports `role`, `skill`, `technology`, `tool`, `package`, and `playbook` nodes with `requires`, `uses`, `guides_to`, and `depends_on` edges. The CLI exposes read-only `knowledge status`, `knowledge validate`, and `knowledge show <id>` commands. The M4 role-roadmap command traverses `requires` and `uses`; `devcompass recommend path --goal <node-id>` traverses `depends_on` transitively and emits prerequisites before the requested goal.

## Consequences

- The graph is offline, reviewable, and usable without installing a database.
- Role roadmaps can be generated deterministically without changing user-facing knowledge identifiers.
- Prerequisite paths are deterministic, reviewable, and fail safely when a cycle is detected.
- Personalized skill-gap analysis and adaptive learning plans remain deferred.
- This is not yet a graph database, semantic search engine, personalized coach, or AI system.

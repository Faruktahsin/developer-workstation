# ADR-006: Offline Knowledge Graph Foundation

## Status

Accepted

## Context

DevCompass needs a portable, inspectable knowledge layer before it can provide search or personalized recommendations. The Workstation MVP intentionally has no mandatory runtime beyond Bash.

## Decision

Store the initial graph as version-controlled TSV files under `packages/knowledge/graph/`:

- `nodes.tsv`: `id`, `type`, `label`, `description`
- `edges.tsv`: `source_id`, `relation`, `target_id`

The M3 graph supports `role`, `skill`, `technology`, `tool`, and `playbook` nodes with `requires`, `uses`, and `guides_to` edges. The CLI exposes read-only `knowledge status`, `knowledge validate`, and `knowledge show <id>` commands.

## Consequences

- The graph is offline, reviewable, and usable without installing a database.
- M4 can add graph search and recommendation logic without changing the user-facing knowledge identifiers.
- This is not yet a graph database, semantic search engine, personalized coach, or AI system.

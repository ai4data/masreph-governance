# Data Marketplace (public schema) — Discovery and Knowledge Graph Design

## 1) What exists in `data_marketplace.public`

### Tables and row counts

| Table | Rows |
|---|---:|
| `datasets` | 2,009 |
| `data_elements` | 55,955 |
| `dataset_metrics` | 2,009 |
| `dataset_preview` | 2,009 |
| `dataset_owners` | 4,018 |
| `data_owners` | 224 |
| `dataset_tags` | 33,369 |
| `tags` | 85 |
| `dataset_use_cases` | 113 |
| `use_cases` | 25 |
| `ratings` | 15,893 |
| `users` | 10 |
| `related_datasets` | 1,000 |

### Views

- `dataset_summary`
- `popular_tags`

### Relationship backbone (FKs)

- `data_elements.dataset_id -> datasets.id`
- `dataset_metrics.dataset_id -> datasets.id`
- `dataset_preview.dataset_id -> datasets.id`
- `dataset_owners.dataset_id -> datasets.id`
- `dataset_owners.owner_id -> data_owners.id`
- `dataset_tags.dataset_id -> datasets.id`
- `dataset_tags.tag_id -> tags.id`
- `dataset_use_cases.dataset_id -> datasets.id`
- `dataset_use_cases.use_case_id -> use_cases.id`
- `ratings.dataset_id -> datasets.id`
- `ratings.user_id -> users.id`
- `related_datasets.dataset_id -> datasets.id`
- `related_datasets.related_dataset_id -> datasets.id`

### Integrity/quality observations

- No FK orphans found in sampled checks for owners/tags/elements/metrics.
- `technical_id` always equals `id` in `datasets`.
- `dataset_metrics` quality fields are in valid range (`0..100`).
- `related_datasets` stores mirrored pairs (500 undirected pairs represented as 1,000 directed rows).
- Main null hotspots in `datasets`: `business_description` (702), `business_impact` (759), `location` (188), `source_sys_name` (34).

### Domain profile highlights

- Top domains: `Product` (614), `Client` (465), `Risk management` (388).
- Lifecycle heavily `Active` (1,508).
- Maturity heavily `Prepared for distribution` (1,729).
- Each dataset has exactly 1 `owner` and 1 `steward` in `dataset_owners`.

---

## 2) Knowledge Graph goal

Design a graph that supports:

- dataset discovery and recommendation
- governance traversal (owner/steward, classification, legal basis)
- impact analysis and lineage-like neighborhood (`related_datasets`)
- semantic search from business concept -> dataset -> element

---

## 3) Proposed ontology (property graph)

## Node types

- `Dataset`
- `DataElement`
- `DataOwner`
- `Tag`
- `UseCase`
- `User`
- `Rating`
- `MetricSnapshot`
- `Preview`
- `SourceSystem`
- `Domain`
- `Subdomain`
- `BusinessLine`
- `BusinessEntity`
- `Lifecycle`
- `Maturity`
- `Classification`
- `LegalBasis`
- `GeoLocation`

## Core node keys

- `Dataset`: `id`
- `DataElement`: composite (`dataset_id`, `name`) or surrogate `id`
- `DataOwner`: `id`
- `Tag`: `id`
- `UseCase`: `id`
- `User`: `id`
- `Rating`: `id`
- Other dimensions: normalized by `name`

## Edges

- `(:Dataset)-[:HAS_ELEMENT]->(:DataElement)`
- `(:Dataset)-[:HAS_METRIC]->(:MetricSnapshot)`
- `(:Dataset)-[:HAS_PREVIEW]->(:Preview)`
- `(:Dataset)-[:HAS_TAG]->(:Tag)`
- `(:Dataset)-[:USED_IN]->(:UseCase)`
- `(:Dataset)-[:OWNED_BY]->(:DataOwner)` where `role='owner'`
- `(:Dataset)-[:STEWARDED_BY]->(:DataOwner)` where `role='steward'`
- `(:Dataset)-[:RATED_BY]->(:User)` through `Rating` (either direct with props or via `Rating` node)
- `(:Dataset)-[:RELATED_TO {type, similarity_score}]->(:Dataset)`
- `(:Dataset)-[:IN_DOMAIN]->(:Domain)`
- `(:Dataset)-[:IN_SUBDOMAIN]->(:Subdomain)`
- `(:Dataset)-[:IN_BUSINESS_LINE]->(:BusinessLine)`
- `(:Dataset)-[:IN_BUSINESS_ENTITY]->(:BusinessEntity)`
- `(:Dataset)-[:FROM_SOURCE]->(:SourceSystem)`
- `(:Dataset)-[:HAS_LIFECYCLE]->(:Lifecycle)`
- `(:Dataset)-[:HAS_MATURITY]->(:Maturity)`
- `(:Dataset)-[:HAS_CLASSIFICATION]->(:Classification)`
- `(:Dataset)-[:HAS_LEGAL_BASIS]->(:LegalBasis)`
- `(:Dataset)-[:LOCATED_IN]->(:GeoLocation)`

---

## 4) Mapping from relational schema -> graph

- `datasets` is the hub node table.
- `data_elements` materializes column-level semantics (`HAS_ELEMENT`).
- `dataset_metrics` is one metric node per dataset (`HAS_METRIC`) with quality/usage/rating features.
- `dataset_preview` is one preview node per dataset (`HAS_PREVIEW`).
- `dataset_owners` + `data_owners` create responsibility edges with role semantics.
- `dataset_tags` + `tags` create taxonomy/folksonomy layer.
- `dataset_use_cases` + `use_cases` create consumption context graph.
- `ratings` + `users` create trust/popularity graph.
- `related_datasets` becomes `RELATED_TO`; deduplicate mirrored pairs for undirected semantics unless direction is needed.

---

## 5) Implementation rules

- Treat `Dataset.id` as global stable identifier.
- Keep `related_datasets` canonicalized by `(least(dataset_id, related_dataset_id), relationship_type)` to avoid duplicate edges.
- Store edge timestamps where available (`created_at`, `updated_at`).
- Preserve text-rich fields (`description`, `business_description`, `business_impact`) on `Dataset` for semantic search embeddings.

---

## 6) Minimal graph DDL (conceptual)

Example (Neo4j style constraints):

```cypher
CREATE CONSTRAINT dataset_id IF NOT EXISTS FOR (d:Dataset) REQUIRE d.id IS UNIQUE;
CREATE CONSTRAINT owner_id IF NOT EXISTS FOR (o:DataOwner) REQUIRE o.id IS UNIQUE;
CREATE CONSTRAINT tag_id IF NOT EXISTS FOR (t:Tag) REQUIRE t.id IS UNIQUE;
CREATE CONSTRAINT use_case_id IF NOT EXISTS FOR (u:UseCase) REQUIRE u.id IS UNIQUE;
CREATE CONSTRAINT user_id IF NOT EXISTS FOR (u:User) REQUIRE u.id IS UNIQUE;
```

---

## 7) High-value graph queries

- Find governed-but-underused high-quality datasets:
  - `quality_score > 85` and `usage_count < threshold`
- Owner impact radius:
  - all datasets, tags, and use cases reachable from one owner
- Tag-driven recommendations:
  - datasets sharing high-overlap tags and domain
- Risk/compliance discovery:
  - datasets with classification/legal basis + PII-like elements (`email`, `iban`, `phone`, etc.)
- Similar dataset surfacing:
  - traverse `RELATED_TO` + tag/domain similarity

---

## 8) Suggested phased build

1. Ingest hub (`Dataset`) + direct dimensions (`Domain`, `SourceSystem`, etc.).
2. Ingest ownership, tags, use-cases, ratings.
3. Ingest `DataElement` and build semantic search index on text fields.
4. Add governance scorecards and recommendation algorithms.
5. Add incremental sync from PostgreSQL change windows (`updated_at`).

---

## 9) Practical notes for this specific schema

- This schema is already graph-friendly (clear join tables, stable IDs).
- The biggest structural cleanup needed before production KG is de-duplicating mirrored `related_datasets` edges.
- Because `dataset_metrics`/`dataset_preview` are 1:1 with `datasets`, they can be flattened into `Dataset` properties if you prefer a lean graph.
- Keep `DataElement` as first-class nodes; this is where most governance and discovery value sits.

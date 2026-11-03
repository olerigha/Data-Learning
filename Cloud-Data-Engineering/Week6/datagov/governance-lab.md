# Week 6 Governance and Responsible AI Lab

## Outcome

Define who owns the gold dataset, what may be served, which contract consumers can rely on, how transformations are traced, and how AI-assisted work is reviewed. Apply every decision to the same governed data layer used by the Week 6 API and dashboard.

## 1. Catalog and provenance

Add or update the project entry in [the course data catalog](../docs/DATA-CATALOG.md). Record the owner, source URL, license, retrieval timestamp, refresh cadence, schema version, sensitivity, retention period, and verified deletion procedure. Name the person or team responsible for source changes and quality incidents.

## 2. Classification, privacy, and access

Create a field-level table with these columns: field, purpose, classification, privacy risk, allowed audience, and protection. Classify each field as public, internal, confidential, or restricted; identify direct identifiers, quasi-identifiers, sensitive attributes, and sensitive locations even when the current fixture is public.

State which privacy rules or contractual terms could apply in the dataset's jurisdiction and why. This is a reasoned engineering assessment, not legal advice. Minimize fields to those required by the analytical question, define who may read raw and aggregate layers, and choose masking, tokenization, aggregation, deletion, or documented acceptance for each identified risk.

## 3. Versioned data contract

Create `data-contract.yaml` for the gold dataset. Include an owner, semantic version, grain, refresh expectation, fields and types, nullability, quality constraints, and the compatibility policy. Use this minimum shape:

```yaml
owner: team-name
version: 1.0.0
dataset: gold_events
grain: one row per event date and event type
freshness: updated within 24 hours of source retrieval
fields:
  - name: event_date
    type: date
    nullable: false
  - name: event_count
    type: integer
    nullable: false
    minimum: 0
compatibility:
  breaking_change: increment major version and notify API/dashboard owners
```

Validate one conforming row and one deliberately invalid row. Explain whether adding, removing, renaming, or changing the type of a field is backward compatible for the API and dashboard.

## 4. Lineage and observability

Update [the course lineage record](../docs/DATA-LINEAGE.md) through the API and dashboard. For each transformation, record its command or job, input and output, schema version, row counts, rejected rows, timestamp, and code version. (See [`Data-Governance-and-Provenance.ipynb`](Data-Governance-and-Provenance.ipynb) for an executable reference implementation of provenance tracking and lineage generation).

Define at least one measurable data service-level indicator, such as freshness, accepted-row ratio, duplicate-key count, or schema-contract success. Give it a threshold, an owner, and a response. Capture one passing result and one controlled failure or simulated alert; application uptime alone is not data observability. (See [`observability-lab.md`](observability-lab.md) for failure-injection procedures and log evidence capture).

## 5. Responsible AI review

If an AI assistant contributed code, SQL, documentation, classifications, or visual choices, record the tool, task, and human verification performed. Do not submit credentials, restricted records, or unpublished personal data to a public AI service. Independently test generated queries and code, verify citations and licenses, inspect outputs for unsupported claims or harmful bias, and name the person accountable for the final decision.

If no AI tool was used, submit that statement and describe where AI assistance would require extra review in this data product.

## Submission evidence

- Completed catalog entry and field-classification table.
- `data-contract.yaml` plus passing and failing validation evidence.
- Updated lineage through the API and dashboard.
- Retention, deletion, and layer-level access decisions.
- One data observability rule with owner, threshold, and result.
- Responsible-AI use record or non-use statement with verification plan.
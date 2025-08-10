---
id: task-0015
title: Add data migration for existing decimal quantities
status: To Do
assignee: []
created_date: '2025-08-10'
labels:
  - fractions
  - migration
dependencies:
  - task-0008
  - task-0011
priority: low
---

## Description

Create a data migration to convert existing decimal quantities to fraction representation for consistency. Handle edge cases and maintain data integrity during the migration.

## Acceptance Criteria

- [ ] Migration converts existing decimal quantities to equivalent fractions
- [ ] Migration handles common decimals like 0.5 -> 1/2
- [ ] 0.25 -> 1/4
- [ ] Migration preserves exact decimal values that don't convert cleanly to simple fractions
- [ ] Migration provides rollback capability
- [ ] Migration logs conversion results for verification
- [ ] All existing recipes maintain their ingredient quantities after migration

---
id: task-0008
title: Add fraction storage fields to recipe ingredients
status: To Do
assignee: []
created_date: '2025-08-10'
labels:
  - fractions
  - database
dependencies: []
priority: medium
---

## Description

Add numerator and denominator integer fields to recipes_recipe_ingredients table to store fractions accurately without precision loss. Keep existing decimal quantity field for backward compatibility and mixed number support.

## Acceptance Criteria

- [ ] Migration adds numerator integer field
- [ ] Migration adds denominator integer field
- [ ] Migration allows both fields to be null for backward compatibility
- [ ] Schema supports accurate fraction storage (e.g.
- [ ] 1/3 stored as numerator=1
- [ ] denominator=3)
- [ ] Existing decimal quantities remain functional

---
id: task-0011
title: Update RecipeIngredient model with fraction support
status: To Do
assignee: []
created_date: '2025-08-10'
labels:
  - fractions
  - model
dependencies:
  - task-0008
  - task-0009
  - task-0010
priority: high
---

## Description

Enhance the Recipes::RecipeIngredient model to handle fraction input parsing and display. Add virtual attributes and validation for fraction quantities while maintaining backward compatibility.

## Acceptance Criteria

- [ ] Model accepts quantity input as string for fraction parsing
- [ ] Virtual quantity= setter parses fractions and stores in numerator/denominator
- [ ] Virtual quantity getter returns formatted fraction string for display
- [ ] Validation ensures either decimal quantity OR fraction fields are present
- [ ] Validation prevents invalid fraction combinations (denominator = 0)
- [ ] Model maintains backward compatibility with existing decimal quantities

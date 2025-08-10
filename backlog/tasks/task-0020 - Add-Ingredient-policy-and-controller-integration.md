---
id: task-0020
title: Add Ingredient policy and controller integration
status: To Do
assignee: []
created_date: '2025-08-10'
labels:
  - authorization
  - recipes
dependencies:
  - task-0018
---

## Description

Create IngredientPolicy for ingredient management and integrate it with the IngredientsController, providing proper authorization for ingredient CRUD operations.

## Acceptance Criteria

- [ ] IngredientPolicy is created with appropriate CRUD methods
- [ ] Policy includes scope for user-accessible ingredients
- [ ] IngredientsController integrates policy authorization correctly
- [ ] All ingredient controller actions are properly authorized
- [ ] Policy tests cover all permission scenarios including edge cases
- [ ] Controller integration tests verify authorization behavior

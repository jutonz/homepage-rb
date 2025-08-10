---
id: task-0021
title: Add RecipeIngredient policy
status: In Progress
assignee: []
created_date: '2025-08-10'
updated_date: '2025-08-10'
labels:
  - authorization
  - recipes
dependencies:
  - task-0019
---

## Description

Create RecipeIngredient policy to handle authorization for recipe-ingredient relationship operations and integrate it with the Recipes::IngredientsController.

## Acceptance Criteria

- [ ] RecipeIngredient policy is created for relationship management
- [ ] Policy handles create and destroy operations for recipe ingredients
- [ ] Recipes::IngredientsController uses policy authorization
- [ ] Policy ensures users can only modify ingredients on their own recipes
- [ ] Comprehensive tests cover relationship authorization scenarios
- [ ] Integration tests verify controller authorization works correctly

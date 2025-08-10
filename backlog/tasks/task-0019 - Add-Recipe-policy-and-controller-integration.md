---
id: task-0019
title: Add Recipe policy and controller integration
status: In Progress
assignee: []
created_date: '2025-08-10'
updated_date: '2025-08-10'
labels:
  - authorization
  - recipes
dependencies:
  - task-0018
---

## Description

Create RecipePolicy with comprehensive CRUD permissions and integrate it with the Recipes::RecipesController, ensuring proper authorization for all recipe operations.

## Acceptance Criteria

- [ ] RecipePolicy is created with index
- [ ] show
- [ ] create
- [ ] update
- [ ] destroy methods
- [ ] Policy includes proper scope for filtering recipes by user ownership
- [ ] Recipes::RecipesController uses authorize and policy_scope appropriately
- [ ] All recipe controller actions are properly authorized
- [ ] Comprehensive policy tests cover all permission scenarios
- [ ] Integration tests verify controller authorization works correctly

---
id: task-0026
title: Add API authorization policies
status: To Do
assignee: []
created_date: '2025-08-10'
labels:
  - authorization
  - api
dependencies:
  - task-0018
---

## Description

Create API::TokenPolicy for API token management and integrate authorization with the Settings::Api::TokensController to ensure proper API access control.

## Acceptance Criteria

- [ ] API::TokenPolicy is created with token management permissions
- [ ] Settings::Api::TokensController integrates policy authorization
- [ ] Policy ensures users can only manage their own API tokens
- [ ] API token operations are properly authorized
- [ ] Policy tests cover API token authorization scenarios
- [ ] Controller integration tests verify API authorization works correctly

---
id: task-0037
title: Add comprehensive authorization integration tests
status: To Do
assignee: []
created_date: '2025-08-11 01:04'
labels:
  - authorization
  - testing
  - integration
dependencies:
  - task-0030
  - task-0031
  - task-0032
  - task-0033
  - task-0034
  - task-0035
  - task-0036
---

## Description

Create integration tests that verify authorization works correctly across all major application flows including web and API contexts. Tests should cover both successful authorization and proper failure handling.

## Acceptance Criteria

- [ ] Integration tests cover all major web user flows with proper authorization
- [ ] Integration tests cover API authentication and authorization flows
- [ ] Tests verify proper error handling for unauthorized access in web context
- [ ] Tests verify proper JSON error responses for unauthorized API access
- [ ] Tests cover edge cases like missing tokens expired sessions and insufficient permissions
- [ ] Test suite runs successfully and covers authorization across the entire application
- [ ] Tests verify that authorization verification middleware catches missing authorization calls

---
id: task-0048
title: Add UserGroup invitation controller actions
status: Done
assignee: []
created_date: '2025-08-12 21:38'
updated_date: '2025-08-13 14:40'
labels:
  - controller
  - api
dependencies:
  - task-0046
---

## Description

Implement controller actions for creating and managing UserGroup invitations including authorization

## Acceptance Criteria

- [ ] Owner can create invitations by providing email address
- [ ] System validates email format and prevents duplicate invitations
- [ ] Only UserGroup owners can create invitations
- [ ] Controller handles invitation creation errors appropriately

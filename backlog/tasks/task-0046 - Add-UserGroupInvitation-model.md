---
id: task-0046
title: Add UserGroupInvitation model
status: Done
assignee: []
created_date: '2025-08-12 21:38'
updated_date: '2025-08-12 21:43'
labels:
  - database
  - model
dependencies:
  - task-0042
---

## Description

Create database model to track invitation state including email, token, expiration, and acceptance status

## Acceptance Criteria

- [ ] Migration creates user_group_invitations table with required fields
- [ ] Model includes proper validations and associations
- [ ] Model generates secure invitation tokens
- [ ] Model tracks invitation status and expiration

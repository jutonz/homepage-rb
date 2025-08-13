---
id: task-0051
title: Add UserGroupInvitation authorization policies
status: To Do
assignee: []
created_date: '2025-08-12 21:38'
labels:
  - authorization
  - security
dependencies:
  - task-0046
---

## Description

Create Pundit policies to control access to UserGroup invitation functionality

## Acceptance Criteria

- [ ] Policy allows only UserGroup owners to create invitations
- [ ] Policy restricts invitation viewing to appropriate users
- [ ] Policy integrates with existing authorization system
- [ ] All invitation controller actions use proper authorization

---
id: task-0049
title: Add invitation acceptance flow
status: To Do
assignee: []
created_date: '2025-08-12 21:38'
labels:
  - controller
  - authentication
dependencies:
  - task-0046
---

## Description

Implement the flow for users to accept UserGroup invitations via email links

## Acceptance Criteria

- [ ] Users can access invitation via secure token link
- [ ] System validates invitation token and expiration
- [ ] Accepting invitation creates UserGroupMembership
- [ ] Used or expired tokens are handled gracefully
- [ ] Users are redirected appropriately after acceptance

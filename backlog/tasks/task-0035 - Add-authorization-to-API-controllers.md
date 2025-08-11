---
id: task-0035
title: Add authorization to API controllers
status: To Do
assignee: []
created_date: '2025-08-11 01:03'
labels:
  - authorization
  - api
dependencies: []
---

## Description

Add proper Pundit authorization to API controllers including CurrentIpsController and WebhooksController. Some API endpoints may need special authorization handling or explicit skip_authorization.

## Acceptance Criteria

- [ ] CurrentIpsController includes appropriate authorization or skip_authorization
- [ ] TodoistController includes appropriate authorization for webhook endpoints
- [ ] Any other API controllers are reviewed and include proper authorization
- [ ] API-specific authorization patterns are documented and consistent
- [ ] Public API endpoints properly skip authorization with clear justification

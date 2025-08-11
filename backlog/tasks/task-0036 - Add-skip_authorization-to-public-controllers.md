---
id: task-0036
title: Add skip_authorization to public controllers
status: To Do
assignee: []
created_date: '2025-08-11 01:03'
labels:
  - authorization
  - public
dependencies: []
---

## Description

Properly configure public controllers (SessionsController HomesController CallbackController) to explicitly skip authorization verification since they handle public access and authentication flows.

## Acceptance Criteria

- [ ] SessionsController includes skip_after_action :verify_authorized
- [ ] HomesController includes skip_after_action :verify_authorized
- [ ] CallbackController includes skip_after_action :verify_authorized
- [ ] Skip configurations include clear comments explaining why authorization is skipped
- [ ] Controllers maintain existing functionality without authorization interference

---
id: task-0030
title: Add authorization verification middleware to ApplicationController
status: To Do
assignee: []
created_date: '2025-08-11 01:01'
labels:
  - authorization
  - middleware
dependencies:
  - task-0027
---

## Description

Implement after_action :verify_authorized in ApplicationController to catch controllers that don't properly authorize actions. This middleware will ensure no controller action bypasses authorization checks.

## Acceptance Criteria

- [ ] ApplicationController includes after_action :verify_authorized
- [ ] Public controllers (SessionsController HomesController CallbackController) are properly exempted via skip_after_action
- [ ] Controllers with authentication-only requirements can skip verification with skip_after_action
- [ ] Middleware provides helpful error messages when authorization is missing
- [ ] Error handling works correctly in test and development environments

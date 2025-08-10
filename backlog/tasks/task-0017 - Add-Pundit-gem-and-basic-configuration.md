---
id: task-0017
title: Add Pundit gem and basic configuration
status: To Do
assignee: []
created_date: '2025-08-10'
labels:
  - authorization
  - foundation
dependencies: []
priority: high
---

## Description

Install the Pundit gem and set up the foundational configuration including ApplicationController integration, ApplicationPolicy base class, and proper error handling for authorization failures.

## Acceptance Criteria

- [ ] Pundit gem is added to Gemfile and installed
- [ ] ApplicationController includes Pundit module and has rescue_from handler
- [ ] ApplicationPolicy base class is created with standard CRUD methods
- [ ] Authorization errors render appropriate responses (403 for web
- [ ] JSON error for API)
- [ ] Basic Pundit configuration is working without breaking existing functionality

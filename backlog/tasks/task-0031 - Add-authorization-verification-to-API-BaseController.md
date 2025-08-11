---
id: task-0031
title: 'Add authorization verification to API::BaseController'
status: To Do
assignee: []
created_date: '2025-08-11 01:02'
labels:
  - authorization
  - api
dependencies:
  - task-0030
---

## Description

Extend API::BaseController with authorization verification and ensure proper JSON error responses for authorization failures. API controllers need different error handling than web controllers.

## Acceptance Criteria

- [ ] API::BaseController includes after_action :verify_authorized
- [ ] JSON error responses are returned for Pundit::NotAuthorizedError
- [ ] Error responses include appropriate HTTP status codes and structure
- [ ] API authorization failures don't redirect but return proper JSON errors
- [ ] Authorization verification works with API token authentication

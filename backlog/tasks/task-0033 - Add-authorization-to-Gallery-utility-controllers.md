---
id: task-0033
title: Add authorization to Gallery utility controllers
status: To Do
assignee: []
created_date: '2025-08-11 01:02'
labels:
  - authorization
  - galleries
dependencies: []
---

## Description

Add proper Pundit authorization to BulkUploadsController AutoAddTagsController and TagSearchesController which currently only use authentication checks.

## Acceptance Criteria

- [ ] BulkUploadsController includes authorize calls for all actions
- [ ] AutoAddTagsController includes authorize calls for all actions
- [ ] TagSearchesController includes authorize calls for all actions
- [ ] Controllers integrate with existing gallery authorization patterns
- [ ] Manual current_user scoping is replaced with policy-based authorization where appropriate

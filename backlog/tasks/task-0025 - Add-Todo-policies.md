---
id: task-0025
title: Add Todo policies
status: To Do
assignee: []
created_date: '2025-08-10'
labels:
  - authorization
  - todo
dependencies:
  - task-0018
---

## Description

Create comprehensive authorization policies for the Todo module including Todo::Room, Todo::Task, and Todo::TaskOccurrence models, and integrate them with all Todo controllers.

## Acceptance Criteria

- [ ] Todo::RoomPolicy is created with proper CRUD and sharing permissions
- [ ] Todo::TaskPolicy is created with task management permissions
- [ ] Todo::TaskOccurrencePolicy is created for task occurrence operations
- [ ] All Todo controllers integrate policy authorization correctly
- [ ] Policies handle room sharing and task assignment permissions appropriately
- [ ] Policy scopes filter todo items based on user access and room membership
- [ ] Comprehensive tests cover all todo authorization scenarios
- [ ] Integration tests verify all todo controller authorization works

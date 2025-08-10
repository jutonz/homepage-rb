---
id: task-0024
title: Add Gallery Tag policies
status: In Progress
assignee: []
created_date: '2025-08-10'
updated_date: '2025-08-10'
labels:
  - authorization
  - gallery
dependencies:
  - task-0022
---

## Description

Create authorization policies for Galleries::Tag and Galleries::ImageTag models and integrate them with the corresponding tag controllers to manage tag operations.

## Acceptance Criteria

- [ ] Galleries::TagPolicy is created for tag management
- [ ] Galleries::ImageTagPolicy is created for image-tag relationships
- [ ] Tag controllers integrate policy authorization appropriately
- [ ] Policies handle tag creation
- [ ] modification
- [ ] and association permissions
- [ ] Policy scopes filter tags based on user permissions
- [ ] Comprehensive tests cover all tag authorization scenarios
- [ ] Integration tests verify tag controller authorization works

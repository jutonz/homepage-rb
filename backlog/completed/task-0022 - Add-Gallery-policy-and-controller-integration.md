---
id: task-0022
title: Add Gallery policy and controller integration
status: Done
assignee: []
created_date: '2025-08-10'
updated_date: '2025-08-10'
labels:
  - authorization
  - gallery
dependencies:
  - task-0018
---

## Description

Create GalleryPolicy with comprehensive authorization rules and integrate it with the GalleriesController, ensuring proper access control for gallery operations.

## Acceptance Criteria

- [ ] GalleryPolicy is created with full CRUD methods and proper scoping
- [ ] Policy handles both public and private gallery access appropriately
- [ ] GalleriesController integrates policy authorization on all actions
- [ ] Policy scope filters galleries based on user permissions and visibility
- [ ] Comprehensive policy tests cover all permission scenarios
- [ ] Controller integration tests verify authorization behavior
